from fastapi import APIRouter,Depends,HTTPException
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.expense import Expense
from app.models.rule import ApprovalRule
from app.models.approval_step import ApprovalStep
from app.models.approval import Approval
from app.schemas.approval import ApprovalRuleUpdate, ApprovalStepUpdate

router=APIRouter()

def _ensure_admin(user):
    if user.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Not allowed")

@router.get("/all-expenses")
def all_expenses(user=Depends(get_current_user),
                 db:Session=Depends(get_db)):

    _ensure_admin(user)
    return db.query(Expense)\
        .filter_by(company_id=user.company_id).all()


@router.get("/approval-rule")
def get_rule(user=Depends(get_current_user),
             db:Session=Depends(get_db)):
    _ensure_admin(user)
    rule=db.query(ApprovalRule).filter_by(company_id=user.company_id).first()
    if not rule:
        rule=ApprovalRule(company_id=user.company_id, manager_first=True)
        db.add(rule)
        db.commit()
        db.refresh(rule)
    return {
        "id": rule.id,
        "percentage_required": rule.percentage_required,
        "specific_approver_id": rule.specific_approver_id,
        "manager_first": rule.manager_first
    }


@router.put("/approval-rule")
def update_rule(data:ApprovalRuleUpdate,
                user=Depends(get_current_user),
                db:Session=Depends(get_db)):
    _ensure_admin(user)
    rule=db.query(ApprovalRule).filter_by(company_id=user.company_id).first()
    if not rule:
        rule=ApprovalRule(company_id=user.company_id)
        db.add(rule)
    rule.percentage_required=data.percentage_required
    rule.specific_approver_id=data.specific_approver_id
    rule.manager_first=data.manager_first if data.manager_first is not None else True
    db.commit()
    return {"msg":"Approval rule updated"}


@router.get("/approval-steps")
def get_steps(user=Depends(get_current_user),
              db:Session=Depends(get_db)):
    _ensure_admin(user)
    steps=db.query(ApprovalStep)\
        .filter_by(company_id=user.company_id)\
        .order_by(ApprovalStep.step_order.asc())\
        .all()
    return [
        {
            "id": step.id,
            "approver_id": step.approver_id,
            "step_order": step.step_order,
            "required": step.required
        } for step in steps
    ]


@router.post("/approval-steps")
def update_steps(data:ApprovalStepUpdate,
                 user=Depends(get_current_user),
                 db:Session=Depends(get_db)):
    _ensure_admin(user)
    db.query(ApprovalStep).filter_by(company_id=user.company_id).delete()
    for item in data.steps:
        db.add(ApprovalStep(
            company_id=user.company_id,
            approver_id=item.approver_id,
            step_order=item.step_order,
            required=item.required
        ))
    db.commit()
    return {"msg":"Approval steps updated"}


@router.post("/expenses/{expense_id}/override")
def override_expense(expense_id:int,
                     status:str="APPROVED",
                     user=Depends(get_current_user),
                     db:Session=Depends(get_db)):
    _ensure_admin(user)
    expense=db.query(Expense)\
        .filter_by(id=expense_id,company_id=user.company_id).first()
    if not expense:
        raise HTTPException(status_code=404, detail="Expense not found")

    expense.status=status
    approvals=db.query(Approval).filter_by(expense_id=expense_id).all()
    for approval in approvals:
        if status == "APPROVED":
            approval.status="APPROVED"
        elif status == "REJECTED":
            approval.status="REJECTED"
        else:
            approval.status="CANCELLED"
    db.commit()
    return {"msg":"Expense overridden"}
