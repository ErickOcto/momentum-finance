package handlers

import (
	"log/slog"
	"strings"
	"time"

	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

type CreateCashLogRequest struct {
	WalletID        *string `json:"wallet_id"`
	Amount          float64 `json:"amount"`
	Currency        string  `json:"currency"`
	Type            string  `json:"type"` // 'INCOME', 'EXPENSE', 'TRANSFER'
	Category        string  `json:"category"`
	Description     *string `json:"description"`
	TransactionDate *string `json:"transaction_date"` // YYYY-MM-DD
}

// GetCashLogs handles GET /api/v1/cash-logs
func GetCashLogs(c *fiber.Ctx) error {
	clerkID, ok := c.Locals("userID").(string)
	if !ok || clerkID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized request context",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())
	user, err := repo.GetByClerkID(c.Context(), clerkID)
	if err != nil {
		slog.Error("failed to find user profile for cash logs fetch", "clerk_id", clerkID, "error", err)
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "user profile not found",
		})
	}

	cashLogRepo := repositories.NewCashLogRepository(repositories.GetDB())
	logs, err := cashLogRepo.GetByUserID(c.Context(), user.ID)
	if err != nil {
		slog.Error("failed to fetch user cash logs", "user_id", user.ID, "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to retrieve cash logs",
		})
	}

	if logs == nil {
		logs = []repositories.CashLog{}
	}

	return c.JSON(logs)
}

// CreateCashLog handles POST /api/v1/cash-logs
func CreateCashLog(c *fiber.Ctx) error {
	clerkID, ok := c.Locals("userID").(string)
	if !ok || clerkID == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"error": "unauthorized request context",
		})
	}

	repo := repositories.NewUserRepository(repositories.GetDB())
	user, err := repo.GetByClerkID(c.Context(), clerkID)
	if err != nil {
		slog.Error("failed to find user profile for cash log create", "clerk_id", clerkID, "error", err)
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "user profile not found",
		})
	}

	var req CreateCashLogRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "cannot parse request body",
		})
	}

	req.Type = strings.ToUpper(strings.TrimSpace(req.Type))
	req.Category = strings.TrimSpace(req.Category)

	// Field Validation
	if req.Amount <= 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "transaction amount must be greater than zero",
		})
	}

	if req.Type != "INCOME" && req.Type != "EXPENSE" && req.Type != "TRANSFER" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "transaction type must be 'INCOME', 'EXPENSE', or 'TRANSFER'",
		})
	}

	if req.Category == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "transaction category is required",
		})
	}

	currency := strings.ToUpper(strings.TrimSpace(req.Currency))
	if currency == "" {
		currency = "IDR"
	}

	var txDate time.Time
	if req.TransactionDate != nil && *req.TransactionDate != "" {
		parsedDate, err := time.Parse("2006-01-02", *req.TransactionDate)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "transaction_date must be in YYYY-MM-DD format",
			})
		}
		txDate = parsedDate
	} else {
		txDate = time.Now()
	}

	l := &repositories.CashLog{
		UserID:          user.ID,
		WalletID:        req.WalletID,
		Amount:          req.Amount,
		Currency:        currency,
		Type:            req.Type,
		Category:        req.Category,
		Description:     req.Description,
		TransactionDate: txDate,
	}

	cashLogRepo := repositories.NewCashLogRepository(repositories.GetDB())
	if err := cashLogRepo.Create(c.Context(), l); err != nil {
		slog.Error("failed to create cash log transaction record", "user_id", user.ID, "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(l)
}
