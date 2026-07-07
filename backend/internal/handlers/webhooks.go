package handlers

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"strings"

	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

// ClerkWebhookSecret stores the configured secret for Svix signatures
var ClerkWebhookSecret string

// ClerkWebhookEvent holds the outer event envelope
type ClerkWebhookEvent struct {
	Type string          `json:"type"`
	Data json.RawMessage `json:"data"`
}

// ClerkUserData represents payload details for user created/updated
type ClerkUserData struct {
	ID             string                  `json:"id"`
	EmailAddresses []ClerkEmailAddressData `json:"email_addresses"`
	FirstName      string                  `json:"first_name"`
	LastName       string                  `json:"last_name"`
}

// ClerkEmailAddressData holds email list elements
type ClerkEmailAddressData struct {
	EmailAddress string `json:"email_address"`
}

// VerifySvixSignature checks validity of Svix headers
func VerifySvixSignature(secret string, id string, timestamp string, body []byte, signatureHeader string) error {
	if secret == "" {
		return errors.New("webhook secret not configured")
	}

	cleanSecret := secret
	if strings.HasPrefix(secret, "whsec_") {
		cleanSecret = strings.TrimPrefix(secret, "whsec_")
	}
	key, err := base64.StdEncoding.DecodeString(cleanSecret)
	if err != nil {
		return fmt.Errorf("invalid base64 secret: %w", err)
	}

	toSign := fmt.Sprintf("%s.%s.%s", id, timestamp, string(body))
	h := hmac.New(sha256.New, key)
	h.Write([]byte(toSign))
	computedSig := hex.EncodeToString(h.Sum(nil))

	signatures := strings.Split(signatureHeader, " ")
	for _, sig := range signatures {
		parts := strings.Split(sig, ",")
		if len(parts) == 2 && parts[0] == "v1" {
			if hmac.Equal([]byte(parts[1]), []byte(computedSig)) {
				return nil
			}
		}
	}

	return errors.New("signature mismatch")
}

// ClerkWebhookHandler processes inbound Clerk webhook payloads
func ClerkWebhookHandler(c *fiber.Ctx) error {
	svixID := c.Get("svix-id")
	svixTimestamp := c.Get("svix-timestamp")
	svixSignature := c.Get("svix-signature")

	if svixID == "" || svixTimestamp == "" || svixSignature == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "missing required svix headers",
		})
	}

	body := c.Body()

	// Verify Svix signatures
	if err := VerifySvixSignature(ClerkWebhookSecret, svixID, svixTimestamp, body, svixSignature); err != nil {
		slog.Error("webhook signature verification failed", "error", err)
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid signature",
		})
	}

	var event ClerkWebhookEvent
	if err := json.Unmarshal(body, &event); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "malformed JSON body",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())

	switch event.Type {
	case "user.created":
		var uData ClerkUserData
		if err := json.Unmarshal(event.Data, &uData); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "invalid user data format",
			})
		}

		email := ""
		if len(uData.EmailAddresses) > 0 {
			email = uData.EmailAddresses[0].EmailAddress
		}

		displayName := strings.TrimSpace(fmt.Sprintf("%s %s", uData.FirstName, uData.LastName))
		var dispNamePtr *string
		if displayName != "" {
			dispNamePtr = &displayName
		}

		user := &repositories.User{
			ClerkID:     uData.ID,
			Email:       email,
			DisplayName: dispNamePtr,
		}

		// Insert user in PG
		if err := repo.CreateUser(c.Context(), user); err != nil {
			slog.Error("failed to create user from webhook", "clerk_id", uData.ID, "error", err)
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "database error on user creation",
			})
		}

		slog.Info("user successfully synced from clerk webhook", "clerk_id", uData.ID, "user_id", user.ID)

	case "user.deleted":
		var uData struct {
			ID string `json:"id"`
		}
		if err := json.Unmarshal(event.Data, &uData); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "invalid user deletion payload",
			})
		}

		if err := repo.DeleteUserByClerkID(c.Context(), uData.ID); err != nil {
			slog.Error("failed to delete user from webhook", "clerk_id", uData.ID, "error", err)
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "database error on user deletion",
			})
		}

		slog.Info("user successfully deleted from clerk webhook", "clerk_id", uData.ID)
	}

	return c.SendStatus(fiber.StatusOK)
}
