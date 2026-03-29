from pydantic import BaseModel

class ExpenseCreate(BaseModel):
    amount:float
    currency:str
    description:str
    category:str