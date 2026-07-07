package repositories

import (
	"context"
	"fmt"
	"log/slog"
	"sync"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	dbPool *pgxpool.Pool
	once   sync.Once
)

// InitDB initializes the pgx connection pool
func InitDB(ctx context.Context, databaseURL string) (*pgxpool.Pool, error) {
	var err error
	once.Do(func() {
		if databaseURL == "" {
			err = fmt.Errorf("database URL is empty")
			return
		}

		config, errConfig := pgxpool.ParseConfig(databaseURL)
		if errConfig != nil {
			err = fmt.Errorf("unable to parse database url: %w", errConfig)
			return
		}

		// Configure pool limits
		config.MaxConns = 10
		config.MinConns = 2
		config.MaxConnLifetime = 30 * time.Minute
		config.MaxConnIdleTime = 15 * time.Minute

		pool, errConnect := pgxpool.NewWithConfig(ctx, config)
		if errConnect != nil {
			err = fmt.Errorf("unable to create connection pool: %w", errConnect)
			return
		}

		// Verify connection is alive
		if errPing := pool.Ping(ctx); errPing != nil {
			pool.Close()
			err = fmt.Errorf("unable to ping database: %w", errPing)
			return
		}

		dbPool = pool
		slog.Info("database connection pool initialized successfully")
	})

	if err != nil {
		return nil, err
	}
	return dbPool, nil
}

// GetDB returns the database connection pool
func GetDB() *pgxpool.Pool {
	return dbPool
}

// CloseDB closes the database pool if initialized
func CloseDB() {
	if dbPool != nil {
		dbPool.Close()
		slog.Info("database connection pool closed")
	}
}
