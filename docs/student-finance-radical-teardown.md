# The Radical Teardown & Feature Manifesto
## A Brutally Honest PM Critique + Architecture Blueprint for a Gen-Z Student Finance App

> **Document Status:** Internal Strategic Review  
> **Version:** 1.0  
> **Audience:** Founding PM, Lead Architect, Design Lead

---

## [1] THE BRUTAL GRILL — 5 Harsh Truths Your Current PRD Ignores

---

### Harsh Truth #1: The Shame Loop Destroys Your Retention Before Week 2

Your current PRD is built on a silent, fatal assumption: that students *want* to confront their spending data. They don't. When a student blows their food budget on bubble tea and late-night grab food runs, they *know* it. They don't need an app to confirm it with a cheerful red donut chart.

The entire behavioral loop your app depends on — **Log → See Data → Feel Accountable → Change Behavior** — breaks catastrophically at step 3 for this demographic. Gen-Z doesn't respond to dashboard guilt trips; they disengage. They'll open the app, see they're 40% over budget in week 2, feel a spike of shame, and then **not open it again for 11 days**.

Your "AI Auto-Categorization" (FR-M02/FR-M04) is only valuable if the user stays in the app long enough for the AI to matter. Standard finance apps report D30 retention rates under 15% for users 18–24. Your current feature set does nothing structurally different to change this number.

**What you're missing:** The app needs a non-judgmental, even *humorous* emotional layer that destigmatizes seeing your own financial wreckage. Confrontation without compassion is just surveillance.

---

### Harsh Truth #2: Your Budgeting Model Is Built for a Salaried Adult, Not an Allowance-Dependent Student

Your "Allowance Pacing Calendar" (FR-M03) is a step in the right direction, but it still models allowance like clockwork income. Indonesian student financial reality is far messier:

- Allowances arrive **irregularly** — parents say "nanti ya" and send it 4 days late
- They're supplemented by **random injections**: lebaran money, birthday transfers, sudden parental sympathy after a sad phone call
- They're **partially absorbed** by shared family costs (adik's school fees, ongkos pulang, etc.)
- They're **simultaneously eroded** by Shopee Paylater, Kredivo, and GoPaylater installments that auto-debit on dates the student doesn't fully track

Monthly budgeting assumes a flat input line. Student financial reality is a jagged, unpredictable waveform. Every feature you've built — burn-rate prediction, daily safe-to-spend — is a function of income stability that doesn't actually exist for your user. Your model will produce wildly inaccurate predictions and students will distrust and abandon it.

**What you're missing:** The income model needs a fundamentally different architecture: **event-driven, injection-based cash flow tracking** rather than calendar-based budgeting.

---

### Harsh Truth #3: Your AI Categorization Is Running on Less Than Half the Data

Here's the brutal math: In Indonesia, a significant share of student spending — estimates for urban Indonesian student populations suggest 35–55% — is cash. Warung makan depan kampus. Gorengan. Angkot. Ojek pangkalan. Jajan keliling. These transactions leave *no digital trace*. No receipt, no SMS, no QR code.

Your "AI Auto-Categorization & Receipt Scanner" (FR-M04) is doing OCR on struk Indomaret and parsing GoPay histories — great. But it's building a financial picture with a structural hole the size of half the user's actual life. You're not building a finance tracker; you're building a **partial finance tracker** that will be confidently wrong about the user's true financial state.

The app will tell a student their food budget is 60% consumed when it's actually 110% consumed, because the cash warung meals don't exist in the system. When the student trusts the app and the month ends in catastrophe anyway, they blame the app — not themselves — and churn.

**What you're missing:** A frictionless, one-tap "quick cash log" that costs the user less than 4 seconds (no category selection, no note — just amount and a smart AI guess of context based on time, location, and recent patterns). Cash logging needs to be as fast as tapping a notification, not a UX flow.

---

### Harsh Truth #4: Your Split-Bill Feature Ignores the Social Cost of Asking for Money Back

"Subscription Splitter" (FR-S02) sends automated WhatsApp payment reminders to roommates. Sounds efficient. Here's why it gets turned off within 2 weeks:

Indonesian campus social dynamics (and Gen-Z social dynamics broadly) operate under an unspoken rule: **debt collection among friends is social aggression, not financial hygiene**. Sending a WhatsApp message saying "kamu belum bayar Rp35.000 untuk Spotify bulan ini" — even automated — creates a power dynamic that feels accusatory. The friend receiving it feels embarrassed. The friend sending it feels awkward for having set up the automation. The feature becomes a source of friction in the friendship, not financial clarity.

You can't solve this with better UX copy. The social psychology is structural. Any feature that makes money-owed *explicit and public between friends* will face adoption rejection in this cultural context.

**What you're missing:** Debt collection needs to be reframed as *ambient, low-stakes, and funny* — not transactional. The mechanism needs social camouflage.

---

### Harsh Truth #5: Burn-Rate Prediction Without Prescription Is Just a Better Anxiety Machine

"FR-S01: Predictive Burn-Rate Alert" — "You will run out of money in 8 days." Okay. So what? What is the student supposed to *do* with that information when:

- They have a mandatory birthday dinner for their best friend on day 5
- Their campus org meeting on day 6 expects everyone to chip in for snacks
- They've already half-committed to a road trip on day 7

Prediction without an **actionable escape route** is pure psychological distress delivered as a push notification. Students will quickly learn that opening your app results in bad news they can't act on, and they'll stop opening it. This is not a notification design problem — it's a product philosophy problem.

Standard finance apps confuse **awareness** with **agency**. Awareness of a problem you cannot solve is called anxiety. Your app needs to deliver prediction *and* prescription simultaneously: not just "you'll be broke in 8 days" but "here's the 3 spending decisions in the next 4 days that would get you to day 15."

