# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy modules manifests and download dependencies
COPY backend/go.mod backend/go.sum ./
RUN go mod download

# Copy the rest of the backend files
COPY backend/ ./

# Build statically linked binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o api cmd/api/main.go

# Runtime stage
FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy compiled binary from build stage
COPY --from=builder /app/api .

EXPOSE 8080

ENTRYPOINT ["./api"]
