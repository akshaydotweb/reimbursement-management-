from fastapi import APIRouter,Depends,HTTPException
from sqlalchemy.orm import Session

from app.schemas.auth import Signup,Login
from app.core.database import get_db
from app.models.company import Company
from app.models.user import User
from app.core.security import hash_password,verify_password,create_token
from app.services.currency import get_country_currency

router=APIRouter()

@router.post("/signup")
def signup(data:Signup,db:Session=Depends(get_db)):

    currency=get_country_currency(data.country)

    company=Company(
        name=data.company_name,
        base_currency=currency
    )
    db.add(company)
    db.commit()
    db.refresh(company)

    user=User(
        email=data.email,
        password=hash_password(data.password),
        role="ADMIN",
        company_id=company.id
    )

    db.add(user)
    db.commit()

    return {"msg":"Company Created"}

@router.post("/login")
def login(data:Login,db:Session=Depends(get_db)):

    user=db.query(User).filter_by(email=data.email).first()

    if not user or not verify_password(data.password,user.password):
        raise HTTPException(400,"Invalid Credentials")

    token=create_token({"id":user.id})

    return {"access_token":token}