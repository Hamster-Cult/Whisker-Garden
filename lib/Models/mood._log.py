from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column
from datetime import date, time


class mood_log(SQLModel, table=True):
  mood_id: int | None = Field(default=None, primary_key=True)
  mood_date: date = Field (nullable=False)
  mood_time: time =  Field (nullable=False)
  mood_rating: int = Field (nullable=False, ge=1, le=5 )
  mood_text: str | None = Field (default=None)




 