---

## [2] UNCONVENTIONAL STUDENT PAIN POINTS — The 5 Raw Truths No App Addresses

---

### Pain Point #1: The Distributed Informal Debt Web

**"Pinjam 20k bentar ya"** — said to 12 different people in a semester.

Students operate in a constant, invisible web of micro-debt. The scale of this is staggering when you actually map it: informal loans to/from friends (often in the Rp10k–Rp200k range), Shopee Paylater balances, Kredivo installments, GoPay Paylater, perhaps a family loan, maybe a koperasi campus credit. Each debt is small. Collectively, they can add up to 1–3 months of allowance.

The pain is multi-layered:
- **Cognitive load:** Remembering who owes you what across 8 different people is mentally exhausting
- **Social cost:** Asking for repayment damages friendships; most students just silently absorb the loss
- **Visibility failure:** No single view of total informal debt exposure exists anywhere
- **Escalation risk:** Small unpaid debts compound into borrowing from paylater to cover paylater, the first stage of a debt spiral

The deeper insight: **students know this is a problem but accept it as a cost of being social**. An app that addresses this without introducing social awkwardness would be genuinely transformative.

---

### Pain Point #2: The FOMO Tax — Social Spending as Social Infrastructure

Going to the overpriced cafe isn't irrational behavior. It's **social infrastructure investment**.

Indonesian campus culture is highly social-group-centric. Being in a circle (geng, kelompok), being seen at certain places, wearing certain things, attending certain events — these are not luxuries. They are **social capital expenditures** that translate into future opportunities: introductions, project collaborations, romantic prospects, emotional support networks.

Standard finance apps moralize about Starbucks spending. Gen-Z students don't need moral lectures — they need a framework that says: "Your social spending is legitimate. Here's how to make it intentional rather than reactive, so you don't have to choose between your social life and your survival."

