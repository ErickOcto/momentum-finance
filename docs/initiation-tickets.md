# Project Initiation Tickets

This document defines the set of GitHub Issues required to bootstrap the **Momentum Finance** project based on the architectural blueprint in [tech-stack.md](file:///Users/frederickoctoramadhan/development/gtihub.nosync/momentum-finance/docs/tech-stack.md) and the workflow requirements in [workflow.md](file:///Users/frederickoctoramadhan/development/gtihub.nosync/momentum-finance/docs/workflow.md).

---

## Issue #1: Setup Backend Go REST API Skeleton (Fiber/Echo)

### Objective
Establish the foundational Go backend structure using a lightweight HTTP router (Fiber or Echo) and implement the Clean/DDD-lite directory layout (Handlers -> Services -> Repositories).

### Acceptance Criteria
- [ ] Initialize Go module (`go mod init momentum-backend`).
- [ ] Set up HTTP server router (Fiber or Echo) listening on a configurable port via env variable.
- [ ] Implement DDD directory structure:
  - `/cmd/api` (entrypoint `main.go`)
  - `/internal/handlers` (HTTP handlers)
  - `/internal/services` (Business logic)
  - `/internal/repositories` (Database / pgx persistence)
  - `/internal/config` (Env variables loading)
- [ ] Add basic health check endpoint `/health` returning JSON `{"status": "ok"}`.
- [ ] Integrate a structured logger (e.g., standard library `slog` or `logrus`).
- [ ] Implement graceful shutdown handling OS signals (SIGINT, SIGTERM).

### Architectural Impact
- `/go.mod` [NEW]
- `/go.sum` [NEW]
- `/cmd/api/main.go` [NEW]
- `/internal/config/config.go` [NEW]
- `/internal/handlers/health.go` [NEW]

---

## Issue #2: Setup Database Engine & Drizzle ORM Migration Workflow

### Objective
Provision the database environment using PostgreSQL 16+ and set up the minimal Node/TypeScript environment to manage schema definitions and database migrations via Drizzle ORM.

### Acceptance Criteria
- [ ] Create a `/db` directory for the database migration worker.
- [ ] Initialize a Node project (`package.json`, `tsconfig.json`) in `/db`.
- [ ] Configure Drizzle ORM with dependencies (`drizzle-orm`, `drizzle-kit`, `tsx`).
- [ ] Define initial base schemas in TypeScript matching the MVP components:
  - Users (Clerk sync details)
  - Wallets / Cash Logs
  - Ghost Debt Ledger
  - Stealth Ledger (ciphertext storage only)
- [ ] Configure `drizzle.config.ts` for migration generation and execution.
- [ ] Verify `npx drizzle-kit generate` and `npx drizzle-kit migrate` commands work against a local Postgres database.

### Architectural Impact
- `/db/package.json` [NEW]
- `/db/tsconfig.json` [NEW]
- `/db/drizzle.config.ts` [NEW]
- `/db/src/schema.ts` [NEW]
- `/db/src/migrate.ts` [NEW]

---

## Issue #3: Integrate PGX Database Client & Repository Layer in Go Backend

### Objective
Integrate the `pgx/v5` driver in the Go backend to execute runtime queries against the Drizzle-managed PostgreSQL database.

### Acceptance Criteria
- [ ] Add `pgx/v5` dependency to Go backend.
- [ ] Create a reusable database connection pool helper in `/internal/repositories`.
- [ ] Parse `DATABASE_URL` env variable for connection pool initialization.
- [ ] Implement a base repository pattern (e.g., a dummy transaction repository or user repository) executing raw SQL queries via `pgx`.
- [ ] Add db connection validation check to the `/health` endpoint to verify db readiness before returning success.

### Architectural Impact
- `/internal/repositories/db.go` [NEW]
- `/internal/handlers/health.go` [MODIFY]

---

## Issue #4: Setup Clerk Auth Middleware in Go Backend

### Objective
Secure API routes by verifying Clerk JWT session tokens passed in the Authorization header.

### Acceptance Criteria
- [ ] Install Clerk Go SDK or build a lightweight JWT validation middleware using the Clerk JWKS endpoint.
- [ ] Retrieve Clerk JWKS keys at backend initialization and cache them.
- [ ] Create an auth middleware that:
  - Extracts the Bearer token from the `Authorization` header.
  - Validates the signature, audience, issuer, and expiration of the token.
  - Injects the authenticated User ID into the request context.
  - Returns `401 Unauthorized` for missing/invalid tokens.
- [ ] Mount the auth middleware to a test protected endpoint `/api/v1/protected`.

### Architectural Impact
- `/internal/middleware/auth.go` [NEW]
- `/internal/handlers/protected.go` [NEW]
- `/cmd/api/main.go` [MODIFY]

---

## Issue #5: Setup Flutter Mobile Client Skeleton (Clean Architecture + Riverpod/BLoC)

### Objective
Initialize the Flutter client application adhering to Clean Architecture principles, structuring folders for UI, Domain, and Data layers.

### Acceptance Criteria
- [ ] Create Flutter workspace using Dart 3.x (`flutter create client`).
- [ ] Clean up default template and structure project:
  - `/lib/main.dart`
  - `/lib/core` (constants, themes, errors, network client)
  - `/lib/features` (segmented by feature)
    - `/lib/features/[feature]/presentation` (UI widgets, controllers/state managers)
    - `/lib/features/[feature]/domain` (Entities, Use Cases)
    - `/lib/features/[feature]/data` (Models, Repositories, Data Sources)
- [ ] Configure chosen State Management (Riverpod or BLoC package) in `pubspec.yaml`.
- [ ] Add HTTP client/wrapper (e.g., `dio` or standard `http`) with global exception handling.
- [ ] Verify clean compilation and successful build on target platforms (Android/iOS).

### Architectural Impact
- `/client/pubspec.yaml` [NEW]
- `/client/lib/main.dart` [NEW]
- `/client/lib/core/` [NEW]
- `/client/lib/features/` [NEW]

---

## Issue #6: Initialize Hive/Isar Offline Storage Layer in Flutter Client

### Objective
Integrate Hive or Isar database into the Flutter client to support offline local caching of transaction queues and ledger states.

### Acceptance Criteria
- [ ] Add `hive` (or `isar`) and generator dependencies to `client/pubspec.yaml`.
- [ ] Initialize Hive/Isar database during client boot sequence in `main.dart`.
- [ ] Build a generic Offline Queue service container capable of storing JSON-serialized payloads locally when offline.
- [ ] Define initial Hive/Isar schemas or adapters for local storage of Cash Logs.
- [ ] Write unit/widget tests verifying local read/write capabilities are functional.

### Architectural Impact
- `/client/pubspec.yaml` [MODIFY]
- `/client/lib/core/storage/local_storage.dart` [NEW]
- `/client/lib/main.dart` [MODIFY]

---

## Issue #7: Setup Local Development Environment & DevOps Pipeline (Docker Compose)

### Objective
Configure local orchestration using Docker Compose to stand up the PostgreSQL 16 database and define minimal Multi-stage Dockerfiles for local execution and staging builds.

### Acceptance Criteria
- [ ] Write `docker-compose.yml` defining:
  - `postgres` (using `postgres:16-alpine` on port 5432)
  - Adminer/PgAdmin (optional, for easy database visualization)
- [ ] Write a multi-stage `Dockerfile` for the Go backend (Builder image -> Alpine runtime image under 50MB).
- [ ] Create environment configuration templates (`.env.example`).
- [ ] Verify that running `docker compose up` starts up the database and backend correctly.

### Architectural Impact
- `/docker-compose.yml` [NEW]
- `/Dockerfile` [NEW]
- `/.env.example` [NEW]
