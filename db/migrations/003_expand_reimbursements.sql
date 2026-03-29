-- Add missing columns to expenses
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS expense_date TEXT;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS paid_by TEXT;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS remarks TEXT;
ALTER TABLE expenses ADD COLUMN IF NOT EXISTS receipt_url TEXT;

-- Add comment to approvals (if approvals table exists)
ALTER TABLE approvals ADD COLUMN IF NOT EXISTS comment TEXT;

-- Create approvals table if missing
CREATE TABLE IF NOT EXISTS approvals (
  id SERIAL PRIMARY KEY,
  expense_id INTEGER,
  approver_id INTEGER,
  step_order INTEGER,
  status VARCHAR DEFAULT 'PENDING',
  comment TEXT
);

-- Create approval rules table
CREATE TABLE IF NOT EXISTS approval_rules (
  id SERIAL PRIMARY KEY,
  company_id INTEGER,
  percentage_required FLOAT,
  specific_approver_id INTEGER,
  manager_first BOOLEAN DEFAULT true
);

-- Create approval steps table
CREATE TABLE IF NOT EXISTS approval_steps (
  id SERIAL PRIMARY KEY,
  company_id INTEGER,
  approver_id INTEGER,
  step_order INTEGER,
  required BOOLEAN DEFAULT true
);
