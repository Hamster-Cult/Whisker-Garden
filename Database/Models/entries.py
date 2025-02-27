from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from datetime import datetime, date, time
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class Entries(SQLModel, table=True):
    entry_id: int | None = Field(default=None, primary_key=True)
    entry: str = Field(max_length=255, nullable=False)
    entry_date: date = Field(nullable=False)
    entry_time: time = Field(nullable=False)
    rating: int = Field(nullable=False, min_length=0, max_length=5)