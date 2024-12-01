package main

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func main() {
	r := chi.NewRouter()

	r.Use(
		middleware.RequestID,
		middleware.DefaultLogger,
		middleware.Recoverer,
	)

	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("Hello world!"))
	})

	http.ListenAndServe(":8080", r)
}
