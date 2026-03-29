from sqlalchemy import Column,Integer,Float,Boolean
from app.core.database import Base

class ApprovalRule(Base):
    __tablename__="approval_rules"

    id=Column(Integer,primary_key=True)
    company_id=Column(Integer)

    percentage_required=Column(Float,nullable=True)
    specific_approver_id=Column(Integer,nullable=True)
    manager_first=Column(Boolean,default=True)