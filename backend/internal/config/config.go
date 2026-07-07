package config

import (
	"os"
)

// Config holds all config variables loaded from environment variables
type Config struct {
	Port               string
	DatabaseURL        string
	ClerkJWKSURL       string
	ClerkWebhookSecret string
}

// LoadConfig reads configuration from the environment
func LoadConfig() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	dbURL := os.Getenv("DATABASE_URL")
	jwksURL := os.Getenv("CLERK_JWKS_URL")
	webhookSecret := os.Getenv("CLERK_WEBHOOK_SECRET")

	return &Config{
		Port:               port,
		DatabaseURL:        dbURL,
		ClerkJWKSURL:       jwksURL,
		ClerkWebhookSecret: webhookSecret,
	}
}
