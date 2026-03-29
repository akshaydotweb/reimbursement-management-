-- ENUMS
CREATE TYPE user_role AS ENUM ('ADMIN', 'MANAGER', 'EMPLOYEE');

CREATE TYPE expense_status AS ENUM (
  'DRAFT','SUBMITTED','PENDING','APPROVED','REJECTED'
);

CREATE TYPE approval_status AS ENUM (
  'PENDING','APPROVED','REJECTED'
);

CREATE TYPE approver_type AS ENUM (
  'MANAGER','ROLE','USER'
);

CREATE TYPE rule_type AS ENUM (
  'SEQUENTIAL','PERCENTAGE','SPECIFIC','HYBRID'
);

-- COMPANIES
CREATE TABLE companies (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    default_currency VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- USERS
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    role user_role NOT NULL,
    manager_id BIGINT REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- EXPENSES
CREATE TABLE expenses (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id),

    amount NUMERIC(12,2) NOT NULL,
    currency VARCHAR(10) NOT NULL,

    category TEXT,
    description TEXT,
    expense_date DATE,

    status expense_status DEFAULT 'DRAFT',
    current_step INT DEFAULT 1,

    metadata JSONB,

    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- EXPENSE ITEMS
CREATE TABLE expense_items (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT REFERENCES expenses(id) ON DELETE CASCADE,

    name TEXT,
    quantity INT,
    unit_price NUMERIC(10,2),
    total NUMERIC(10,2)
);

-- WORKFLOWS
CREATE TABLE workflows (
    id BIGSERIAL PRIMARY KEY,
    company_id BIGINT REFERENCES companies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

-- WORKFLOW STEPS
CREATE TABLE workflow_steps (
    id BIGSERIAL PRIMARY KEY,
    workflow_id BIGINT REFERENCES workflows(id) ON DELETE CASCADE,

    step_order INT NOT NULL,
    approver_type approver_type NOT NULL,

    approver_user_id BIGINT REFERENCES users(id),
    approver_role user_role,

    is_mandatory BOOLEAN DEFAULT TRUE,

    UNIQUE (workflow_id, step_order)
);

-- WORKFLOW RULES
CREATE TABLE workflow_rules (
    id BIGSERIAL PRIMARY KEY,
    workflow_id BIGINT REFERENCES workflows(id) ON DELETE CASCADE,

    rule_type rule_type NOT NULL,
    percentage_value INT,
    specific_user_id BIGINT REFERENCES users(id),

    config JSONB
);

-- EXPENSE WORKFLOW INSTANCE
CREATE TABLE expense_workflows (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT UNIQUE REFERENCES expenses(id) ON DELETE CASCADE,
    workflow_id BIGINT REFERENCES workflows(id),

    started_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- APPROVAL LOG
CREATE TABLE expense_approvals (
    id BIGSERIAL PRIMARY KEY,
    expense_id BIGINT REFERENCES expenses(id) ON DELETE CASCADE,
    step_id BIGINT REFERENCES workflow_steps(id),

    approver_id BIGINT REFERENCES users(id),

    status approval_status DEFAULT 'PENDING',
    comment TEXT,

    decided_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- INDEXES
CREATE INDEX idx_users_company ON users(company_id);
CREATE INDEX idx_expenses_user ON expenses(user_id);
CREATE INDEX idx_expenses_status ON expenses(status);
CREATE INDEX idx_approvals_expense ON expense_approvals(expense_id);
CREATE INDEX idx_approvals_approver ON expense_approvals(approver_id);
