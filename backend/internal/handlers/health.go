package handlers

import (
	"github.com/gofiber/fiber/v2"
)

// HealthCheckHandler handles the /health endpoint requests
func HealthCheckHandler(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{
		"status": "ok",
	})
}
