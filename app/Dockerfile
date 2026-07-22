FROM golang:1.19-alpine AS builder

WORKDIR /src

COPY go.mod ./

COPY main.go ./

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app .

FROM scratch

COPY --from=builder /app /app

USER 65532:65532

ENV APP_NAME=app

ENV PORT=8080

EXPOSE 8080

ENTRYPOINT ["/app"]