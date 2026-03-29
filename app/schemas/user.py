from pydantic import BaseModel

class CreateUser(BaseModel):
    email:str
    password:str
    role:str
    manager_id:int|None=None