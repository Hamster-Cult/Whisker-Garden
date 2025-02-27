from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column

class goals(SQLModel, table=True):
  goal_id: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
  goal_name: str = Field (max_length=50, nullable=False)
  goal_desc: str | None = Field (default=None)
  goal_achievement: bool = Field(nullable=False)
