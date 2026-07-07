package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// Wallet represents the wallet entity mapping to database schema
type Wallet struct {
	ID        string
	UserID    string
	Name      string
	Type      string // 'CASH', 'BANK', 'EWALLET'
	Balance   float64
	Currency  string
	CreatedAt time.Time
	UpdatedAt time.Time
}

// WalletRepository defines database operations for wallets
type WalletRepository interface {
	GetByUserID(ctx context.Context, userID string) ([]Wallet, error)
	Create(ctx context.Context, wallet *Wallet) error
	GetByIDAndUserID(ctx context.Context, id string, userID string) (*Wallet, error)
}

type pgWalletRepository struct {
	db *pgxpool.Pool
}

// NewWalletRepository creates a new wallet repository instance
func NewWalletRepository(db *pgxpool.Pool) WalletRepository {
	return &pgWalletRepository{db: db}
}

// GetByUserID fetches all wallets belonging to a user
func (r *pgWalletRepository) GetByUserID(ctx context.Context, userID string) ([]Wallet, error) {
	query := `
		SELECT id, user_id, name, type, balance, currency, created_at, updated_at 
		FROM wallets 
		WHERE user_id = $1
	`
	rows, err := r.db.Query(ctx, query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var wallets []Wallet
	for rows.Next() {
		var w Wallet
		err := rows.Scan(&w.ID, &w.UserID, &w.Name, &w.Type, &w.Balance, &w.Currency, &w.CreatedAt, &w.UpdatedAt)
		if err != nil {
			return nil, err
		}
		wallets = append(wallets, w)
	}

	return wallets, nil
}

// GetByIDAndUserID fetches a single wallet by ID and owner User ID
func (r *pgWalletRepository) GetByIDAndUserID(ctx context.Context, id string, userID string) (*Wallet, error) {
	query := `
		SELECT id, user_id, name, type, balance, currency, created_at, updated_at 
		FROM wallets 
		WHERE id = $1 AND user_id = $2
	`
	row := r.db.QueryRow(ctx, query, id, userID)
	var w Wallet
	err := row.Scan(&w.ID, &w.UserID, &w.Name, &w.Type, &w.Balance, &w.Currency, &w.CreatedAt, &w.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &w, nil
}

// Create inserts a new wallet record
func (r *pgWalletRepository) Create(ctx context.Context, w *Wallet) error {
	query := `
		INSERT INTO wallets (id, user_id, name, type, balance, currency, created_at, updated_at)
		VALUES (gen_random_uuid(), $1, $2, $3, $4, $5, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query, w.UserID, w.Name, w.Type, w.Balance, w.Currency).
		Scan(&w.ID, &w.CreatedAt, &w.UpdatedAt)
	return err
}
