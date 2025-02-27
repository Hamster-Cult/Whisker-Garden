from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column
from datetime import date

class Garden(SQLModel, table=True):
  garden_slot: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field("foriegn_key="plant.plant_id", nullable=False)
  name: str = Field(max_length=20, nullable=False)
  archived: bool = Field(nullable=False)
  maturity: int = Field(nullable=False)
  last_watered: date = Field(nullable=False)

  

