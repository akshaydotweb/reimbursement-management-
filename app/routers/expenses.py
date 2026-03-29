from fastapi import APIRouter,Depends,UploadFile,HTTPException
import os
from sqlalchemy.orm import Session
from typing import Optional

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.expense import Expense
from app.models.user import User
from app.models.company import Company
from app.services.currency import convert_amount
from app.schemas.expense import ExpenseCreate
from app.services.approval_engine import generate_approval_flow
from app.services.ocr_service import extract_receipt

router=APIRouter()

def _to_dict(expense, display_currency=None):
    data = {column.name: getattr(expense, column.name) for column in expense.__table__.columns}
    if display_currency:
        data["display_currency"] = display_currency
        data["display_amount"] = convert_amount(expense.amount, expense.currency, display_currency)
    return data

@router.get("/")
def list_expenses(user_id:Optional[int]=None,
                  user=Depends(get_current_user),
                  db:Session=Depends(get_db)):

    base_query=db.query(Expense)\
        .filter_by(company_id=user.company_id)
    company=db.query(Company).get(user.company_id)
    base_currency=company.base_currency if company else None

    if user.role == "ADMIN":
        if user_id:
            return [_to_dict(e) for e in base_query.filter_by(user_id=user_id).all()]
        return [_to_dict(e) for e in base_query.all()]

    if user.role == "MANAGER":
        if user_id:
            employee=db.query(User)\
                .filter_by(id=user_id,company_id=user.company_id).first()
            if not employee or employee.manager_id != user.id:
                raise HTTPException(status_code=403, detail="Not allowed")
            return [_to_dict(e, base_currency) for e in base_query.filter_by(user_id=user_id).all()]

        team_ids=[
            member.id for member in db.query(User)
            .filter_by(company_id=user.company_id,manager_id=user.id).all()
        ]
        if not team_ids:
            return []
        return [_to_dict(e, base_currency) for e in base_query.filter(Expense.user_id.in_(team_ids)).all()]

    return [_to_dict(e) for e in base_query.filter_by(user_id=user.id).all()]

@router.post("/")
def create_expense(data:ExpenseCreate,
                   user=Depends(get_current_user),
                   db:Session=Depends(get_db)):

    expense=Expense(
        user_id=user.id,
        company_id=user.company_id,
        amount=data.amount,
        currency=data.currency,
        description=data.description,
        category=data.category,
        expense_date=data.expense_date,
        paid_by=data.paid_by,
        remarks=data.remarks,
        receipt_url=data.receipt_url,
        status="SUBMITTED"
    )

    db.add(expense)
    db.commit()
    db.refresh(expense)

    generate_approval_flow(expense,db)

    return expense


@router.post("/upload")
def upload_receipt(file:UploadFile):

    path=f"uploads/{file.filename}"
    os.makedirs("uploads", exist_ok=True)

    with open(path,"wb") as f:
        f.write(file.file.read())

    data=extract_receipt(path)
    data["receipt_url"]=path
    return data
