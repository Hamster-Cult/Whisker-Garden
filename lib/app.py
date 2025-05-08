from typing import Annotated, Union
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select
from sqlalchemy.exc import SQLAlchemyError
from fastapi.middleware.cors import CORSMiddleware
from lib.database import *
from json import *


# url for the database
postgresql_url = "postgresql://:@localhost/whisker"

# create the database engine
engine = create_engine(postgresql_url)

# create the database tables
# takes from database.py
def create_db_and_tables():
    try:
        SQLModel.metadata.create_all(engine)
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error creating tables: {e}")

# makes an instance of the database and makes sure it's fastapi
def get_session():
    try:
        with Session(engine) as session:
            yield session
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error creating session: {e}")

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

# if any of the functions fail, an exception is raised
@app.get("/setup/{username}") 
def on_startup(username: str):
    create_db_and_tables()
    create_plants()
    create_garden()
    create_user(username)
    create_goals()

@app.get("/user/plant")
def get_plant_asset():
    try:
        with Session(engine) as session:
            plants = session.exec(select(Plant)).all()
            if not plants:
                raise HTTPException(status_code=404, detail="Error 404: Plants not found")
            return plants
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving plant assets: {e}")
    #if not hero:
        #raise HTTPException(status_code=404, detail="Hero not found")


# defines each path in a link and what it does

@app.get("/exp")
def get_exp():
    try:
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
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving User EXP: {e}")

@app.get("/garden/current-details")
def get_exp():
    try:
        with Session(engine) as session:
            results = session.exec(
                select(
                    Garden.plant_id,
                    Garden.last_watered,
                    Garden.maturity,
                    Garden.plant_exp,
                    Garden.garden_slot,
                    Garden.archived)
                .where(Garden.archived == False)
                ).all()
            if not results:
                raise HTTPException(status_code=404, detail="Error 404: Garden not found ")
            results_json = []
            for plant_id, last_watered, maturity, plant_exp, garden_slot, archived in results:
                results_json.append({
                    "plant_id": plant_id,
                    "last_watered": last_watered,
                    "maturity": maturity,
                    "plant_exp": plant_exp,
                    "garden_slot": garden_slot,
                    "archived": archived,
                    })
            return results_json
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving garden progress: {e}")

@app.post("/entry")
def create_entry(entry: Entries, session: SessionDep):
    try:
        with Session(engine) as session:
            session.add(entry)
            session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating entry: {e}")

@app.post("/buy")
def buy_plant(plant: Plant, session: SessionDep):
    try:
        with Session(engine) as session:
            session.add(Plant)
            session.commit()
    except exceptSQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"error buying plant: {e}")

@app.post('/water')
def water_plant(user: AppUser, session: SessionDep):
    try:
        with Session(engine) as session:
            dbUser = session.exec(
                select(AppUser)
                .where(AppUser.user_id == 1)).one()

            dbUser.level = user.level
            dbUser.exp = user.exp
            session.add(dbUser)
            session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating user data: {e}")

@app.post('/water/plant')
def water_plant(plant: Garden, session: SessionDep):
    try:
        with Session(engine) as session:
            dbGarden = session.exec(select(Garden).where(Garden.archived == False)).one()

            dbGarden.maturity = plant.maturity
            dbGarden.plant_exp = plant.plant_exp
            dbGarden.last_watered = plant.last_watered
            session.add(dbGarden)
            session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error updating garden data: {e}")

@app.get("/entries/{page_number}")
def get_entries(page_number: int, session: SessionDep):
    try:
        with Session(engine) as session:
            offset = 4 * (page_number - 1)
            return session.exec(
                select(Entries)
                .offset(offset)
                .limit(4)).all()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error retrieving entries: {e}")

@app.get("/garden/{page_number}")
def get_entries(page_number: int, session: SessionDep):
    try:
        with Session(engine) as session:
            offset = 16 * (page_number - 1)
            return session.exec(
                select(Garden)
                .offset(offset)
                .limit(16)).all()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error retrieving entries: {e}") # copy pasted the code pls fix the error handling

