package config

import (
	"os"
)

// Config holds all config variables loaded from environment variables
type Config struct {
	Port string
}

// LoadConfig reads configuration from the environment
func LoadConfig() *Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	return &Config{
		Port: port,
	}
}
