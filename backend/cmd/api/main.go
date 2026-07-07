package main

import (
	"context"
	"fmt"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"momentum-backend/internal/config"
	"momentum-backend/internal/handlers"
	"momentum-backend/internal/middleware"
	"momentum-backend/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

func main() {
	// 1. Initialize structured logging
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	// 2. Load Configuration
	cfg := config.LoadConfig()
	logger.Info("configuration loaded", "port", cfg.Port)

	// Configure JWKS URL for Clerk middleware
	if cfg.ClerkJWKSURL != "" {
		middleware.SetJWKSURL(cfg.ClerkJWKSURL)
		logger.Info("Clerk JWKS URL configured", "url", cfg.ClerkJWKSURL)
	} else {
		logger.Warn("CLERK_JWKS_URL is not set; auth middleware requests will fail to initialize keys")
	}

	// Configure Clerk Webhook Secret
	if cfg.ClerkWebhookSecret != "" {
		handlers.ClerkWebhookSecret = cfg.ClerkWebhookSecret
		logger.Info("Clerk webhook signature verification enabled")
	} else {
		logger.Warn("CLERK_WEBHOOK_SECRET is not set; inbound webhooks will fail to verify")
	}

	// 2b. Initialize Database Connection Pool
	if cfg.DatabaseURL != "" {
		dbCtx, dbCancel := context.WithTimeout(context.Background(), 10*time.Second)
		_, err := repositories.InitDB(dbCtx, cfg.DatabaseURL)
		dbCancel()
		if err != nil {
			logger.Error("failed to initialize database connection pool", "error", err)
			// For MVP/Robustness we don't crash the server, but log it so healthcheck fails
		} else {
			defer repositories.CloseDB()
		}
	} else {
		logger.Warn("DATABASE_URL is not set; database connection pool skipped")
	}

	// 3. Initialize Fiber App
	app := fiber.New(fiber.Config{
		DisableStartupMessage: true,
	})

	// 4. Register Routes
	app.Get("/health", handlers.HealthCheckHandler)

	// API Group
	api := app.Group("/api/v1")
	api.Get("/protected", middleware.ClerkAuthMiddleware(), handlers.ProtectedHandler)
	api.Post("/webhooks/clerk", handlers.ClerkWebhookHandler)
	api.Get("/users/me", middleware.ClerkAuthMiddleware(), handlers.GetCurrentUserProfile)

	// Wallet Routes
	api.Get("/wallets", middleware.ClerkAuthMiddleware(), handlers.GetWallets)
	api.Post("/wallets", middleware.ClerkAuthMiddleware(), handlers.CreateWallet)

	// Cash Log Routes
	api.Get("/cash-logs", middleware.ClerkAuthMiddleware(), handlers.GetCashLogs)
	api.Post("/cash-logs", middleware.ClerkAuthMiddleware(), handlers.CreateCashLog)

	// 5. Start Server in a Goroutine
	serverErrors := make(chan error, 1)
	go func() {
		logger.Info(fmt.Sprintf("starting server on port %s", cfg.Port))
		if err := app.Listen(fmt.Sprintf(":%s", cfg.Port)); err != nil {
			serverErrors <- err
		}
	}()

	// 6. Graceful Shutdown Setup
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

	// Block waiting for server error or shutdown signal
	select {
	case err := <-serverErrors:
		logger.Error("server error on startup", "error", err)
		os.Exit(1)

	case sig := <-shutdown:
		logger.Info("shutdown signal received", "signal", sig.String())

		// Set a timeout context for shutdown cleanup
		_, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()

		logger.Info("shutting down server...")
		if err := app.Shutdown(); err != nil {
			logger.Error("could not gracefully shutdown server", "error", err)
			os.Exit(1)
		}
		logger.Info("server exited gracefully")
	}
}