@app.get("/unlocked")
def get_entries(session: SessionDep):
    try:
        with Session(engine) as session:
            return session.exec(
                select(Plant)
                .where(Plant.unlocked == True)).all()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error retrieving entries: {e}") # copy pasted the code pls fix the error handling

@app.get("/locked")
def get_entries(session: SessionDep):
    try:
        with Session(engine) as session:
            return session.exec(
                select(Plant)
                .where(Plant.unlocked == False)).all()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error retrieving entries: {e}") # copy pasted the code pls fix the error handling


@app.get("/user")
def get_user_data():
    try:
        with Session(engine) as session:
            user = session.exec(select(AppUser).where(AppUser.user_id == 1)).all()
            if not user:
                raise HTTPException(status_code=404, detail="Error 404: User not found")
            return user
    except SQLAlchemyError as e:
        raise HTTPException(status_code=500, detail=f"Error retreiving user data: {e}")

def month_days(month):
    days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31] # no support for leap years lmao
    return days[int(month)]

@app.get("/calendar/{start_date}")
def view_month(start_date: date, session: SessionDep):
    try:
        with Session(engine) as session:
            start_date_str = start_date.strftime("Y-m-d")
            year = start_date_str[0:5]
            month = start_date_str[5:7]
            end_date = start_date_str[0:8] + str(month_days(month))
            end_date = datetime.strptime(end_date, "Y-m-d").date()
            return session.exec(
                select(Entries.entry_date)
                .where(between(
                    Entries.entry_date,
                    start_date,
                    end_date))
                    ).all()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error viewing month: {e}")


@app.get("/delete")
def delete_user(session: SessionDep):
    try:
        with Session(engine) as session:
            SQLModel.metadata.drop_all(engine)
            SQLModel.metadata.create_all(engine)
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error deleting user: {e}")

# example data used, default data.

# figure out a way to initialize the app
# let the user write their username?
# allow the user to pick from 3 different starting plants
def create_user(name: str):
    try:
        with Session(engine) as session:
            user = AppUser(
                username=name,
                garden_slot=2,# make sure it's linked properly
                level=1,
                exp=0,
                spendable_exp=0)
            session.add(user)
            session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating user: {e}")

def create_plants():
    try:
        with Session(engine) as session:
            plant_1 = Plant(
                plant_type='tulips',
                price = 10)
            plant_2 = Plant(
                plant_type='hibiscus',
                price = 20)
            plant_3 = Plant(
                plant_type='hydrengea',
                price = 30)
            plant_4 = Plant(
                plant_type='wisteria',
                price = 40)
            plant_5 = Plant(
                plant_type='cherry blossom',
                price=50)
            plant_6 = Plant(
                plant_type='rose',
                price=60)
            plant_7 = Plant(
                plant_type='bluebell',
                price=70)
            plant_8 = Plant(
                plant_type='lily of the valley',
                unlocked=True) # default
            plant_9 = Plant(
                plant_type='spider lily',
                price=80)
            plant_10 = Plant(
                plant_type='aster',
                price=90)

            plants = [plant_1, plant_2, plant_3, plant_4, plant_5, plant_6, plant_7, plant_8, plant_9, plant_10]
            for plant in plants:
                session.add(plant)
            session.commit()
    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating plants: {e}")

def create_garden():
    try:
        with Session(engine) as session:
            default_plant = Garden(
                plant_id=8,
                name='ponyo',
                archived=False,
                maturity=1)
            pre_built_plant = Garden(
                plant_id=8,
                name='sunny',
                archived=True,
                maturity=5,
                plant_exp=150,
                last_watered='2025-04-03')

            session.add(pre_built_plant)
            session.add(default_plant)
            session.commit()

    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating garden: {e}")

# pre-designed goals
def create_goals():
    try:
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

    except SQLAlchemyError as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Error creating goals: {e}")
