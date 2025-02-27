from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class garden(SQLModel, table=True):
  garden_slot: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field("foriegn_key="plant.plant_id", nullable=False)
