package handlers

import (
	"io"
	"log/slog"

	"momentum-backend/internal/services"

	"github.com/gofiber/fiber/v2"
)

// ScanReceiptHandler handles POST /api/v1/receipts/scan
func ScanReceiptHandler(c *fiber.Ctx) error {
	fileHeader, err := c.FormFile("receipt")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "multipart form field 'receipt' image file is required",
		})
	}

	file, err := fileHeader.Open()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to open uploaded file",
		})
	}
	defer file.Close()

	imgBytes, err := io.ReadAll(file)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to read uploaded file bytes",
		})
	}

	if len(imgBytes) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "uploaded file is empty",
		})
	}

	details, err := services.ScanReceiptBytes(c.Context(), imgBytes)
	if err != nil {
		slog.Error("failed to parse receipt details via OCR service", "error", err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to scan receipt image",
		})
	}

	return c.JSON(details)
}
