package handlers

import (
	"log/slog"
	"strings"

	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

type CreateWalletRequest struct {
	Name     string  `json:"name"`
	Type     string  `json:"type"` // 'CASH', 'BANK', 'EWALLET'
	Balance  float64 `json:"balance"`
	Currency string  `json:"currency"`
}

// GetWallets handles GET /api/v1/wallets
func GetWallets(c *fiber.Ctx) error {
	clerkID, ok := c.Locals("userID").(string)
	if !ok || clerkID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized request context",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())
	user, err := repo.GetByClerkID(c.Context(), clerkID)
	if err != nil {
		slog.Error("failed to find user profile for wallets fetch", "clerk_id", clerkID, "error", err)
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "user profile not found",
		})
	}

	walletRepo := repositories.NewWalletRepository(repositories.GetDB())
	wallets, err := walletRepo.GetByUserID(c.Context(), user.ID)
	if err != nil {
		slog.Error("failed to fetch user wallets", "user_id", user.ID, "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to retrieve wallets",
		})
	}

	if wallets == nil {
		wallets = []repositories.Wallet{}
	}

	return c.JSON(wallets)
}

// CreateWallet handles POST /api/v1/wallets
func CreateWallet(c *fiber.Ctx) error {
	clerkID, ok := c.Locals("userID").(string)
	if !ok || clerkID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized request context",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())
	user, err := repo.GetByClerkID(c.Context(), clerkID)
	if err != nil {
		slog.Error("failed to find user profile for wallet create", "clerk_id", clerkID, "error", err)
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "user profile not found",
		})
	}

	var req CreateWalletRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "cannot parse request body",
		})
	}

	req.Name = strings.TrimSpace(req.Name)
	req.Type = strings.ToUpper(strings.TrimSpace(req.Type))

	if req.Name == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "wallet name is required",
		})
	}

	if req.Type != "CASH" && req.Type != "BANK" && req.Type != "EWALLET" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "wallet type must be 'CASH', 'BANK', or 'EWALLET'",
		})
	}

	currency := strings.ToUpper(strings.TrimSpace(req.Currency))
	if currency == "" {
		currency = "IDR"
	}

	w := &repositories.Wallet{
		UserID:   user.ID,
		Name:     req.Name,
		Type:     req.Type,
		Balance:  req.Balance,
		Currency: currency,
	}

	walletRepo := repositories.NewWalletRepository(repositories.GetDB())
	if err := walletRepo.Create(c.Context(), w); err != nil {
		slog.Error("failed to create wallet record", "user_id", user.ID, "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to create wallet",
		})
	}

	return c.Status(fiber.StatusCreated).JSON(w)
}
