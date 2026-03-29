from fastapi import Depends,HTTPException
from jose import JWTError
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordBearer

from app.core.security import decode_token
from app.core.database import get_db
from app.models.user import User

oauth2_scheme=OAuth2PasswordBearer(tokenUrl="login")

def get_current_user(
    token:str=Depends(oauth2_scheme),
    db:Session=Depends(get_db)
):
    try:
        payload=decode_token(token)
        user=db.query(User).get(payload["id"])
        return user
    except JWTError:
        raise HTTPException(401,"Invalid Token")