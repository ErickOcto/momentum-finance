package handlers

import (
	"github.com/gofiber/fiber/v2"
)

// ProtectedHandler handles requests for testing authenticated routes
func ProtectedHandler(c *fiber.Ctx) error {
	userID := c.Locals("userID")
	return c.JSON(fiber.Map{
		"message": "authenticated successfully",
		"userId":  userID,
	})
}
