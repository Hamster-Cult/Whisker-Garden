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


@app.get("/setup") # setup database with inserts
def on_startup():
    create_db_and_tables()
    create_plants()
    create_garden()
    create_user()
    create_garden()
    create_goals()

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
                Garden.maturity,
                Garden.plant_exp,
                Garden.archived)
            .where(Garden.archived == False)
            ).all()
        results_json = []
        for plant_id, last_watered, maturity, archived, plant_exp in results:
            results_json.append({
                "plant_id": plant_id,
                "last_watered": last_watered,
                "archived": plant_exp, # no clue why thse two are swapped???
                "plant_exp": archived,
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

# figure out a way to initialize the app
# let the user write their username?
# allow the user to pick from 3 different starting plants
def create_user():
    with Session(engine) as session:
        user = AppUser(
            username='test user',
            plant_id=1,
            level=1,
            exp=0)
        session.add(user)
        session.commit()

def create_plants():
    with Session(engine) as session:
        plant_1 = Plant(
            plant_type='tulips',
            unlocked=True) # default plant
        plant_2 = Plant(
            plant_type='hibiscus')
        plant_3 = Plant(
            plant_type='hydrengea')
        plant_4 = Plant(
            plant_type='wisteria')
        plant_5 = Plant(
            plant_type='cherry blossom')
        plant_6 = Plant(
            plant_type='rose')
        plant_7 = Plant(
            plant_type='bluebell')
        plant_8 = Plant(
            plant_type='lily of the valley')
        plant_9 = Plant(
            plant_type='spider lily')
        plant_10 = Plant(
            plant_type='aster')

        plants = [plant_1, plant_2, plant_3, plant_4, plant_5, plant_6, plant_7, plant_8, plant_9, plant_10]
        for plant in plants:
            session.add(plant)
        session.commit()

def create_garden():
    with Session(engine) as session:
        default_plant = Garden(
            plant_id=1, 
            name='ponyo', 
            archived=False, 
            maturity=2)
        pre_built_plant = Garden(
            plant_id=1, 
            name='sunny', 
            archived=True, 
            maturity=5,
            plant_exp=150,
            last_watered='2025-04-03')
        
        session.add(pre_built_plant)
        session.add(default_plant)
        session.commit()

# pre-designed goals
def create_goals():
    with Session(engine) as session:
        goal_1 = Goals(
            plant_id=1,
            name='hydrate',
            desc='drink 3 cups a day',
            exp_increase=30
        )
        goal_2 = Goals(
            plant_id=1,
            name='stretch',
            exp_increase=50
        )
        goal_3 = Goals(
            plant_id=1,
            name='touch grass',
            desc='I know what you are',
            exp_increase=100
        )
        goals = [goal_1, goal_2, goal_3]
        
        for goal in goals:
            session.add(goal)
        session.commit()