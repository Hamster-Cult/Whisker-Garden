from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class UserEntries(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.user_id", nullable=False)
    entry_id: int = Field(foreign_key="entries.entry_id", nullable = False)
    