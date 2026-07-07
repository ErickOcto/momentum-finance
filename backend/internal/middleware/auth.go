package middleware

import (
	"crypto/rsa"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"math/big"
	"net/http"
	"strings"
	"sync"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

// JSONWebKeys holds a list of JWK keys
type JSONWebKeys struct {
	Keys []JSONWebKey `json:"keys"`
}

// JSONWebKey represents a single JWK key
type JSONWebKey struct {
	Kty string   `json:"kty"`
	Kid string   `json:"kid"`
	Use string   `json:"use"`
	Alg string   `json:"alg"`
	N   string   `json:"n"`
	E   string   `json:"e"`
	X5c []string `json:"x5c"`
}

var (
	jwksMu       sync.RWMutex
	cachedKeys   = make(map[string]*rsa.PublicKey)
	lastFetched  time.Time
	jwksFetchURL string
)

// SetJWKSURL sets the URL from which to fetch the JWKS
func SetJWKSURL(url string) {
	jwksMu.Lock()
	defer jwksMu.Unlock()
	jwksFetchURL = url
}

func fetchJWKS() error {
	if jwksFetchURL == "" {
		return errors.New("JWKS URL is not set")
	}

	resp, err := http.Get(jwksFetchURL)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("JWKS request failed with status: %d", resp.StatusCode)
	}

	var jwks JSONWebKeys
	if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
		return err
	}

	newKeys := make(map[string]*rsa.PublicKey)
	for _, jwk := range jwks.Keys {
		if jwk.Kty != "RSA" || jwk.N == "" || jwk.E == "" {
			continue
		}

		// Decode exponent (base64url)
		decE, err := base64.RawURLEncoding.DecodeString(jwk.E)
		if err != nil {
			continue
		}
		if len(decE) < 4 {
			ndata := make([]byte, 4)
			copy(ndata[4-len(decE):], decE)
			decE = ndata
		}
		pubE := int(big.NewInt(0).SetBytes(decE).Uint64())

		// Decode modulus (base64url)
		decN, err := base64.RawURLEncoding.DecodeString(jwk.N)
		if err != nil {
			continue
		}
		pubN := big.NewInt(0).SetBytes(decN)

		newKeys[jwk.Kid] = &rsa.PublicKey{
			N: pubN,
			E: pubE,
		}
	}

	jwksMu.Lock()
	cachedKeys = newKeys
	lastFetched = time.Now()
	jwksMu.Unlock()

	slog.Info("JWKS keys successfully fetched and cached", "count", len(newKeys))
	return nil
}

func getPublicKey(kid string) (*rsa.PublicKey, error) {
	jwksMu.RLock()
	key, exists := cachedKeys[kid]
	fetchAge := time.Since(lastFetched)
	jwksMu.RUnlock()

	// Fetch if key is missing or older than 1 hour
	if !exists || fetchAge > 1*time.Hour {
		if err := fetchJWKS(); err != nil {
			if exists {
				return key, nil // Fallback to cached key on failure
			}
			return nil, err
		}
		jwksMu.RLock()
		key, exists = cachedKeys[kid]
		jwksMu.RUnlock()
		if !exists {
			return nil, fmt.Errorf("public key not found for kid: %s", kid)
		}
	}

	return key, nil
}

// ClerkAuthMiddleware validates Clerk JWT session tokens
func ClerkAuthMiddleware() fiber.Handler {
	return func(c *fiber.Ctx) error {
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "missing authorization header",
			})
		}

		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || strings.ToLower(parts[0]) != "bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "invalid authorization header format",
			})
		}

		tokenString := parts[1]

		token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
			if _, ok := token.Method.(*jwt.SigningMethodRSA); !ok {
				return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
			}

			kid, ok := token.Header["kid"].(string)
			if !ok {
				return nil, errors.New("missing kid in token header")
			}

			return getPublicKey(kid)
		})

		if err != nil || !token.Valid {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": fmt.Sprintf("invalid token: %v", err),
			})
		}

		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "invalid claims structure",
			})
		}

		// Extract subject (user ID)
		sub, ok := claims["sub"].(string)
		if !ok || sub == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "missing subject in claims",
			})
		}

		// Save User ID to locals
		c.Locals("userID", sub)

		return c.Next()
	}
}
