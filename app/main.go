package main

import (
	"errors"
	"fmt"
	"net/http"
	"os"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func run() error {
	appName := os.Getenv("APP_NAME")
	if appName == "" {
		return errors.New("APP_NAME is not set")
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	hostName, err := os.Hostname()
	if err != nil {
		return fmt.Errorf("failed to get hostname: %w", err)
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "app: %s, pod: %s", appName, hostName)
	})

	return http.ListenAndServe(":"+port, nil)
}
