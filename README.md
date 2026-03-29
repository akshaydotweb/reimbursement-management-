# Reimbursement Management System

Vue (Vite) frontend + FastAPI backend for managing reimbursement workflows with role-based UX.

## Features
- Role-based UI for Admin, Manager, and Employee
- Admin user management with manager assignment
- Expense submission with receipt OCR and auto-fill
- Manager approvals with comments and currency conversion
- Multi-step approvals with manager-first, percentage, and specific-approver rules
- Admin overrides and approvals visibility
- Loading, empty, and success/error states

## Tech Stack
- Frontend: Vue 3 + Vite + Cedar Design System
- Backend: FastAPI + SQLAlchemy + Postgres
- OCR: pytesseract + PIL

## Prerequisites
- Node.js and npm
- Python 3
- PostgreSQL running locally

## Environment
Create or update `.env` in the project root:
```
DATABASE_URL=postgresql://<user>:<password>@localhost/reimbursement_db
SECRET_KEY=<your_secret_key>
```

### .env Notes
- `DATABASE_URL` must point to a running Postgres instance.
- `SECRET_KEY` is required for JWT signing (use any random string).
- If `.env` is missing, the backend will fail to start.

## Backend Setup
Create a virtual environment in `app/.venv` and install dependencies:
```
python3 -m venv app/.venv
app/.venv/bin/pip install fastapi uvicorn sqlalchemy python-jose "passlib[bcrypt]" python-multipart pillow pytesseract requests python-dotenv
```

Apply database updates:
```
psql reimbursement_db -f db/update.sql
```

### Database Notes
- The update script adds required columns and tables.
- If you already have data, **do not drop** tables—use the update script.
- If Postgres isn’t running, the backend won’t start.

Run the backend:
```
app/.venv/bin/uvicorn app.main:app --reload
```

Backend runs at:
```
http://127.0.0.1:8000
```

## Frontend Setup
Install dependencies:
```
cd frontend
npm install
```

Run the frontend:
```
npm run dev
```

Frontend runs at:
```
http://localhost:5174
```

## Basic Flow
1. Admin signs up (company created automatically).
2. Admin creates managers and employees and assigns manager relationships.
3. Employee submits an expense with receipt upload and optional OCR auto-fill.
4. Manager reviews assigned approvals and approves/rejects with comments.
5. Admin can override approvals if needed.

## API Notes
- `GET /users/me` returns the current user profile.
- `GET /approvals/pending` returns approvals assigned to the current manager.
- Approval rules and steps are managed via `/admin/approval-rule` and `/admin/approval-steps`.

## Troubleshooting
- If you see "Unable to load approvals" or "Unable to submit", run:
  ```
  psql reimbursement_db -f db/update.sql
  ```
- Ensure Postgres is running and `DATABASE_URL` is correct.
