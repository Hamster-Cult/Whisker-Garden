from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class Entries(SQLModel, table=True):
    entry_id: int | None = Field(default=None, primary_key=True)
    entry = Field(str, nullable=False)