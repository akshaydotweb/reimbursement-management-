from pydantic import BaseModel
from typing import Optional,List

class ApprovalAction(BaseModel):
    action:str

class ApprovalRuleUpdate(BaseModel):
    percentage_required:Optional[float]=None
    specific_approver_id:Optional[int]=None
    manager_first:Optional[bool]=True

class ApprovalStepItem(BaseModel):
    approver_id:int
    step_order:int
    required:Optional[bool]=True

class ApprovalStepUpdate(BaseModel):
    steps:List[ApprovalStepItem]