The pain point is the **guilt** attached to this spending, not the spending itself. Students feel shame tracking it (because the app will judge them) and shame *not* tracking it (because they know they're being chaotic). The app needs to give social spending a legitimate home.

---

### Pain Point #3: Parental Financial Surveillance Anxiety

Many Indonesian students have at least one of the following situations:
- Their bank account was opened by their parents and the parent still has access or receives SMS alerts
- Their e-wallet is linked to a family account or group
- Their parents call to ask "uangnya habis buat apa?" when they send money unexpectedly
- They share a phone plan or Google account with parents who could potentially see app data

The result: students **either don't use finance apps at all**, or they maintain two parallel financial realities — one "sanitized" version for parental inspection and one actual version that they track in their heads. This anxiety is real, widespread, and completely unaddressed by any finance app currently in the market.

The actual need isn't to hide criminal activity — it's to have **personal financial privacy** from family during a developmental life stage when students are learning to be financially autonomous. This is a healthy and legitimate psychological need that deserves a product solution.

---

### Pain Point #4: The Academic Financial Ambush

Campus financial life has a hidden calendar that blindsides students every semester:

| Event | Typical Cost (IDR) | Notice Given |
|---|---|---|
| UKT (Semester Fee) | Rp2.4M – Rp12M+ | 2–4 weeks |
| KKN Living Expenses | Rp1.5M – Rp4M | 1–2 months |
| Skripsi Printing + Binding | Rp200k – Rp500k | Days |
| Wisuda Package (Photos, Toga, Etc.) | Rp500k – Rp2.5M | 1 month |
| Himpunan/BEM Organizational Dues | Rp100k – Rp500k/semester | Varies |
| Lab Reports, KKL, Academic Trips | Rp200k – Rp1M | 1–3 weeks |

These events are **entirely predictable in aggregate** (they happen every semester at roughly the same academic calendar points) but arrive as psychological shocks because students have no system to anticipate them. A student can be perfectly on-budget for 3 months and then get completely obliterated in week 1 of month 4 by a UKT deadline.

No finance app currently integrates university-specific academic calendars with financial planning. This is a massive, unaddressed gap that represents genuine product defensibility through institutional data partnerships.

---

### Pain Point #5: The Side-Hustle Income Chaos

The side-hustle economy among Indonesian university students is large and growing: freelance design on Fiverr/99designs/direct, content creation, campus tutoring (les privat), reseller/dropship, event organizer committees, food reselling. This income is:

- **Irregular:** Payment arrives when clients feel like it
- **Multi-channel:** Cash, transfer, GoPay, DANA, OVO, sometimes barter
- **Untracked by cost:** A student who makes Rp500k from a design project doesn't factor in the 8 hours of time, the software subscription cost, or the electricity bill
- **Tax-invisible:** Almost no student is aware of UMKM tax obligations or PKP thresholds
- **Unprofitable in practice:** Many students are effectively charging below minimum wage once costs are accounted for

The deeper problem: without P&L visibility, students can't distinguish between a hustle that's actually generating value and one that's just keeping them busy and broke. They feel "successful" because money came in, while their actual financial position worsened.

---

## [3] THE RADICAL FEATURE SET — 5 Hyper-Differentiated "Overpower" Features

---

### Feature 1: Ghost Debt Ledger™ — The Social IOU Graph

**Pain Point Addressed:** Distributed Informal Debt Web  
**Core Concept:** A private, visual graph of all informal debt relationships — amounts owed and amounts receivable — with zero social friction, context-aware nudges, and mutual visibility on opt-in consent.

**How It Works:**

1. User logs an informal debt ("I loaned Andi Rp50k for makan siang") in under 5 seconds — just amount, name, optional emoji tag
2. The system maintains a running **net position per person** (you're +Rp50k with Andi, -Rp75k with Reza)
3. A visual web graph shows the user's debt ecosystem at a glance
4. If both parties are on the app and mutually consent, debts **auto-sync and reconcile**
5. Nudges are sent via the app itself (not WhatsApp) in a low-stakes, humorous format: *"Reminder: Andi still owes you Rp50k — it's been 14 days. Maybe drop a hint 😅"*
6. Users can set "forgiveness thresholds" — debts under Rp20k auto-forgive after 30 days, keeping friendships intact

**Why It's Differentiated:** Every split-bill app (Splitwise, etc.) requires the other person to also be on the platform and explicitly accept a debt. Ghost Debt Ledger is **unilateral and private first** — you track your side without requiring friend participation. The social friction is eliminated because the nudge mechanism is internal and opt-in.

---

### Feature 2: FOMO Fund™ — The Intentional Flex Budget

**Pain Point Addressed:** The FOMO Tax / Social Spending as Social Infrastructure  
**Core Concept:** A dedicated, pre-committed social spending envelope that reframes FOMO spending from shame-driven impulse to intentional budget allocation — with a built-in "BLESS or BLOCK" micro-decision gate before discretionary social spending.

**How It Works:**

1. During onboarding, the user allocates a specific "Flex Fund" from their monthly allowance (suggested: 15–20% of total budget). This is their sanctioned social life budget
2. When the app detects a potential social/discretionary transaction (via merchant category, time of day, location, or manual trigger), it surfaces a **BLESS/BLOCK gate**: a bottom sheet showing Flex Fund balance, impact of this spend, and days remaining in the month
3. The user can choose:
   - **BLESS IT** → Spend proceeds, logged as intentional flex (no shame)
   - **BLOCK IT** → Spend is paused, app suggests alternatives (nearby cheaper option, postpone to next month when budget resets)
   - **FLEX FORWARD** → Borrow from next month's FOMO Fund (tracked explicitly as a "pre-commitment," not debt)
4. At month end, any unspent Flex Fund rolls forward (not to savings — this is *social capital*, not savings). Students can see their "FOMO Score" — a streak of intentional vs. reactive spending decisions

**Why It's Differentiated:** This is the only finance feature that **legitimizes social spending** rather than treating it as failure. By making it a named, budgeted category with its own vault, the app becomes a *permission slip* for social life rather than a guilt machine. This is the conceptual inversion that standard finance apps miss entirely.

---

### Feature 3: Stealth Ledger™ — Private Financial Mode

**Pain Point Addressed:** Parental Financial Surveillance Anxiety  
**Core Concept:** A PIN-separated, cryptographically isolated financial shadow layer within the app that tracks real spending in full, but surfaces only a curated "public view" in the main dashboard — solving the dual-reality problem without requiring two separate apps.

**How It Works:**

1. User activates Stealth Ledger via a separate PIN (distinct from the main app PIN/biometric)
2. Transactions can be tagged as **Stealth** at logging time or retroactively
3. Stealth transactions are encrypted client-side with the user's Stealth PIN key — the server stores only ciphertext. **Even the app backend cannot read stealth transactions without the PIN**
4. The main dashboard shows the "public view" — clean, shareable, parent-appropriate. The aggregate totals exclude stealth amounts
5. Entering Stealth Mode (via PIN) reveals the full picture: real balances, real categories, true remaining budget
6. A "Show Mode" switch lets the user instantly switch to Public View for over-the-shoulder moments (parent looking at the phone)
7. Stealth analytics run locally on-device — the AI categorization for stealth transactions never leaves the phone unencrypted

**Why It's Differentiated:** No finance app in any market has built an explicit privacy-from-family layer. The closest concept is "hidden categories" in some budgeting apps, which is cosmetic, not cryptographic. This feature has a genuine product moat: it requires trust architecture (client-side encryption, zero-knowledge design) that's hard to replicate quickly. More importantly, it speaks directly to a real, universal student psychological need that competitors are embarrassed to name.

**Important Legal Note:** This must be framed and marketed exclusively as **financial privacy for adult students** — not as a tool to hide illegal activity. The app's ToS should make this explicit. There is no compliance issue with offering privacy features to adult users.

---

### Feature 4: Academic Vault™ — University Financial Calendar & Auto-Reserve Engine

**Pain Point Addressed:** The Academic Financial Ambush  
**Core Concept:** A university-aware financial planning engine that pre-loads all known academic financial obligations based on the user's institution, semester, and year — then automatically reserves funds months in advance, making "financial ambushes" structurally impossible.

**How It Works:**

1. At onboarding, user inputs: university name, current semester, and academic program
2. The system loads a **pre-built academic financial calendar** for that institution (UKT deadlines, KKN season, standard graduation fees, typical org dues) — sourced from institutional partnerships or crowd-sourced + verified data
3. For each upcoming academic financial event, the app creates an **Academic Vault**: a locked sub-wallet with a target amount, deadline, and auto-reserve schedule
4. Each month, a calculated portion of the user's allowance is automatically swept into the relevant vault(s) — the "Daily Safe-to-Spend" calculation already accounts for these sweeps, so the student's operational budget is accurate from day one
5. Vaults are locked by default (require a 24-hour "thaw" to break open early), preventing emergency raid of academic reserves for social spending
6. The student sees their **"Academic Safety Score"** — a percentage showing how covered they are for all upcoming academic obligations
7. Community-contributed data allows students to add institution-specific costs (e.g., "Jurusan Teknik Sipil di UI also charges Rp150k for lab fees in semester 5") that gets surfaced to peers at the same institution

**Why It's Differentiated:** This requires institutional data infrastructure that gives the app a genuine competitive moat. A competitor can copy the feature UI in 2 weeks. They cannot copy 2 years of curated university financial calendar data and 50,000 student data points validating typical costs per institution per semester. This is a **data moat**, not just a feature.

---

### Feature 5: Hustle Mirror™ — Side-Income P&L Dashboard

**Pain Point Addressed:** The Side-Hustle Income Chaos  
**Core Concept:** A project-based income and cost tracking module that gives students a true profitability picture of each side hustle — including their time as a cost — with an effective hourly rate dashboard and tax awareness engine.

**How It Works:**

1. User creates a "Hustle" (e.g., "Freelance Design - Kelas Kreatif Project")
2. For each hustle, they log:
   - **Revenue:** Amount received, date, channel (cash/transfer/e-wallet)
   - **Costs:** Direct costs attributed to the project (software, materials, transport, printing)
   - **Time:** Hours invested (simple start/stop timer or manual input)
3. The app calculates in real-time:
   - **Gross Revenue** vs. **Net Revenue** (after costs)
   - **Effective Hourly Rate:** Net revenue ÷ hours invested
   - **Profitability Trend:** Is this hustle getting more or less profitable over time?
4. An **AI Income Projector** uses historical payout patterns per hustle to project expected income in the next 30/60/90 days — feeding directly into the allowance model as supplemental income
5. A **Tax Awareness Layer** triggers when cumulative annual hustle income approaches UMKM thresholds (Rp500jt annual, Rp4.8M/month) — surfacing educational content, not scary warnings
6. A shareable **"Hustle Report Card"** lets students share sanitized performance data (great for portfolio building or parent reporting)
7. **Barter & In-Kind Income Tracking:** A dedicated flow for logging non-cash compensation (product exchanges, services, exposure deals) that students can decide to value at market rate or zero

**Why It's Differentiated:** Every gig-economy finance feature is designed for Gojek drivers or freelancers with consistent monthly income. This is the first feature designed for the chaotic, multi-channel, time-untracked income reality of a student hustler — including the **psychological dimension**: showing a student that their "successful" hustle is paying them Rp8.000/hour (below UMR) is a revelatory and actionable insight that no other app delivers.

---

## [4] TECHNICAL SCHEMA BLUEPRINT

---

### Schema 1: Ghost Debt Ledger

```sql
-- Core IOU records (unilateral, no counterparty app required)
CREATE TABLE iou_records (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Counterparty can be on-platform or off-platform
    counterparty_user_id    UUID REFERENCES users(id) ON DELETE SET NULL,
    counterparty_alias      VARCHAR(100),           -- display name if off-platform
    counterparty_contact    VARCHAR(50),            -- phone number for potential WA nudge
    
    -- Financial core
    amount          DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    currency        VARCHAR(3) NOT NULL DEFAULT 'IDR',
    direction       VARCHAR(20) NOT NULL CHECK (direction IN ('I_OWE', 'OWED_TO_ME')),
    
    -- Context & metadata
    reason          TEXT,
    context_tags    VARCHAR(50)[],                  -- e.g., {'makan', 'bensin', 'titip'}
    emoji_tag       VARCHAR(10),                    -- quick emotional context
    
    -- Lifecycle
    status          VARCHAR(20) NOT NULL DEFAULT 'OPEN'
                    CHECK (status IN ('OPEN', 'PARTIAL', 'SETTLED', 'FORGIVEN', 'DISPUTED')),
    settled_amount  DECIMAL(15,2) NOT NULL DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    due_date        DATE,
    settled_at      TIMESTAMPTZ,
    
    -- Forgiveness automation
    auto_forgive_after_days     INT DEFAULT NULL,   -- NULL = never auto-forgive
    forgiveness_threshold_idr   DECIMAL(15,2),      -- forgive if amount <= threshold
    
    -- Nudge preferences
    nudge_style     VARCHAR(20) DEFAULT 'SUBTLE'
                    CHECK (nudge_style IN ('SUBTLE', 'HUMOROUS', 'FORMAL', 'NONE')),
    nudge_count     INT NOT NULL DEFAULT 0,
    last_nudge_at   TIMESTAMPTZ,
    next_nudge_at   TIMESTAMPTZ
);

-- Settlement events (partial or full)
CREATE TABLE iou_settlements (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    iou_id      UUID NOT NULL REFERENCES iou_records(id) ON DELETE CASCADE,
    amount      DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    method      VARCHAR(50),    -- 'CASH', 'TRANSFER', 'GOPAY', 'MEAL', 'BARTER'
    note        TEXT,
    settled_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Mutual consent sync (both parties on platform)
CREATE TABLE iou_mutual_links (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    party_a_iou_id      UUID NOT NULL REFERENCES iou_records(id),
    party_b_iou_id      UUID NOT NULL REFERENCES iou_records(id),
    linked_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    consensus_status    VARCHAR(20) DEFAULT 'PENDING'
                        CHECK (consensus_status IN ('PENDING', 'AGREED', 'DISPUTED'))
);

-- Aggregate view per counterparty (materialized for performance)
CREATE MATERIALIZED VIEW iou_net_positions AS
SELECT
    owner_user_id,
    COALESCE(counterparty_user_id::TEXT, counterparty_alias) AS counterparty_key,
    counterparty_alias,
    counterparty_user_id,
    SUM(CASE WHEN direction = 'OWED_TO_ME' THEN amount - settled_amount ELSE 0 END) AS total_receivable,
    SUM(CASE WHEN direction = 'I_OWE'      THEN amount - settled_amount ELSE 0 END) AS total_payable,
    SUM(CASE WHEN direction = 'OWED_TO_ME' THEN amount - settled_amount
             WHEN direction = 'I_OWE'      THEN -(amount - settled_amount) ELSE 0 END) AS net_position
FROM iou_records
WHERE status NOT IN ('SETTLED', 'FORGIVEN')
GROUP BY owner_user_id, counterparty_key, counterparty_alias, counterparty_user_id;
```

**AI/ML Requirements:**

| Requirement | Approach | On-Device Feasibility |
|---|---|---|
| Debt logging from natural language ("pinjam 50k ke Reza buat makan") | Fine-tuned NER model (TensorFlow Lite) to extract amount + name + context | ✅ Yes — 8MB model |
| Smart nudge timing (when is the counterparty most likely to respond?) | Heuristic: nudge on weekday mornings, not past 9PM, not on Fridays. Simple rule-based. | ✅ No ML needed |
| Auto-forgiveness likelihood scoring | Logistic regression on: amount, days elapsed, relationship frequency, past settlement rate | ✅ Lightweight, server-side |
| Graph visualization rendering | D3.js force-directed graph or custom SVG renderer | ✅ Client-side only |

---

### Schema 2: FOMO Fund / Flex Budget

```sql
-- Per-user FOMO Fund configuration
CREATE TABLE fomo_fund_config (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    monthly_allocation      DECIMAL(15,2) NOT NULL,     -- user-set flex budget
    current_balance         DECIMAL(15,2) NOT NULL DEFAULT 0,
    forward_borrowed        DECIMAL(15,2) NOT NULL DEFAULT 0,  -- borrowed from next month
    rollover_enabled        BOOLEAN NOT NULL DEFAULT TRUE,
    reset_day               SMALLINT NOT NULL DEFAULT 1 CHECK (reset_day BETWEEN 1 AND 28),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- BLESS/BLOCK decision log (every gate interaction)
CREATE TABLE fomo_decisions (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                     UUID NOT NULL REFERENCES users(id),
    proposed_amount             DECIMAL(15,2) NOT NULL,
    fund_balance_at_decision    DECIMAL(15,2) NOT NULL,
    decision                    VARCHAR(20) NOT NULL
                                CHECK (decision IN ('BLESSED', 'BLOCKED', 'FORWARDED', 'DISMISSED')),
    forward_amount              DECIMAL(15,2),           -- if FORWARDED
    merchant_name               VARCHAR(200),
    merchant_category           VARCHAR(50),
    
    -- Context snapshot (for behavioral ML training)
    context                     JSONB NOT NULL DEFAULT '{}',
    /*  Example context payload:
        {
          "time_of_day": "22:15",
          "day_of_week": "Friday",
          "location_type": "cafe",
          "social_signal": "group_activity",
          "peer_count_estimate": 4,
          "days_since_last_flex": 3,
          "monthly_flex_consumed_pct": 0.72,
          "days_until_reset": 8
        }
    */
    
    decided_at                  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Monthly FOMO Fund cycle ledger
CREATE TABLE fomo_fund_ledger (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id),
    cycle_month     DATE NOT NULL,                  -- first day of the month
    opening_balance DECIMAL(15,2) NOT NULL DEFAULT 0,
    allocated       DECIMAL(15,2) NOT NULL,
    rolled_in       DECIMAL(15,2) NOT NULL DEFAULT 0,   -- rollover from prior month
    borrowed_in     DECIMAL(15,2) NOT NULL DEFAULT 0,   -- borrowed forward from next month
    spent           DECIMAL(15,2) NOT NULL DEFAULT 0,
    closing_balance DECIMAL(15,2),                      -- null until cycle closes
    fomo_score      DECIMAL(5,2),                       -- % of decisions that were intentional

    UNIQUE (user_id, cycle_month)
);

-- Indexes for behavioral pattern queries
CREATE INDEX idx_fomo_decisions_user_context ON fomo_decisions 
    USING GIN (context);
CREATE INDEX idx_fomo_decisions_user_time ON fomo_decisions 
    (user_id, decided_at DESC);
```

**AI/ML Requirements:**

| Requirement | Approach | On-Device Feasibility |
|---|---|---|
| Detecting "flex" vs. "necessity" purchases in real-time | Merchant MCC code classification + time/location context heuristic. Rule-based fallback if ML confidence < 0.75 | ✅ Yes — rule-based first |
| BLESS/BLOCK gate trigger (when to surface the gate) | Heuristic: trigger only for amounts > 2% of monthly budget + in flex-category merchant + non-recurring transaction | ✅ No ML needed |
| FOMO Score calculation | `(BLESSED + FORWARDED) / total_decisions` — simple ratio, explainable | ✅ Server-side SQL |
| Proactive flex budget recommendation at onboarding | Cohort-based: median flex % for users with similar allowance range at similar university type | Server-side only |

---

### Schema 3: Stealth Ledger

```sql
-- Stealth Ledger configuration (zero-knowledge design)
-- CRITICAL: stealth_pin_key_hash is a PBKDF2/Argon2 hash of user's Stealth PIN
-- The actual encryption key NEVER leaves the client device
CREATE TABLE stealth_ledger_config (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    stealth_pin_key_hash    VARCHAR(255) NOT NULL,  -- Argon2id hash, for PIN verification ONLY
    is_active           BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_accessed_at    TIMESTAMPTZ
    -- NOTE: No balance or transaction data stored here
);

-- Stealth transactions (all fields except metadata are client-side encrypted)
-- Server receives and stores only ciphertext. Decryption only possible on-device with PIN.
CREATE TABLE stealth_transactions (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- Encrypted blobs (AES-256-GCM, key derived from Stealth PIN on client)
    encrypted_amount        BYTEA NOT NULL,
    encrypted_category      BYTEA NOT NULL,
    encrypted_note          BYTEA,
    encrypted_merchant      BYTEA,
    encrypted_metadata      BYTEA,          -- full JSON blob, encrypted
    
    -- Non-sensitive indexing fields (for server-side ordering only)
    transaction_date        DATE NOT NULL,  -- date only (no time), for ordering
    iv                      BYTEA NOT NULL, -- AES initialization vector
    auth_tag                BYTEA NOT NULL, -- GCM authentication tag for integrity
    
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    synced_at               TIMESTAMPTZ     -- NULL if created offline
);

-- Row-level security: users can only access their own stealth records
ALTER TABLE stealth_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY stealth_owner_only ON stealth_transactions
    USING (user_id = current_setting('app.current_user_id')::UUID);

-- Aggregate stats (server stores only encrypted aggregate — client decrypts)
CREATE TABLE stealth_aggregate_cache (
    user_id             UUID PRIMARY KEY REFERENCES users(id),
    encrypted_total_spent   BYTEA,          -- encrypted monthly total
    record_count        INT NOT NULL DEFAULT 0,  -- count only, not amounts
    cache_month         DATE NOT NULL,
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**Client-Side Encryption Architecture:**

```javascript
// Key derivation from Stealth PIN (runs on device, never sent to server)
const deriveSteatlhKey = async (pin, userId) => {
    const encoder = new TextEncoder();
    const keyMaterial = await crypto.subtle.importKey(
        'raw', encoder.encode(pin), 'PBKDF2', false, ['deriveKey']
    );
    return await crypto.subtle.deriveKey({
        name: 'PBKDF2',
        salt: encoder.encode(userId),   // userId as salt (stored on server, not secret)
        iterations: 310_000,            // OWASP recommended for PBKDF2-SHA256
        hash: 'SHA-256'
    }, keyMaterial, { name: 'AES-GCM', length: 256 }, false, ['encrypt', 'decrypt']);
};

// Encrypting a transaction field before sending to server
const encryptField = async (key, plaintext) => {
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const encoded = new TextEncoder().encode(String(plaintext));
    const ciphertext = await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, encoded);
    return { iv, ciphertext: new Uint8Array(ciphertext) };
};
```

**AI/ML Requirements:**

| Requirement | Approach | On-Device Feasibility |
|---|---|---|
| AI categorization for stealth transactions | TensorFlow Lite model running entirely on-device. No data sent to server for inference. | ✅ Mandatory — on-device only |
| Stealth budget analytics | All aggregation done client-side after local decryption. Server receives zero plaintext data. | ✅ Mandatory |
| Anomaly detection (prevent accidental stealth logging) | Simple heuristic: warn if stealth amount > 50% of daily budget | ✅ Client-side rule |

---

### Schema 4: Academic Vault

```sql
-- University reference table (seeded + crowd-validated)
CREATE TABLE universities (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(300) NOT NULL,
    code            VARCHAR(30) UNIQUE,         -- e.g., 'UI', 'ITB', 'UGM'
    type            VARCHAR(20) CHECK (type IN ('NEGERI', 'SWASTA', 'POLITEKNIK', 'KEDINASAN')),
    city            VARCHAR(100),
    province        VARCHAR(100),
    country         VARCHAR(100) NOT NULL DEFAULT 'Indonesia',
    is_verified     BOOLEAN NOT NULL DEFAULT FALSE
);

-- Academic financial event templates (seeded per university + program)
CREATE TABLE academic_financial_events (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    university_id       UUID REFERENCES universities(id) ON DELETE CASCADE,   -- NULL = universal
    program_id          UUID REFERENCES academic_programs(id),                -- NULL = all programs
    
    event_name          VARCHAR(200) NOT NULL,
    event_type          VARCHAR(50) NOT NULL
                        CHECK (event_type IN (
                            'UKT', 'SPP', 'KKN', 'THESIS_DEFENSE', 'THESIS_PRINT',
                            'GRADUATION_FEE', 'WISUDA_PACKAGE', 'ORG_DUES',
                            'LAB_FEE', 'KKL', 'ACADEMIC_TRIP', 'CUSTOM'
                        )),
    
    -- Semester targeting
    target_semesters    SMALLINT[],             -- [5, 6] means semesters 5 and 6
    typical_month       SMALLINT CHECK (typical_month BETWEEN 1 AND 12),
    
    -- Cost estimates (crowd-sourced, validated)
    cost_estimate_min   DECIMAL(15,2),
    cost_estimate_max   DECIMAL(15,2),
    cost_estimate_median DECIMAL(15,2),
    cost_confidence     DECIMAL(3,2),           -- 0.0–1.0, data quality score
    data_points_count   INT NOT NULL DEFAULT 0, -- how many students contributed cost data
    
    is_recurring        BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified         BOOLEAN NOT NULL DEFAULT FALSE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User's personalized academic vaults
CREATE TABLE academic_vaults (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    academic_event_id       UUID REFERENCES academic_financial_events(id),   -- NULL = custom
    
    vault_name              VARCHAR(200) NOT NULL,
    target_amount           DECIMAL(15,2) NOT NULL CHECK (target_amount > 0),
    current_saved           DECIMAL(15,2) NOT NULL DEFAULT 0,
    deadline                DATE NOT NULL,
    
    -- Auto-reserve engine
    auto_reserve_enabled    BOOLEAN NOT NULL DEFAULT TRUE,
    auto_reserve_monthly    DECIMAL(15,2),       -- calculated: (target - saved) / months_remaining
    reserve_day             SMALLINT DEFAULT 1,  -- day of month to auto-reserve
    
    -- Lock mechanism
    is_locked               BOOLEAN NOT NULL DEFAULT TRUE,
    unlock_requires_delay_hours INT NOT NULL DEFAULT 24,    -- cooling-off before early withdrawal
    unlock_requested_at     TIMESTAMPTZ,
    
    status                  VARCHAR(20) NOT NULL DEFAULT 'SAVING'
                            CHECK (status IN ('SAVING', 'FUNDED', 'PARTIALLY_FUNDED', 'USED', 'MISSED', 'CANCELLED')),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Vault contribution ledger
CREATE TABLE vault_contributions (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vault_id            UUID NOT NULL REFERENCES academic_vaults(id) ON DELETE CASCADE,
    amount              DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    contribution_type   VARCHAR(20) NOT NULL CHECK (contribution_type IN ('AUTO', 'MANUAL', 'BONUS')),
    source_wallet_id    UUID,           -- which wallet was debited
    contributed_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    note                TEXT
);

-- Community cost-reporting (crowd-source validation)
CREATE TABLE vault_cost_reports (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    academic_event_id       UUID NOT NULL REFERENCES academic_financial_events(id),
    reporter_user_id        UUID NOT NULL REFERENCES users(id),
    reported_amount         DECIMAL(15,2) NOT NULL,
    academic_year           VARCHAR(10),    -- e.g., '2024/2025'
    program_name            VARCHAR(100),
    is_verified             BOOLEAN NOT NULL DEFAULT FALSE,
    submitted_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

**AI/ML Requirements:**

| Requirement | Approach | On-Device Feasibility |
|---|---|---|
| Auto-reserve amount calculation | Deterministic formula: `(target - current_saved) / months_to_deadline`. No ML. | ✅ Pure math |
| Academic Safety Score | Weighted average: `Σ (vault.current_saved / vault.target_amount * event_criticality_weight)` | ✅ Server SQL |
| Predicting when a vault will be under-funded based on current burn rate | Time-series regression on allowance injection patterns. Updates weekly. | Server-side, lightweight |
| Cost estimate validation (outlier rejection in crowd-sourced data) | IQR-based outlier detection before updating `cost_estimate_median`. Simple statistical method. | ✅ Server-side |
| Event calendar pre-population from university name | NLP entity matching + fuzzy search against `universities` table at onboarding | ✅ Server API call, one-time |

---

### Schema 5: Hustle Mirror (Side-Income P&L Dashboard)

```sql
-- Side hustle project definition
CREATE TABLE hustles (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    category        VARCHAR(50) NOT NULL
                    CHECK (category IN (
                        'FREELANCE_DESIGN', 'FREELANCE_DEV', 'TUTORING',
                        'CONTENT_CREATION', 'RESELLER', 'DROPSHIP',
                        'EVENT_ORGANIZER', 'FOOD_BUSINESS', 'OTHER'
                    )),
    description     TEXT,
    status          VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                    CHECK (status IN ('ACTIVE', 'PAUSED', 'COMPLETED', 'ABANDONED')),
    started_at      DATE NOT NULL DEFAULT CURRENT_DATE,
    ended_at        DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Revenue entries per hustle
CREATE TABLE hustle_revenue (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hustle_id       UUID NOT NULL REFERENCES hustles(id) ON DELETE CASCADE,
    amount          DECIMAL(15,2),               -- NULL if in-kind
    currency        VARCHAR(3) DEFAULT 'IDR',
    
    -- In-kind / barter tracking
    is_in_kind      BOOLEAN NOT NULL DEFAULT FALSE,
    in_kind_desc    TEXT,
    in_kind_value   DECIMAL(15,2),               -- user-estimated market value
    
    payment_channel VARCHAR(50),                 -- 'CASH', 'TRANSFER', 'GOPAY', 'DANA', 'OVO'
    client_name     VARCHAR(200),
    project_label   VARCHAR(200),
    received_at     DATE NOT NULL,
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Cost entries per hustle (direct costs only)
CREATE TABLE hustle_costs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hustle_id       UUID NOT NULL REFERENCES hustles(id) ON DELETE CASCADE,
    description     VARCHAR(300) NOT NULL,
    amount          DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    category        VARCHAR(50)
                    CHECK (category IN (
                        'SOFTWARE_SUBSCRIPTION', 'MATERIALS', 'TRANSPORT',
                        'PRINTING', 'EQUIPMENT', 'MARKETING', 'PLATFORM_FEE', 'OTHER'
                    )),
    incurred_at     DATE NOT NULL,
    is_recurring    BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_period VARCHAR(20) CHECK (recurrence_period IN ('MONTHLY', 'YEARLY', NULL)),
    note            TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Time tracking per hustle
CREATE TABLE hustle_time_logs (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hustle_id       UUID NOT NULL REFERENCES hustles(id) ON DELETE CASCADE,
    started_at      TIMESTAMPTZ NOT NULL,
    ended_at        TIMESTAMPTZ,
    duration_minutes INT,                        -- calculated or manual override
    work_label      VARCHAR(200),               -- e.g., 'Client A revisions', 'admin & invoicing'
    logged_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Computed P&L view (materialized, refreshed daily)
CREATE MATERIALIZED VIEW hustle_pnl AS
SELECT
    h.id AS hustle_id,
    h.user_id,
    h.name,
    h.category,
    
    -- Revenue
    COALESCE(SUM(r.amount), 0) + COALESCE(SUM(r.in_kind_value), 0)  AS total_gross_revenue,
    
    -- Costs
    COALESCE(SUM(c.amount), 0)                                       AS total_direct_costs,
    
    -- Net P&L
    (COALESCE(SUM(r.amount), 0) + COALESCE(SUM(r.in_kind_value), 0))
    - COALESCE(SUM(c.amount), 0)                                     AS net_profit,
    
    -- Time investment
    COALESCE(SUM(t.duration_minutes), 0)                             AS total_hours_minutes,
    
    -- Effective hourly rate (IDR/hour)
    CASE
        WHEN COALESCE(SUM(t.duration_minutes), 0) > 0
        THEN ((COALESCE(SUM(r.amount), 0) + COALESCE(SUM(r.in_kind_value), 0))
              - COALESCE(SUM(c.amount), 0))
             / (COALESCE(SUM(t.duration_minutes), 0) / 60.0)
        ELSE NULL
    END                                                              AS effective_hourly_rate_idr,
    
    -- Profitability flag
    CASE
        WHEN ((COALESCE(SUM(r.amount), 0) + COALESCE(SUM(r.in_kind_value), 0))
              - COALESCE(SUM(c.amount), 0)) > 0 THEN 'PROFITABLE'
        WHEN ((COALESCE(SUM(r.amount), 0) + COALESCE(SUM(r.in_kind_value), 0))
              - COALESCE(SUM(c.amount), 0)) = 0 THEN 'BREAK_EVEN'
        ELSE 'LOSS'
    END                                                              AS profitability_status

FROM hustles h
LEFT JOIN hustle_revenue r ON r.hustle_id = h.id
LEFT JOIN hustle_costs   c ON c.hustle_id = h.id
LEFT JOIN hustle_time_logs t ON t.hustle_id = h.id AND t.ended_at IS NOT NULL
GROUP BY h.id, h.user_id, h.name, h.category;

-- Tax awareness trigger table
CREATE TABLE hustle_tax_alerts (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                 UUID NOT NULL REFERENCES users(id),
    alert_type              VARCHAR(50) NOT NULL
                            CHECK (alert_type IN ('UMKM_THRESHOLD_WARNING', 'QUARTERLY_REMINDER', 'EDUCATIONAL')),
    ytd_gross_revenue       DECIMAL(15,2) NOT NULL,
    threshold_pct           DECIMAL(5,2),           -- % of annual UMKM threshold reached
    educational_content_id  UUID,
    shown_at                TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    dismissed_at            TIMESTAMPTZ
);
```

**AI/ML Requirements:**

| Requirement | Approach | On-Device Feasibility |
|---|---|---|
| Income projection for irregular hustle revenue | ARIMA or Exponential Smoothing on per-hustle revenue time series. Minimum 3 data points before activating. | Server-side (insufficient on-device data in early use) |
| Automatic cost categorization from description | TF-IDF classifier + keyword matching. E.g., "Adobe CC renewal" → SOFTWARE_SUBSCRIPTION | ✅ Yes — lightweight model |
| Effective hourly rate benchmarking | Cohort comparison: "Students doing FREELANCE_DESIGN in your region average Rp45k/hour. You're at Rp18k/hour." | Server-side aggregate SQL |
| Tax threshold monitoring | Deterministic: SUM(ytd_revenue) / 500_000_000 × 100. Trigger alert at 20%, 50%, 80%, 95% | ✅ Pure math |
| Hustle Report Card generation | Templated summary with dynamic data fill. No ML. | ✅ Client-side render |

---

## [5] UPDATED FR MATRIX — Integrating Radical Features

| ID | Feature Name | Pain Point Addressed | Priority | Category |
|---|---|---|---|---|
| **FR-M01** | Core Authentication | Foundation | Must Have | General |
| **FR-M02** | AI Auto-Categorization (with Quick Cash Log) | Cash Blindness | Must Have | Overpower |
| **FR-M03** | Event-Driven Allowance Engine | Irregular Income | Must Have | Student Mode |
| **FR-M04** | Ghost Debt Ledger™ | Distributed Debt Web | **Must Have** | **Radical** |
| **FR-M05** | FOMO Fund™ | FOMO Tax | **Must Have** | **Radical** |
| **FR-S01** | Stealth Ledger™ | Parental Surveillance | Should Have | **Radical** |
| **FR-S02** | Academic Vault™ | Academic Ambush | Should Have | **Radical** |
| **FR-S03** | Hustle Mirror™ | Side-Hustle Chaos | Should Have | **Radical** |
| **FR-S04** | Predictive Burn-Rate + Prescription Engine | Anxiety without Agency | Should Have | Overpower |
| **FR-C01** | Survival Mode + Community Radar | End-of-month survival | Could Have | Student Mode |
| **FR-C02** | Financial Avatar | Gamification / Retention | Could Have | Overpower |
| **FR-C03** | Campus Org Treasury Mode | Club budget management | Could Have | Student Mode |

---

## CLOSING STRATEGIC NOTE

The five radical features proposed here share a common design philosophy that differentiates them from every existing finance app:

1. **They don't moralize.** FOMO Fund legitimizes social spending. Ghost Debt Ledger removes judgment from informal debt. This is culturally specific and emotionally intelligent.

2. **They solve social dynamics, not just financial ones.** Stealth Ledger solves a family relationship problem. Ghost Debt Ledger solves a friendship preservation problem. This is a category expansion: from finance app to *life app*.

3. **They build data moats.** Academic Vault requires institutional financial calendar data that competitors can't easily replicate. Hustle Mirror requires time-tracking + revenue data that creates a longitudinal user profile.

4. **They work offline-first.** Stealth Ledger's encryption is client-side. Ghost Debt Ledger logs unilaterally. Academic Vault's auto-reserve calculation is deterministic. These aren't AI-dependent features — they work in Gedung C basement with zero signal.

5. **They compound.** A user who logs their Ghost Debt, FOMO Fund allocations, Stealth transactions, Vault progress, and Hustle income creates a **complete financial identity** inside this app — one that would take years to rebuild elsewhere. That's the retention flywheel that a "Daily Safe-to-Spend" number alone will never achieve.

---

*Document generated as part of the Momentum Product Intelligence Series.*
