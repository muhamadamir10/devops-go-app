FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY . .

ARG VERSION=1.0.0
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-X main.version=${VERSION}" -o app main.go

FROM alpine:3.19

WORKDIR /app
COPY --from=builder /app/app .

EXPOSE 8080
ENTRYPOINT ["./app"]