from app.models.approval import Approval
from app.models.user import User

def generate_approval_flow(expense,db):

    user=db.query(User).get(expense.user_id)

    if user.manager_id:
        approval=Approval(
            expense_id=expense.id,
            approver_id=user.manager_id,
            step_order=1
        )
        db.add(approval)

    db.commit()


def check_approval_completion(expense_id,db):

    approvals=db.query(Approval)\
        .filter_by(expense_id=expense_id).all()

    if all(a.status=="APPROVED" for a in approvals):
        from app.models.expense import Expense
        exp=db.query(Expense).get(expense_id)
        exp.status="APPROVED"
        db.commit()