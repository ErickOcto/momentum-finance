# Momentum Finance - Product Requirements Document (PRD)
## Version 1.0 (MVP)

---

## 1. Executive Summary & Vision

Momentum Finance is a Gen-Z student finance app that abandons guilt-driven traditional budgeting in favor of reality-based cash flow tracking. The app acknowledges the messy reality of student finances: irregular allowance injections, high cash usage, informal social debt, FOMO spending, and parental surveillance anxiety. 

**MVP Vision (The Hybrid Approach):**
Version 1.0 will ship the complete Hybrid feature set. It combines the foundational requirements of a modern finance app (multi-wallet, OCR scanning) with the 5 "Radical" student-centric features designed to build immediate retention and address unarticulated psychological pain points.

---

## 2. Core Dashboard: Dynamic Cash-Flow Engine

The app rejects the standard 30-day calendar budget. Because student income is highly irregular (late allowances, random gifts, side hustles), the dashboard uses an event-driven **Dynamic Cash-Flow** model.

**The "True Safe-to-Spend" Metric:**
Instead of simple `(Income - Expenses)`, the dashboard explicitly calculates:
`Available Liquidity - (Academic Vault Reserves + FOMO Fund Envelope) = True Safe-to-Spend`

This gives the student agency without anxiety, showing exactly what is safe to spend today without jeopardizing upcoming institutional obligations or their dedicated social budget.

---

## 3. Functional Requirements (FR)

### 3.1. Foundation (The Baseline)
| ID | Feature | Description |
|---|---|---|
| **FR-F01** | Core Auth & Security | Login via Email, Google, Apple ID. Biometric/PIN protection. |
| **FR-F02** | Multi-Wallet Setup | Support for Cash, Bank Accounts, and E-Wallets. |
| **FR-F03** | AI Receipt Scanner (Public) | Users can snap receipts for auto-categorization. **MVP Architecture:** Powered by a Third-Party API (e.g., Google Vision/OpenAI) for speed to market. |
| **FR-F04** | Ultra-Fast Cash Log | Frictionless, sub-5-second manual logging for cash transactions (warung, angkot). |

### 3.2. The Radical Suite (The "Overpower" Tier)
These 5 features form the core differentiation of the MVP.

| ID | Feature | Description |
|---|---|---|
| **FR-R01** | **Ghost Debt Ledger** | A unilateral, private visual graph of informal micro-debts with friends. Tracks net positions without requiring the friend to have the app. Features low-stakes internal nudges and user-defined auto-forgiveness thresholds. |
| **FR-R02** | **FOMO Fund** | An intentional, pre-committed envelope for social spending. Before a discretionary spend is logged, it triggers a "BLESS or BLOCK" gate, reframing social spending from impulse/shame to intentional budget allocation. |
| **FR-R03** | **Stealth Ledger** | A PIN-separated, cryptographically isolated shadow ledger for financial privacy from parents. Transactions here do not appear on the main dashboard. **MVP Architecture:** Kept strictly manual/rule-based (no third-party AI) to guarantee absolute data privacy. |
| **FR-R04** | **Academic Vault** | A university-aware financial calendar. Pre-loads known academic obligations (UKT, KKN, thesis printing) based on the user's institution and auto-reserves funds months in advance to prevent "financial ambushes". |
| **FR-R05** | **Hustle Mirror** | A P&L dashboard for side-hustles (freelance, dropship, tutoring). Tracks revenue, direct costs, and *time invested* to show the true effective hourly rate of the hustle. |

---

## 4. Technical Architecture & Constraints (NFRs)

### 4.1. AI & Machine Learning Strategy
* **Public Transactions:** Use a Third-Party API for OCR and text parsing to accelerate MVP development.
* **Stealth Transactions:** Because Stealth data cannot be sent to a third-party server, AI features (including third-party APIs and local heavy ML models like TF Lite) are completely disabled for Stealth in MVP to safeguard package size limits. Stealth logging will rely strictly on manual input and lightweight, local regex/keyword-matching heuristics (e.g., matching text patterns like "makan" or "kopi" locally on-device).

### 4.2. Security & Privacy
* **NFR-SEC-01 (Stealth Encryption):** The Stealth Ledger must use client-side encryption (AES-256). The encryption key is derived locally from the Stealth PIN. The backend database must only receive and store ciphertext for these records.
* **NFR-SEC-02 (Transport):** TLS 1.3 for all API communication.

### 4.3. Performance & Usability
* **NFR-PERF-01 (Size Constraints):** The application package size must be under 40MB to accommodate lower-end student devices.
* **NFR-PERF-02 (Offline Capability):** Users must be able to execute quick cash logs, Ghost Debt entries, and Stealth Ledger manual entries while offline. The local Isar/Hive database will hold encrypted payload queues and sync background network mutations to the PostgreSQL backend via idempotent Go HTTP endpoints upon reconnection.
* **NFR-UX-01 (Logging Speed):** The critical path for manual logging must take no more than 2 taps from the home screen.
