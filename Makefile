.PHONY: test build run-v1 hotfix-v2 clean help

# Variabel Proyek
IMAGE_NAME = devops-go-app
VERSION_V1 = 1.0.0
VERSION_V2 = 1.0.1
CONTAINER_NAME = go-app-container

help:
	@echo "Perintah yang tersedia:"
	@echo "  make test      - Jalankan Go Unit Tests via Docker"
	@echo "  make build     - Build Docker image (v1.0.0)"
	@echo "  make run-v1    - Kompilasi & jalankan container v1.0.0 (Hotfix Mount)"
	@echo "  make hotfix-v2 - Swap binary ke v1.0.1 tanpa rebuild image"
	@echo "  make clean     - Hentikan dan hapus container"

test:
	docker run --rm -v "$$(pwd):/app" -w /app golang:1.22-alpine go test -v ./...

build:
	docker build --build-arg VERSION=$(VERSION_V1) -t $(IMAGE_NAME):$(VERSION_V1) .

run-v1:
	mkdir -p bin
	docker run --rm -v "$$(pwd):/app" -w /app golang:1.22-alpine sh -c "CGO_ENABLED=0 GOOS=linux go build -ldflags='-X main.version=$(VERSION_V1)' -o ./bin/app main.go"
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true
	docker run -d --name $(CONTAINER_NAME) -p 8080:8080 --restart always -v "$$(pwd)/bin/app:/app/app" $(IMAGE_NAME):$(VERSION_V1)

hotfix-v2:
	docker run --rm -v "$$(pwd):/app" -w /app golang:1.22-alpine sh -c "CGO_ENABLED=0 GOOS=linux go build -ldflags='-X main.version=$(VERSION_V2)' -o ./bin/app main.go"
	docker restart $(CONTAINER_NAME)

clean:
	docker stop $(CONTAINER_NAME) 2>/dev/null || true
	docker rm $(CONTAINER_NAME) 2>/dev/null || true