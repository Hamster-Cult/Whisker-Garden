from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from Models.plant import Plant
from Models.users import User
from Models.garden import Garden
from Models.entries import Entries
from Models.goals import Goals
from Models.mood_log import MoodLog
from Models.user_entries import UserEntries



postgresql_url = "postgresql://keita:furry@localhost"

engine = create_engine(postgresql_url, echo=True)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)
    
def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]
