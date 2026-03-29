from pydantic import BaseModel
from typing import Optional

class ExpenseCreate(BaseModel):
    amount:float
    currency:str
    description:str
    category:str
    expense_date:Optional[str]=None
    paid_by:Optional[str]=None
    remarks:Optional[str]=None
    receipt_url:Optional[str]=None
