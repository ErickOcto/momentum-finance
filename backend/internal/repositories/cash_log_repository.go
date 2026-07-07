package repositories

import (
	"context"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// CashLog represents the cash_log entity mapping to database schema
type CashLog struct {
	ID              string
	UserID          string
	WalletID        *string
	Amount          float64
	Currency        string
	Type            string // 'INCOME', 'EXPENSE', 'TRANSFER'
	Category        string
	Description     *string
	TransactionDate time.Time
	CreatedAt       time.Time
}

// CashLogRepository defines database operations for transactions
type CashLogRepository interface {
	GetByUserID(ctx context.Context, userID string) ([]CashLog, error)
	Create(ctx context.Context, log *CashLog) error
}

type pgCashLogRepository struct {
	db *pgxpool.Pool
}

// NewCashLogRepository creates a new cash log repository instance
func NewCashLogRepository(db *pgxpool.Pool) CashLogRepository {
	return &pgCashLogRepository{db: db}
}

// GetByUserID fetches all cash log transactions for a user
func (r *pgCashLogRepository) GetByUserID(ctx context.Context, userID string) ([]CashLog, error) {
	query := `
		SELECT id, user_id, wallet_id, amount, currency, type, category, description, transaction_date, created_at 
		FROM cash_logs 
		WHERE user_id = $1
		ORDER BY transaction_date DESC, created_at DESC
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var logs []CashLog
	for rows.Next() {
		var l CashLog
		err := rows.Scan(&l.ID, &l.UserID, &l.WalletID, &l.Amount, &l.Currency, &l.Type, &l.Category, &l.Description, &l.TransactionDate, &l.CreatedAt)
		if err != nil {
			return nil, err
		}
		logs = append(logs, l)
	}

	return logs, nil
}

// Create inserts a cash log and updates the linked wallet balance inside a transaction
func (r *pgCashLogRepository) Create(ctx context.Context, l *CashLog) error {
	tx, err := r.db.Begin(ctx)
	if err != nil {
		return err
	}
	defer tx.Rollback(ctx)

	// 1. Insert Cash Log
	queryLog := `
		INSERT INTO cash_logs (id, user_id, wallet_id, amount, currency, type, category, description, transaction_date, created_at)
		VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, $6, $7, COALESCE($8, CURRENT_DATE), NOW())
		RETURNING id, transaction_date, created_at
	`
	var tDate time.Time
	err = tx.QueryRow(ctx, queryLog, l.UserID, l.WalletID, l.Amount, l.Currency, l.Type, l.Category, l.Description, l.TransactionDate).
		Scan(&l.ID, &tDate, &l.CreatedAt)
	if err != nil {
		return fmt.Errorf("failed to insert cash log: %w", err)
	}
	l.TransactionDate = tDate

	// 2. Update linked Wallet balance if applicable
	if l.WalletID != nil && *l.WalletID != "" {
		delta := l.Amount
		if l.Type == "EXPENSE" {
			delta = -l.Amount
		}

		queryWallet := `
			UPDATE wallets 
			SET balance = balance + $1, updated_at = NOW() 
			WHERE id = $2 AND user_id = $3
		`
		tag, err := tx.Exec(ctx, queryWallet, delta, *l.WalletID, l.UserID)
		if err != nil {
			return fmt.Errorf("failed to update wallet balance: %w", err)
		}
		if tag.RowsAffected() == 0 {
			return fmt.Errorf("wallet not found or not owned by user")
		}
	}

	return tx.Commit(ctx)
}
