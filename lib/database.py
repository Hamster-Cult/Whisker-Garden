from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column
from datetime import date, time

class User(SQLModel, table=True):
   user_id: int | None = Field(default=None, primary_key=True)
   plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
   username: str = Field(max_length=20, nullable=False)
   level: int = Field (int, nullable=False, min_length=0)
   exp: int = Field (int, nullable=False, min_length=0)

class UserEntries(SQLModel, table=True):
    user_id: int = Field(foreign_key="user.user_id", primary_key=True)
    entry_id: int = Field(foreign_key="entries.entry_id", primary_key=True)
    
class Plant(SQLModel, table=True):
    plant_id: int | None = Field(default=None, primary_key=True)
    plant_type: str = Field(max_length=20, nullable=False)

class MoodLog(SQLModel, table=True):
  mood_id: int | None = Field(default=None, primary_key=True)
  mood_date: date = Field (nullable=False)
  mood_date: date = Field (date, nullable=False)
  mood_time: time =  Field (nullable=False)
  mood_rating: int = Field (nullable=False, ge=1, le=5 )
  mood_text: str | None = Field (default=None)

class Goals(SQLModel, table=True):
  goal_id: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
  goal_name: str = Field (max_length=50, nullable=False)
  goal_desc: str | None = Field (default=None)
  goal_achievement: bool = Field(nullable=False)

class Garden(SQLModel, table=True):
  garden_slot: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
  name: str = Field(max_length=20, nullable=False)
  archived: bool = Field(nullable=False)
  maturity: int = Field(nullable=False)
  last_watered: date = Field(nullable=False)

class Entries(SQLModel, table=True):
    entry_id: int | None = Field(default=None, primary_key=True)
    entry: str = Field(max_length=255, nullable=False)
    entry_date: date = Field(nullable=False)
    entry_time: time = Field(nullable=False)
    rating: int = Field(nullable=False, min_length=0, max_length=5)