from sqlalchemy import Column,Integer,String,Float,ForeignKey
from app.core.database import Base

class Expense(Base):
    __tablename__="expenses"

    id=Column(Integer,primary_key=True,index=True)
    user_id=Column(Integer)
    company_id=Column(Integer)

    amount=Column(Float)
    currency=Column(String)

    description=Column(String)
    category=Column(String)

    status=Column(String,default="DRAFT")