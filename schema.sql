-- ============================================================
-- Personal Finance AI - PostgreSQL Schema
-- ============================================================

-- USERS
CREATE TABLE users (
    id          BIGSERIAL PRIMARY KEY,
    email       VARCHAR(255) NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    full_name   VARCHAR(100) NOT NULL,
    phone       VARCHAR(20),
    monthly_income  DECIMAL(15,2) DEFAULT 0,
    risk_profile    VARCHAR(20) DEFAULT 'MODERATE' CHECK (risk_profile IN ('CONSERVATIVE','MODERATE','AGGRESSIVE')),
    currency        VARCHAR(10) DEFAULT 'INR',
    health_score    INT DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    updated_at  TIMESTAMP DEFAULT NOW()
);

-- CATEGORIES
CREATE TABLE categories (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    icon        VARCHAR(50),
    color       VARCHAR(20),
    type        VARCHAR(20) NOT NULL CHECK (type IN ('EXPENSE','INCOME')),
    is_system   BOOLEAN DEFAULT FALSE,
    user_id     BIGINT REFERENCES users(id) ON DELETE CASCADE
);

-- TRANSACTIONS
CREATE TABLE transactions (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id     BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    amount          DECIMAL(15,2) NOT NULL,
    type            VARCHAR(20) NOT NULL CHECK (type IN ('INCOME','EXPENSE','TRANSFER')),
    description     VARCHAR(500),
    merchant        VARCHAR(200),
    transaction_date DATE NOT NULL,
    is_recurring    BOOLEAN DEFAULT FALSE,
    recurrence_rule VARCHAR(50),
    ai_classified   BOOLEAN DEFAULT FALSE,
    tags            TEXT[],
    created_at      TIMESTAMP DEFAULT NOW()
);

-- BUDGETS
CREATE TABLE budgets (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id     BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    amount          DECIMAL(15,2) NOT NULL,
    period          VARCHAR(20) NOT NULL CHECK (period IN ('WEEKLY','MONTHLY','YEARLY')),
    start_date      DATE NOT NULL,
    end_date        DATE NOT NULL,
    alert_threshold DECIMAL(5,2) DEFAULT 80.00,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- GOALS
CREATE TABLE goals (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title           VARCHAR(200) NOT NULL,
    description     TEXT,
    target_amount   DECIMAL(15,2) NOT NULL,
    current_amount  DECIMAL(15,2) DEFAULT 0,
    deadline        DATE NOT NULL,
    goal_type       VARCHAR(50) CHECK (goal_type IN ('SAVINGS','EMERGENCY_FUND','VACATION','HOME','EDUCATION','RETIREMENT','OTHER')),
    status          VARCHAR(20) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','COMPLETED','PAUSED','CANCELLED')),
    created_at      TIMESTAMP DEFAULT NOW()
);

-- INVESTMENTS
CREATE TABLE investments (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name            VARCHAR(200) NOT NULL,
    type            VARCHAR(50) CHECK (type IN ('SIP','MUTUAL_FUND','FD','STOCKS','CRYPTO','GOLD','PPF','NPS','OTHER')),
    amount_invested DECIMAL(15,2) NOT NULL,
    current_value   DECIMAL(15,2),
    start_date      DATE,
    maturity_date   DATE,
    expected_return DECIMAL(5,2),
    notes           TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- INSURANCE RECOMMENDATIONS
CREATE TABLE insurance_recommendations (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type            VARCHAR(50) CHECK (type IN ('HEALTH','TERM_LIFE','VEHICLE','HOME','TRAVEL')),
    recommended_cover DECIMAL(15,2),
    current_cover   DECIMAL(15,2) DEFAULT 0,
    is_underinsured BOOLEAN DEFAULT FALSE,
    ai_reasoning    TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- AI CHAT LOGS
CREATE TABLE ai_logs (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    session_id      VARCHAR(100),
    role            VARCHAR(20) CHECK (role IN ('user','assistant','system')),
    content         TEXT NOT NULL,
    tokens_used     INT,
    created_at      TIMESTAMP DEFAULT NOW()
);

-- FINANCIAL HEALTH SCORES (history)
CREATE TABLE health_score_history (
    id              BIGSERIAL PRIMARY KEY,
    user_id         BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    score           INT NOT NULL,
    breakdown       JSONB,
    calculated_at   TIMESTAMP DEFAULT NOW()
);

-- BADGES / GAMIFICATION
CREATE TABLE badges (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    description TEXT,
    icon        VARCHAR(100),
    criteria    JSONB
);

CREATE TABLE user_badges (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    badge_id    BIGINT NOT NULL REFERENCES badges(id),
    earned_at   TIMESTAMP DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================
CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_transactions_type ON transactions(user_id, type);
CREATE INDEX idx_budgets_user_period ON budgets(user_id, period);
CREATE INDEX idx_goals_user_status ON goals(user_id, status);
CREATE INDEX idx_ai_logs_session ON ai_logs(user_id, session_id);
CREATE INDEX idx_investments_user ON investments(user_id);

-- ============================================================
-- SEED: Default system categories
-- ============================================================
INSERT INTO categories (name, icon, color, type, is_system) VALUES
('Salary',        'briefcase',    '#22c55e', 'INCOME',  TRUE),
('Freelance',     'laptop',       '#16a34a', 'INCOME',  TRUE),
('Food & Dining', 'utensils',     '#f97316', 'EXPENSE', TRUE),
('Transport',     'car',          '#3b82f6', 'EXPENSE', TRUE),
('Shopping',      'shopping-bag', '#a855f7', 'EXPENSE', TRUE),
('Healthcare',    'heart-pulse',  '#ef4444', 'EXPENSE', TRUE),
('Entertainment', 'film',         '#ec4899', 'EXPENSE', TRUE),
('Utilities',     'zap',          '#eab308', 'EXPENSE', TRUE),
('Rent',          'home',         '#6366f1', 'EXPENSE', TRUE),
('Education',     'book-open',    '#0ea5e9', 'EXPENSE', TRUE),
('Investments',   'trending-up',  '#10b981', 'EXPENSE', TRUE),
('Insurance',     'shield',       '#64748b', 'EXPENSE', TRUE),
('Other',         'more-horizontal','#94a3b8','EXPENSE',TRUE);
