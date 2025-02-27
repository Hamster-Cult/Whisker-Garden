from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class Plant(SQLModel, table=True):
    plant_id: int | None = Field(default=None, primary_key=True)
    plant_type: str = Field(max_length=20, nullable=False)
    