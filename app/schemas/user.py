from pydantic import BaseModel

class CreateUser(BaseModel):
    email:str
    role:str
    manager_id:int|None=None