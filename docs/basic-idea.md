## The "Student Mode" Concept
When toggled on, the UI shifts to focus on **allowance pacing, peer-to-peer sharing, and extreme cost-saving insights**, adapting seamlessly to lower-end smartphones often used by students.

---

## Updated Functional Requirements (FR) Matrix

### 1. Must Have (MVP Core)

> Critical for basic functionality and immediate student value.

| ID | Feature Name | Functional Description | Category |
| --- | --- | --- | --- |
| **FR-M01** | *Core Authentication* | Sign up, log in, and secure accounts via email/Google/Apple ID and Biometrics. | General |
| **FR-M02** | *AI Auto-Categorization* | Snap a receipt or sync e-wallets; AI parses text (OCR) and auto-categorizes the expense. | Overpower |
| **FR-M03** | **Allowance Pacing Calendar** | Instead of monthly income, students input their weekly/monthly allowance. The app calculates a **"Daily Safe-to-Spend"** limit that dynamically updates. | **Student Mode** |
| **FR-M04** | **Student Discount Aggregator** | Location-based alerts showing nearby student discounts (food, cafes, bookstores, transit) or online tech deals (Notion, GitHub, Spotify). | **Student Mode** |
| **FR-M05** | *Basic Analytics* | Visual pie/bar charts of monthly or weekly spending patterns. | General |

### 2. Should Have (Competitive Edge)

> High-value features that make the app indispensable for group living and academic budgeting.

| ID | Feature Name | Functional Description | Category |
| --- | --- | --- | --- |
| **FR-S01** | *Predictive Burn-Rate Alert* | AI predicts the exact date the student will run out of money based on current velocity. | Overpower |
| **FR-S02** | **Subscription Splitter & Optimizer** | Automatically tracks shared student premium accounts (Netflix, Spotify, Canva). Calculates individual shares and sends automated WhatsApp payment reminders to roommates. | **Student Mode** |
| **FR-S03** | **Academic Goal Budgeting** | Separate sub-wallets specifically locked for academic expenses (tuition fees, textbooks, organizational dues, printing). | **Student Mode** |
| **FR-S04** | **Side-Hustle Income Tracker** | Designed for irregular income (tutoring, freelance, campus jobs). AI projects average monthly income based on fluctuating payouts. | **Student Mode** |
| **FR-S02** | *Split-Bill & Auto-Tagging* | General group bill-splitting with automated reminder prompts. | Overpower |

### 3. Could Have (Delighters & Gamification)

> Advanced features to boost virality, engagement, and retention among Gen-Z.

| ID | Feature Name | Functional Description | Category |
| --- | --- | --- | --- |
| **FR-C01** | **"Survival Mode" Gamification** | When the budget drops below a critical threshold, the app triggers a humorous "Survival Mode." The UI changes, recommending ultra-budget meals or free campus events with complimentary food. | **Student Mode** |
| **FR-C02** | *Financial Avatar & Persona* | A visual character that reacts (happy/crying) in real-time based on the user's financial health. | Overpower |
| **FR-C03** | **Campus Org Treasury Mode** | A micro-ledger mode for student clubs or committee projects to manage event budgets transparently with multi-user viewing access. | **Student Mode** |
| **FR-C04** | *What-If Lifestyle Simulator* | Simulates the long-term impact of upgrading lifestyle choices (e.g., buying a scooter vs. using public transit). | Overpower |

---

## Updated Non-Functional Requirements (NFR)

To ensure this app works flawlessly for students who might not always have the latest flagship phones or unlimited 5G data:

* **NFR-PERF-01 (Device Optimization):** The application package size (*APK/App Store download size*) must be under 40MB to accommodate student devices with limited storage. RAM usage must not exceed 200MB during active background tracking.
* **NFR-PERF-02 (Offline Capability):** Students must be able to log expenses manually and queue receipt uploads while offline (e.g., in campus basements with poor cellular signal). Data will sync automatically once an active connection is detected.
* **NFR-SEC-01 (Data Privacy & Encryption):** All data transfers must utilize TLS 1.3 encryption. Financial data stored on the device must be encrypted using AES-256.
* **NFR-UX-01 (Accessibility & Simplicity):** The Student Mode toggle must be accessible directly from the profile setting or home screen with a single tap, transforming the UI into a more vibrant, Gen-Z-friendly aesthetic.