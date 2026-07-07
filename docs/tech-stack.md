# Project Tech Stack Configuration & Guidelines

This document serves as the absolute ground-truth architectural blueprint for the AI Coding Agent. Every line of code generated for this project must strictly comply with the language choices, design patterns, and engineering constraints defined below.



---

## 1. Architectural Overview

The application uses a separated client-server architecture designed for high performance, minimal memory footprints on lower-end devices, and reliable offline-first processing.

[ Mobile App ] (Flutter/Dart)
         │
         ▼ (HTTPS / JSON + Clerk Auth JWT)
   [ Backend API ] (Go/Golang)
         │
         ▼ (SQL via Drizzle ORM / Node Migration Engine)



---

## 2. Component Specifications

### 📱 Frontend: Mobile Client
*   **Framework:** Flutter (Dart 3.x)
*   **Target Platforms:** Android & iOS (Mobile-focused, optimized for SDK 24+ / iOS 13+)
*   **State Management:** Riverpod or BLoC (Maintain clean separation of UI and business logic)
*   **Local Storage (Offline Queue):** Hive or Isar Database (Fast NoSQL local caching for cash logs and offline operations)
*   **Design Pattern:** Clean Architecture (UI Layer -> Domain/UseCases -> Data/Repository Layer)

### ⚙️ Backend: API Engine
*   **Language:** Go (Golang 1.26+)
*   **Web Framework:** Fiber or Echo (Highly performant, lightweight HTTP routers)
*   **Architecture Pattern:** Idiomatic Go Domain-Driven Design (Handlers -> Services -> Repositories)
*   **Authentication:** Clerk Go SDK (JWT Verification from incoming authorization headers)
*   **Database Migrations & Mapping:** Drizzle ORM (via a minimal Node/TypeScript worker environment exclusively for running migrations)
*   **Database Client (Runtime):** `pgx/v5` native PostgreSQL driver utilized directly inside Go repositories for absolute query performance and compatibility with Drizzle-generated schemas.

### 🗄️ Database Layer
*   **Engine:** PostgreSQL 16+
*   **Data Models:** Synchronized strictly with the `student-finance-radical-teardown.md` specification (Ghost Debt Ledger, FOMO Fund, Stealth Ledger, Academic Vault, Hustle Mirror).
*   **Optimization Constraints:** Heavy reliance on Materialized Views for asynchronous aggregate calculations and GIN indexes for highly nested JSONB tracking.

### 🚀 DevOps & Deployment
*   **Authentication Gateway:** Clerk (Third-party managed user authentication, session tokens, and identity management).
*   **Containerization:** Multi-stage Dockerfiles (Alpine-based minimal runtime images for Go binaries, ensuring images remain < 50MB).
*   **Environment Strategy:** Twelve-Factor App compliance. All secrets (Clerk API Keys, Database URLs) injected purely via runtime environment variables.



---

## 3. Strict Coding Conventions for AI Agents

### When Writing Go (Backend)
1.  **Error Handling:** Never swallow errors. Always check `if err != nil` and return explicitly wrapped errors up the chain.
2.  **Concurrency:** Use Goroutines and Channels strictly where necessary (e.g., asynchronous webhooks or logging tasks). Avoid race conditions by employing mutexes or atomic operations for shared memory state.
3.  **Zero Allocation Mindset:** Prefer passing arrays/slices by pointer where performant, and leverage raw database scans through `pgx` to parse table rows quickly.

### When Writing Flutter/Dart (Frontend)
1.  **Null Safety:** Enforce strict sound null safety. Never use the `!` assertion operator blindly; always handle null variants elegantly.
2.  **Offline-First Handling:** All repository classes interacting with remote REST endpoints must contain fallback mechanisms to save to the local Hive/Isar cache if a network mutation fails.
3.  **UI Performance:** Avoid deeply nested layout trees. Use `const` constructors aggressively to minimize element re-renders.

### When Modifying the Database
1.  **Drizzle Ground Truth:** Never write raw `ALTER TABLE` scripts straight to the database. All table alterations must modify the TypeScript definitions file so Drizzle can automatically generate migration artifacts.