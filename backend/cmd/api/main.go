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
