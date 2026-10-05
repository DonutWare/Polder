package main

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"polder-server/internal/app"
	"polder-server/internal/config"
	"polder-server/internal/httpapi"
)

const shutdownTimeout = 15 * time.Second

func main() {
	slog.SetDefault(slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{Level: logLevel()})))
	if len(os.Args) > 1 && os.Args[1] == "healthcheck" {
		os.Exit(healthcheck())
	}
	if len(os.Args) > 1 && os.Args[1] == "openapi" {
		os.Exit(printOpenAPI())
	}
	if err := run(); err != nil {
		slog.Error("polder stopped", "error", err)
		os.Exit(1)
	}
}

func logLevel() slog.Level {
	if os.Getenv("POLDER_DEBUG") != "" {
		return slog.LevelDebug
	}
	return slog.LevelInfo
}

func run() error {
	cfg, err := config.Load()
	if err != nil {
		return err
	}
	application, err := app.New(cfg)
	if err != nil {
		return err
	}
	defer application.Close()

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	application.StartBackgroundWork(ctx)
	return serve(ctx, cfg, application.Handler)
}

func serve(ctx context.Context, cfg config.Config, handler http.Handler) error {
	server := &http.Server{Addr: cfg.ListenAddress, Handler: handler, ReadHeaderTimeout: 10 * time.Second}
	serverErrors := make(chan error, 1)
	go func() {
		slog.Info("polder listening", "address", cfg.ListenAddress, "database", cfg.DatabaseDriver,
			"config", cfg.ConfigDir, "data", cfg.DataDir)
		serverErrors <- server.ListenAndServe()
	}()

	select {
	case err := <-serverErrors:
		return err
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.Background(), shutdownTimeout)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil && !errors.Is(err, http.ErrServerClosed) {
			return err
		}
		return nil
	}
}

func printOpenAPI() int {
	spec, err := httpapi.OpenAPI()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	var indented bytes.Buffer
	if err := json.Indent(&indented, spec, "", "  "); err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	indented.WriteByte('\n')
	if _, err := indented.WriteTo(os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	return 0
}

func healthcheck() int {
	cfg, err := config.Load()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	_, port, err := net.SplitHostPort(cfg.ListenAddress)
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	client := http.Client{Timeout: 5 * time.Second}
	response, err := client.Get("http://127.0.0.1:" + port + "/healthz")
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		return 1
	}
	defer response.Body.Close()
	if response.StatusCode != http.StatusOK {
		return 1
	}
	return 0
}
