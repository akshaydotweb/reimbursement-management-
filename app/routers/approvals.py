from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.approval import Approval
from app.services.approval_engine import check_approval_completion

router=APIRouter()

@router.post("/{expense_id}")
def approve(expense_id:int,
            user=Depends(get_current_user),
            db:Session=Depends(get_db)):

    approval=db.query(Approval)\
        .filter_by(
            expense_id=expense_id,
            approver_id=user.id
        ).first()

    approval.status="APPROVED"
    db.commit()

    check_approval_completion(expense_id,db)

    return {"msg":"Approved"}