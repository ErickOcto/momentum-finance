# Development Workflow & GitHub Issue Management

This document defines the branching, ticketing, and Pull Request (PR) workflow for this project. The AI Coding Agent must follow this lifecycle for every feature, bug fix, or database migration task.

---

## 1. Branching Strategy

The repository follows a modified Feature Branching model. Direct commits to `main` are strictly forbidden.

*   `main` — Production-ready code. Always stable, compiling, and passing all tests.
*   `feature/issue-[number]-[short-description]` — Development branch for new features.
*   `bugfix/issue-[number]-[short-description]` — Development branch for bug fixes.
*   `db/issue-[number]-[short-description]` — Dedicated branch for Drizzle schema changes and migrations.

---

## 2. The Task Lifecycle (Issue to PR)

Every engineering task must progress through these exact four phases:
[ Phase 1: Issue Discovery ] ──> [ Phase 2: Isolated Branching ]
│
[ Phase 4: Merge & Reconcile ] <── [ Phase 3: PR & Compliance Checks ]


### Phase 1: Issue Scoping & Definition
Before writing code, the AI Agent or the user must define the scope inside a GitHub Issue. The issue description must include:
1.  **Objective:** What specific pain point or feature from `student-finance-radical-teardown.md` is being addressed.
2.  **Acceptance Criteria (AC):** A checklist of functional realities that must pass for this ticket to be considered done.
3.  **Architectural Impact:** Explicit list of files that will be created or mutated.

### Phase 2: Isolated Branching
Once an issue is assigned (e.g., `#12 Implement Ghost Debt API`), the AI Agent must:
1.  Checkout to the `main` branch and pull the latest changes.
2.  Create and switch to a new isolated branch: `git checkout -b feature/issue-12-ghost-debt-api`.

### Phase 3: Pull Request Generation
When the Acceptance Criteria are met, the AI Agent must generate a Pull Request from the feature branch into `main`. The PR template must contain:
*   **Description:** Clear explanation of *how* the feature was implemented.
*   **Closes Link:** Must contain `Closes #12` so GitHub automatically resolves the tracking issue upon merging.
*   **Breaking Changes:** Explicitly state if database schemas were mutated or APIs broken.
*   **Verification Steps:** Command-line steps or test scripts to prove the code works.

### Phase 4: Merge & Reconcile
*   Code review is conducted. 
*   Once approved, the branch is merged into `main` via a **Squash and Merge** to keep the commit history pristine.
*   The local and remote feature branches are deleted.

---

## 3. Strict Rules for AI Agent Task Execution

1.  **One Task at a Time:** Do not attempt to solve multiple GitHub Issues in a single branch or prompt session. Focus strictly on the assigned Issue context.
2.  **No Ghost Files:** Do not leave uncommitted scratch files or temporary scripts in the working directory when submitting a PR.
3.  **Atomic Commits:** Make small, logical commits within your feature branch. Commit messages must be structured as: `feat(#12): implement net-positions endpoint` or `fix(#4): resolve null pointer on Isar sync`.