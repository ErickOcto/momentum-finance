package repositories

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// User represents the user entity mapping to database schema
type User struct {
	ID          string
	ClerkID     string
	Email       string
	DisplayName *string
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// UserRepository defines database operations for users
type UserRepository interface {
	GetByClerkID(ctx context.Context, clerkID string) (*User, error)
}

type pgUserRepository struct {
	db *pgxpool.Pool
}

// NewUserRepository creates a new user repository instance
func NewUserRepository(db *pgxpool.Pool) UserRepository {
	return &pgUserRepository{db: db}
}

// GetByClerkID fetches user by their Clerk unique ID
func (r *pgUserRepository) GetByClerkID(ctx context.Context, clerkID string) (*User, error) {
	query := `
		SELECT id, clerk_id, email, display_name, created_at, updated_at 
		FROM users 
		WHERE clerk_id = $1
	`
	row := r.db.QueryRow(ctx, query, clerkID)
	var u User
	err := row.Scan(&u.ID, &u.ClerkID, &u.Email, &u.DisplayName, &u.CreatedAt, &u.UpdatedAt)
	if err != nil {
		return nil, err
	}
	return &u, nil
}
