from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.expense import Expense

router=APIRouter()

@router.get("/all-expenses")
def all_expenses(user=Depends(get_current_user),
                 db:Session=Depends(get_db)):

    return db.query(Expense)\
        .filter_by(company_id=user.company_id).all()