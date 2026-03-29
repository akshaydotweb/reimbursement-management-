from sqlalchemy import Column,Integer,String
from app.core.database import Base

class Approval(Base):
    __tablename__="approvals"

    id=Column(Integer,primary_key=True,index=True)
    expense_id=Column(Integer)
    approver_id=Column(Integer)
    step_order=Column(Integer)
    status=Column(String,default="PENDING")
    comment=Column(String,nullable=True)
