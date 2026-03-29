from fastapi import APIRouter,Depends,UploadFile
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.expense import Expense
from app.schemas.expense import ExpenseCreate
from app.services.approval_engine import generate_approval_flow
from app.services.ocr_service import extract_receipt

router=APIRouter()

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

    with open(path,"wb") as f:
        f.write(file.file.read())

    return extract_receipt(path)