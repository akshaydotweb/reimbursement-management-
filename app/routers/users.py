from fastapi import APIRouter,Depends
from sqlalchemy.orm import Session

from app.dependencies.auth import get_current_user
from app.core.database import get_db
from app.models.user import User
from app.schemas.user import CreateUser

router=APIRouter()

@router.post("/create-user")
def create_user(data:CreateUser,
                user=Depends(get_current_user),
                db:Session=Depends(get_db)):

    new_user=User(
        email=data.email,
        password="temp123",
        role=data.role,
        company_id=user.company_id,
        manager_id=data.manager_id
    )

    db.add(new_user)
    db.commit()

    return {"msg":"User created"}