from app.models.approval import Approval
from app.models.user import User
from app.models.rule import ApprovalRule
from app.models.approval_step import ApprovalStep

def generate_approval_flow(expense,db):

    user=db.query(User).get(expense.user_id)
    rule=db.query(ApprovalRule)\
        .filter_by(company_id=expense.company_id).first()

    if not rule:
        rule=ApprovalRule(
            company_id=expense.company_id,
            percentage_required=None,
            specific_approver_id=None,
            manager_first=True
        )
        db.add(rule)
        db.commit()

    steps=db.query(ApprovalStep)\
        .filter_by(company_id=expense.company_id)\
        .order_by(ApprovalStep.step_order.asc())\
        .all()

    approver_sequence=[]
    if rule.manager_first and user.manager_id:
        approver_sequence.append(user.manager_id)

    for step in steps:
        if step.approver_id not in approver_sequence:
            approver_sequence.append(step.approver_id)

    if rule.specific_approver_id and rule.specific_approver_id not in approver_sequence:
        approver_sequence.append(rule.specific_approver_id)

    if not approver_sequence:
        expense.status="APPROVED"
        db.commit()
        return

    for idx, approver_id in enumerate(approver_sequence, start=1):
        approval=Approval(
            expense_id=expense.id,
            approver_id=approver_id,
            step_order=idx,
            status="PENDING" if idx == 1 else "WAITING"
        )
        db.add(approval)

    db.commit()


def check_approval_completion(expense_id,db):

    approvals=db.query(Approval)\
        .filter_by(expense_id=expense_id).all()

    if any(a.status=="REJECTED" for a in approvals):
        from app.models.expense import Expense
        exp=db.query(Expense).get(expense_id)
        exp.status="REJECTED"
        db.commit()
        return

    if not approvals:
        return

    from app.models.expense import Expense
    expense=db.query(Expense).get(expense_id)
    rule=db.query(ApprovalRule)\
        .filter_by(company_id=expense.company_id).first()

    approved=[a for a in approvals if a.status=="APPROVED"]
    total=len(approvals)

    if rule and rule.specific_approver_id:
        if any(a.approver_id==rule.specific_approver_id and a.status=="APPROVED" for a in approvals):
            from app.models.expense import Expense
            exp=db.query(Expense).get(expense_id)
            exp.status="APPROVED"
            for a in approvals:
                if a.status=="WAITING":
                    a.status="CANCELLED"
            db.commit()
            return

    if rule and rule.percentage_required:
        if total and (len(approved) / total) * 100 >= rule.percentage_required:
            from app.models.expense import Expense
            exp=db.query(Expense).get(expense_id)
            exp.status="APPROVED"
            for a in approvals:
                if a.status=="WAITING":
                    a.status="CANCELLED"
            db.commit()
            return

    if all(a.status=="APPROVED" for a in approvals):
        from app.models.expense import Expense
        exp=db.query(Expense).get(expense_id)
        exp.status="APPROVED"
        db.commit()
        return

    # Advance to next approver in sequence if no pending remains
    pending_step = next((a for a in approvals if a.status=="PENDING"), None)
    if not pending_step:
        next_steps=[a for a in approvals if a.status=="WAITING"]
        if next_steps:
            next_steps.sort(key=lambda a: a.step_order)
            next_steps[0].status="PENDING"
            db.commit()
