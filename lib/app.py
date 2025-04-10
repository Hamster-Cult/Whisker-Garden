from typing import Annotated, Union
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from fastapi.middleware.cors import CORSMiddleware
from database import *
from json import *

postgresql_url = "postgresql://:@localhost/whisker"

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
    # have plants and stuff in the db from a fresh install
    # why do we recreate the db and tables whenever the server is started?
    # shouldn't we have it static???
    create_plants()
    create_garden()
    create_user()
    create_garden()

@app.get("/user/plant")
def get_plant_asset():
    with Session(engine) as session:
        return session.exec(select(Plant)).all()
    #plant_id = session.get(Garden, plant_id)
    #maturity = session.get(Garden, maturity)
    #if not hero:
        #raise HTTPException(status_code=404, detail="Hero not found")

@app.get("/exp")
def get_exp():
    with Session(engine) as session:
        return session.exec(select(AppUser)).all()
    
@app.get("/garden/last")
def get_exp():
    with Session(engine) as session:
        return session.exec(select(Garden)).all()


@app.post("/entry")
def create_entry(entry: Entries, session: SessionDep):
    with Session(engine) as session:
        session.add(entry)
        session.commit()

@app.get("/entries")
def get_entries(session: SessionDep):
    with Session(engine) as session:
        return session.exec(select(Entries).all())

# let the user write their username?
def create_user():
    with Session(engine) as session:
        user = AppUser(username='default user', plant_id=1, level=1, exp=200)
        session.add(user)
        session.commit()

def create_plants():
    with Session(engine) as session:
        plant_1 = Plant(plant_type='tulips', unlocked=True) # default plant
        plant_2 = Plant(plant_type='hibiscus')

        session.add(plant_1)
        session.add(plant_2)
        session.commit()

def create_garden():
    with Session(engine) as session:
        garden_plant = Garden(
            plant_id=1, 
            name='default tulip', 
            archived=False, 
            maturity=2, 
            last_watered='2025-04-03')
        
        session.add(garden_plant)
        session.commit()
