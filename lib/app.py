from typing import Annotated, Union
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from fastapi.middleware.cors import CORSMiddleware
from database import *

postgresql_url = "postgresql://:Gardens@localhost/whisker"

engine = create_engine(postgresql_url)

def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"], # Or specify allowed origins like ["http://localhost:3000"]

    allow_credentials=True,

    allow_methods=["*"], # Allows all HTTP methods

    allow_headers=["*"], # Allows all headers
)

@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.post("/entry/")
def create_entry(entry: Entries, session: SessionDep) -> Entries:
    session.add(entry)
    session.commit()
    session.refresh(entry)
    return entry

@app.get("/user/plant")
def get_plant_asset(plant_id: int, maturity: int, session: SessionDep) -> int:
    plant_id = session.get(Garden, plant_id)
    maturity = session.get(Garden, maturity)
    #if not hero:
        #raise HTTPException(status_code=404, detail="Hero not found")
    return plant_id

def create_plants():
    plant_1 = Plant(plant_type='tulips')
    plant_2 = Plant(plant_type='hibiscus')

def select_current_plant():
    with Session(engine) as session:
        statement = select(Garden)
        results = session.exec(statement)