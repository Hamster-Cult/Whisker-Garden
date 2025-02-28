from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column



class User(SQLModel, table=True):
   user_id: int | None = Field(default=None, primary_key=True)
   plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
   username: str = Field(max_length=20, nullable=False)
   level: int = Field (int, nullable=False, min_length=0)
   exp: int = Field (int, nullable=False, min_length=0)


