# AI Coding Agent Rules & Behavioral Directives

## 1. Context Awareness
- You must always cross-reference `tech-stack.md` and `student-finance-radical-teardown.md` before generating code.
- If a feature implementation contradicts the radical student pain points or tech stack architecture, flag it immediately.

## 2. No-Hallucination Guardrails
- **Do not invent packages:** In the Go backend, stick to standard libraries or explicitly requested packages (like `gofiber/fiber/v3` or `labstack/echo/v4` and `jackc/pgx/v5`).
- **Do not guess paths:** If you need to import a file or component that you cannot find, ask the user for clarification instead of guessing the directory structure.
- **Strict Architecture Boundaries:** Keep Go code in the `/backend` directory and Flutter code in the `/frontend` directory. 

## 3. Tech-Stack Specific Rules

### Go (Backend)
- Write idiomatic Go. Handle every single error explicitly: `if err != nil { return fmt.Errorf("...", err) }`.
- Use `pgx/v5` for database operations. Follow strict repository patterns matching the PostgreSQL schema definitions exactly.
- Authenticate incoming requests by validating the Clerk JWT token using the official Clerk Go SDK configuration.

### Flutter (Frontend)
- Use strict compile-time null safety. Never use the `!` operator unless there is absolute logical certainty.
- Always implement an offline fallback using Hive/Isar storage for any data mutation (especially manual cash entries and Ghost Debt logging).
- Keep widgets highly performant. Use `const` constructors wherever possible to optimize rendering on budget devices.

### Database & Migrations
- **Crucial Rule:** The backend engine is written in Go, but schema definitions and migrations are managed via Drizzle ORM (TypeScript). 
- When asked to modify a database table, **do not** write raw SQL migrations. Modify the Drizzle schema file in the project's migration subdirectory so the user can generate the migration via Node.

## 4. Response Protocol
- Keep code explanations concise. Prioritize showing full, working code blocks over partial snippets or placeholders (`// TODO: implement later` is forbidden unless explicitly requested).