from fastapi import HTTPException,Body 

from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.approval import Approval
from app.models.expense import Expense
from app.models.user import User
from app.services.approval_engine import check_approval_completion

router=APIRouter()

def _to_dict(model):
    return {column.name: getattr(model, column.name) for column in model.__table__.columns}

@router.get("/pending")
def pending(user=Depends(get_current_user),
            db:Session=Depends(get_db)):

    rows=db.query(Approval,Expense,User)\
        .join(Expense, Approval.expense_id==Expense.id)\
        .join(User, User.id==Expense.user_id)\
        .filter(
            Approval.approver_id==user.id,
            Approval.status=="PENDING"
        ).all()

    return [
        {
            "approval": _to_dict(approval),
            "expense": _to_dict(expense),
            "employee": {"id": employee.id, "email": employee.email}
        }
        for approval, expense, employee in rows
    ]

@router.post("/{expense_id}")
def approve(expense_id:int,
            user=Depends(get_current_user),
            db:Session=Depends(get_db)):

    approval=db.query(Approval)\
        .filter_by(
            expense_id=expense_id,
            approver_id=user.id
        ).first()
    
    if not approval:
        raise HTTPException(status_code=404, detail="Approval not found for this user")


    approval.status="APPROVED"
    db.commit()

    check_approval_completion(expense_id,db)

    return {"msg":"Approved"}


@router.post("/{expense_id}/reject")
def reject(expense_id:int,
           payload:dict=Body(default={}),
           user=Depends(get_current_user),
           db:Session=Depends(get_db)):

    approval=db.query(Approval)\
        .filter_by(
            expense_id=expense_id,
            approver_id=user.id
        ).first()
    
    if not approval:
        raise HTTPException(status_code=404, detail="Approval not found for this user")

    approval.status="REJECTED"
    db.commit()

    expense=db.query(Expense).get(expense_id)
    if expense:
        expense.status="REJECTED"
        db.commit()

    return {"msg":"Rejected"}
