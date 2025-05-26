# file for database this is where the database is created and the tables are defined

from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column
from datetime import date, time

class AppUser(SQLModel, table=True):
  user_id: int | None = Field(default=None, primary_key=True)
  garden_slot: int = Field(foreign_key="garden.garden_slot", nullable=False)
  username: str = Field(max_length=20, nullable=False)
  level: int = Field (nullable=False, min_length=0)
  exp: int = Field (nullable=False, min_length=0)
  spendable_exp: int = Field(nullable=False, min_length=0)

class Plant(SQLModel, table=True):
  plant_id: int | None = Field(default=None, primary_key=True)
  plant_type: str = Field(max_length=20, nullable=False)
  unlocked: bool = Field(nullable=False, default=False) # might throw an error
  price: int = Field(nullable=True)

class Goals(SQLModel, table=True):
  goal_id: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
  name: str = Field (max_length=50, nullable=False)
  desc: str | None = Field (default=None)
  achieved: bool = Field(nullable=True, default=False)
  exp_increase: int = Field(nullable=False)

class Garden(SQLModel, table=True):
  garden_slot: int | None = Field(default=None, primary_key=True)
  plant_id: int = Field(foreign_key="plant.plant_id", nullable=False)
  name: str = Field(max_length=20, nullable=False)
  archived: bool = Field(nullable=False, default=False)
  maturity: int = Field(nullable=False) # add max maturity?
  # stores the total amount of exp gained for a plant to calculate
  # the maturity
  plant_exp: int = Field(nullable=False, max_length=150, default=0)
  last_watered: date = Field(nullable=False, default_factory=date.today)

class Entries(SQLModel, table=True):
  entry_id: int | None = Field(default=None, primary_key=True)
  entry: str = Field(max_length=255, nullable=False)
  entry_date: date = Field(nullable=False)
  entry_time: time = Field(nullable=False)
  rating: int = Field(nullable=False, min_length=0, max_length=5)