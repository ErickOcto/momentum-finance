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
	CreateUser(ctx context.Context, user *User) error
	DeleteUserByClerkID(ctx context.Context, clerkID string) error
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

// CreateUser inserts a new user record
func (r *pgUserRepository) CreateUser(ctx context.Context, user *User) error {
	query := `
		INSERT INTO users (id, clerk_id, email, display_name, created_at, updated_at)
		VALUES (gen_random_uuid(), $1, $2, $3, NOW(), NOW())
		RETURNING id, created_at, updated_at
	`
	err := r.db.QueryRow(ctx, query, user.ClerkID, user.Email, user.DisplayName).
		Scan(&user.ID, &user.CreatedAt, &user.UpdatedAt)
	return err
}

// DeleteUserByClerkID removes user record by Clerk unique ID
func (r *pgUserRepository) DeleteUserByClerkID(ctx context.Context, clerkID string) error {
	query := `
		DELETE FROM users 
		WHERE clerk_id = $1
	`
	_, err := r.db.Exec(ctx, query, clerkID)
	return err
}
