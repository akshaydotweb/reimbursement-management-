from fastapi import FastAPI
from app.core.database import Base,engine

from app.routers import auth,users,expenses,approvals,admin

app=FastAPI(title="Reimbursement System")

Base.metadata.create_all(bind=engine)

app.include_router(auth.router,prefix="/auth")
app.include_router(users.router,prefix="/users")
app.include_router(expenses.router,prefix="/expenses")
app.include_router(approvals.router,prefix="/approvals")
app.include_router(admin.router,prefix="/admin")