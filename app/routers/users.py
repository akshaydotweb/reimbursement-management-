from fastapi import APIRouter,Depends,HTTPException
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.user import CreateUser

from passlib.context import CryptContext
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

router=APIRouter()

def _to_dict(user):
    return {
        "id": user.id,
        "email": user.email,
        "role": user.role,
        "company_id": user.company_id,
        "manager_id": user.manager_id
    }

@router.get("/")
def list_users(user=Depends(get_current_user),
               db:Session=Depends(get_db)):

    if user.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Not allowed")

    users=db.query(User)\
        .filter_by(company_id=user.company_id).all()

    return [_to_dict(u) for u in users]


@router.get("/me")
def me(user=Depends(get_current_user)):
    return _to_dict(user)


@router.post("/create-user")
def create_user(data:CreateUser,
                user=Depends(get_current_user),
                db:Session=Depends(get_db)):

    if user.role != "ADMIN":
        raise HTTPException(status_code=403, detail="Not allowed")

    hashed_password = pwd_context.hash(data.password)

    new_user=User(
        email=data.email,
        password=hashed_password,
        role=data.role,
        company_id=user.company_id,
        manager_id=data.manager_id
    )

    db.add(new_user)
    db.commit()

    return {"msg":"User created"}
