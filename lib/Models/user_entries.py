from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class UserEntries(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.user_id", primary_key=True)
    entry_id: int = Field(foreign_key="entries.entry_id", primary_key=True)
    