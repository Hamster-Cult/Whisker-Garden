from typing import Annotated, Union
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from fastapi.middleware.cors import CORSMiddleware
from database import *
from json import *

# url for the database
postgresql_url = "postgresql://:@localhost/whisker"

# create the database engine
engine = create_engine(postgresql_url)

# create the database tables
# takes from database.py
def create_db_and_tables():
    SQLModel.metadata.create_all(engine)

# makes an instance of the database and makes sure it's fastapi
def get_session():
    with Session(engine) as session:
        yield session

SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

# database, server, and app are on all different ports, so this allows cross-communication
app.add_middleware(

    CORSMiddleware,

    allow_origins=["*"], # Or specify allowed origins like ["http://localhost:3000"]

    allow_credentials=True,

    allow_methods=["*"], # Allows all HTTP methods

    allow_headers=["*"], # Allows all headers
)

# runs when the server starts up
@app.on_event("startup")
def on_startup():
    create_db_and_tables()
    # have plants and stuff in the db from a fresh install
    # why do we recreate the db and tables whenever the server is started?
    # shouldn't we have it static???
    #create_plants()
    #create_garden()
    #create_user()
   # create_garden()

@app.get("/user/plant")
def get_plant_asset():
    with Session(engine) as session:
        return session.exec(select(Plant)).all()
    #if not hero:
        #raise HTTPException(status_code=404, detail="Hero not found")


# defines each path in a link and what it does

@app.get("/exp")
def get_exp():
    with Session(engine) as session:
        results = session.exec(
            select(
                AppUser.level, 
                AppUser.exp)
            .limit(1)
            ).all()
        results_json = []
        for level, exp in results:
            results_json.append({
                "level": level,
                "exp": exp})
        return results_json
    
@app.get("/garden/current-details")
def get_exp():
    with Session(engine) as session:
        results = session.exec(
            select(
                Garden.plant_id, 
                Garden.last_watered, 
                Garden.maturity)
            .where(Garden.archived == False)
            ).all()
        results_json = []
        for plant_id, last_watered, maturity in results:
            results_json.append({
                "plant_id": plant_id,
                "last_watered": last_watered, 
                "maturity": maturity})
        return results_json

@app.post("/entry")
def create_entry(entry: Entries, session: SessionDep):
    with Session(engine) as session:
        session.add(entry)
        session.commit()

@app.get("/entries/{page_number}")
def get_entries(page_number: int, session: SessionDep):
    with Session(engine) as session:
        offset = 4 * (page_number - 1)
        return session.exec(
            select(Entries)
            .offset(offset)
            .limit(4)).all()

# example data used, default data.

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
