package handlers

import (
	"context"
	"time"

	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

// HealthCheckHandler handles the /health endpoint requests, checking the DB connection
func HealthCheckHandler(c *fiber.Ctx) error {
	db := repositories.GetDB()
	if db == nil {
		return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
			"status": "error",
			"db":     "not_initialized",
		})
	}

	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	if err := db.Ping(ctx); err != nil {
		return c.Status(fiber.StatusServiceUnavailable).JSON(fiber.Map{
			"status": "error",
			"db":     "unavailable",
		})
	}

	return c.JSON(fiber.Map{
		"status": "ok",
		"db":     "connected",
	})
}
