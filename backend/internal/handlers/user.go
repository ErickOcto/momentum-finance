package handlers

import (
	"log/slog"

	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

// GetCurrentUserProfile returns the profile of the currently logged-in user
func GetCurrentUserProfile(c *fiber.Ctx) error {
	clerkID, ok := c.Locals("userID").(string)
	if !ok || clerkID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized request context",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())
	user, err := repo.GetByClerkID(c.Context(), clerkID)
	if err != nil {
		slog.Error("failed to find user by clerk id", "clerk_id", clerkID, "error", err)
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "user profile not found",
		})
	}

	return c.JSON(user)
}
