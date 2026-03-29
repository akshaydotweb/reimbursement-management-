from sqlalchemy import Column,Integer,Boolean
from app.core.database import Base

class ApprovalStep(Base):
    __tablename__="approval_steps"

    id=Column(Integer,primary_key=True,index=True)
    company_id=Column(Integer)
    approver_id=Column(Integer)
    step_order=Column(Integer)
    required=Column(Boolean,default=True)
