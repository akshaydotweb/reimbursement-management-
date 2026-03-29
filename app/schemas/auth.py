from pydantic import BaseModel

class Signup(BaseModel):
    email:str
    password:str
    company_name:str
    country:str

class Login(BaseModel):
    email:str
    password:str