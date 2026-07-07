import { pgTable, uuid, varchar, timestamp, decimal, text, integer, boolean, date, customType } from 'drizzle-orm/pg-core';

// Custom type for PostgreSQL bytea (binary data)
const bytea = customType<{ data: Buffer }>({
  dataType() {
    return 'bytea';
  },
  toDriver(val: Buffer) {
    return val;
  },
  fromDriver(val: unknown) {
    if (Buffer.isBuffer(val)) {
      return val;
    }
    return Buffer.from(val as string, 'hex');
  }
});

// Users table (Clerk synced)
export const users = pgTable('users', {
  id: uuid('id').defaultRandom().primaryKey(),
  clerkId: varchar('clerk_id', { length: 255 }).notNull().unique(),
  email: varchar('email', { length: 255 }).notNull().unique(),
  displayName: varchar('display_name', { length: 255 }),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Wallets table
export const wallets = pgTable('wallets', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  name: varchar('name', { length: 100 }).notNull(),
  type: varchar('type', { length: 50 }).notNull(), // 'CASH', 'BANK', 'EWALLET'
  balance: decimal('balance', { precision: 15, scale: 2 }).default('0').notNull(),
  currency: varchar('currency', { length: 3 }).default('IDR').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});

// Cash Logs table (standard transactions)
export const cashLogs = pgTable('cash_logs', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  walletId: uuid('wallet_id').references(() => wallets.id, { onDelete: 'cascade' }),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 3 }).default('IDR').notNull(),
  type: varchar('type', { length: 20 }).notNull(), // 'INCOME', 'EXPENSE', 'TRANSFER'
  category: varchar('category', { length: 100 }).notNull(),
  description: text('description'),
  transactionDate: date('transaction_date').defaultNow().notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
});

// Ghost Debt: IOU records
export const iouRecords = pgTable('iou_records', {
  id: uuid('id').defaultRandom().primaryKey(),
  ownerUserId: uuid('owner_user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  counterpartyUserId: uuid('counterparty_user_id').references(() => users.id, { onDelete: 'set null' }),
  counterpartyAlias: varchar('counterparty_alias', { length: 100 }),
  counterpartyContact: varchar('counterparty_contact', { length: 50 }),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  currency: varchar('currency', { length: 3 }).default('IDR').notNull(),
  direction: varchar('direction', { length: 20 }).notNull(), // 'I_OWE', 'OWED_TO_ME'
  reason: text('reason'),
  contextTags: text('context_tags').array(),
  emojiTag: varchar('emoji_tag', { length: 10 }),
  status: varchar('status', { length: 20 }).default('OPEN').notNull(), // 'OPEN', 'PARTIAL', 'SETTLED', 'FORGIVEN', 'DISPUTED'
  settledAmount: decimal('settled_amount', { precision: 15, scale: 2 }).default('0').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  dueDate: date('due_date'),
  settledAt: timestamp('settled_at', { withTimezone: true }),
  autoForgiveAfterDays: integer('auto_forgive_after_days'),
  forgivenessThresholdIdr: decimal('forgiveness_threshold_idr', { precision: 15, scale: 2 }),
  nudgeStyle: varchar('nudge_style', { length: 20 }).default('SUBTLE'), // 'SUBTLE', 'HUMOROUS', 'FORMAL', 'NONE'
  nudgeCount: integer('nudge_count').default(0).notNull(),
  lastNudgeAt: timestamp('last_nudge_at', { withTimezone: true }),
  nextNudgeAt: timestamp('next_nudge_at', { withTimezone: true }),
});

// Ghost Debt: IOU Settlements
export const iouSettlements = pgTable('iou_settlements', {
  id: uuid('id').defaultRandom().primaryKey(),
  iouId: uuid('iou_id').notNull().references(() => iouRecords.id, { onDelete: 'cascade' }),
  amount: decimal('amount', { precision: 15, scale: 2 }).notNull(),
  method: varchar('method', { length: 50 }), // 'CASH', 'TRANSFER', 'GOPAY', 'MEAL', 'BARTER'
  note: text('note'),
  settledAt: timestamp('settled_at', { withTimezone: true }).defaultNow().notNull(),
});

// Ghost Debt: Mutual consent links
export const iouMutualLinks = pgTable('iou_mutual_links', {
  id: uuid('id').defaultRandom().primaryKey(),
  partyAIouId: uuid('party_a_iou_id').notNull().references(() => iouRecords.id),
  partyBIouId: uuid('party_b_iou_id').notNull().references(() => iouRecords.id),
  linkedAt: timestamp('linked_at', { withTimezone: true }).defaultNow().notNull(),
  consensusStatus: varchar('consensus_status', { length: 20 }).default('PENDING'), // 'PENDING', 'AGREED', 'DISPUTED'
});

// Stealth Ledger: configuration
export const stealthLedgerConfig = pgTable('stealth_ledger_config', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().unique().references(() => users.id, { onDelete: 'cascade' }),
  stealthPinKeyHash: varchar('stealth_pin_key_hash', { length: 255 }).notNull(),
  isActive: boolean('is_active').default(false).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  lastAccessedAt: timestamp('last_accessed_at', { withTimezone: true }),
});

// Stealth Ledger: transactions (encrypted blobs)
export const stealthTransactions = pgTable('stealth_transactions', {
  id: uuid('id').defaultRandom().primaryKey(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  encryptedAmount: bytea('encrypted_amount').notNull(),
  encryptedCategory: bytea('encrypted_category').notNull(),
  encryptedNote: bytea('encrypted_note'),
  encryptedMerchant: bytea('encrypted_merchant'),
  encryptedMetadata: bytea('encrypted_metadata'),
  transactionDate: date('transaction_date').notNull(),
  iv: bytea('iv').notNull(),
  authTag: bytea('auth_tag').notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).defaultNow().notNull(),
  syncedAt: timestamp('synced_at', { withTimezone: true }),
});

// Stealth Ledger: aggregate cache
export const stealthAggregateCache = pgTable('stealth_aggregate_cache', {
  userId: uuid('user_id').primaryKey().references(() => users.id),
  encryptedTotalSpent: bytea('encrypted_total_spent'),
  recordCount: integer('record_count').default(0).notNull(),
  cacheMonth: date('cache_month').notNull(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).defaultNow().notNull(),
});
