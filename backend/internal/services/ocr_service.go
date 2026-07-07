package services

import (
	"context"
	"os"
)

// ReceiptDetails represents the structured parser results
type ReceiptDetails struct {
	Amount          float64 `json:"amount"`
	Category        string  `json:"category"`
	Merchant        string  `json:"merchant"`
	TransactionDate string  `json:"transaction_date"` // YYYY-MM-DD
}

// ScanReceiptBytes processes the inbound receipt image bytes
func ScanReceiptBytes(ctx context.Context, imgBytes []byte) (*ReceiptDetails, error) {
	// If third-party AI keys are not set, return simulated parsing mock details
	openAIKey := os.Getenv("OPENAI_API_KEY")
	gVisionKey := os.Getenv("GOOGLE_VISION_API_KEY")

	if openAIKey == "" && gVisionKey == "" {
		// Mock implementation to enable offline local verification
		return &ReceiptDetails{
			Amount:          75000.0,
			Category:        "makan",
			Merchant:        "Warung Bu Kris",
			TransactionDate: "2026-07-07",
		}, nil
	}

	// Dynamic/Actual API parser logic would reside here.
	// For MVP skeleton purposes, default to mock structured mapping:
	return &ReceiptDetails{
		Amount:          85000.0,
		Category:        "kopi",
		Merchant:        "Starbucks Coffee",
		TransactionDate: "2026-07-07",
	}, nil
}
