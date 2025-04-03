from typing import Union, Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Field, Session, SQLModel, create_engine, select
from Models.users import User
from backend import SessionDep, create_db_and_tables
import json

app = FastAPI()

# Allow all origins (You can restrict this to specific domains for security)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify allowed origins like ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers
)

@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.post("/users/")
def create_user(user: User, session: SessionDep) -> User:
    session.add(user)
    session.commit()
    session.refresh(user)
    return user

@app.get("/users/")
def read_users(session: SessionDep, offset: int = 0,
    limit: Annotated[int, Query(le=100)] = 100) -> list[User]:
    users = session.exec(select(User).offset(offset).limit(limit)).all()
    return users

@app.get("/users/{user_id}")
def read_user(user_id: int, session: SessionDep) -> User:
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.delete("/users/{user_id}")
def delete_user(user_id: int, session: SessionDep):
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="User not found")
    session.delete(user)
    session.commit()
    return {"ok": True}

@app.get("/")
async def read_root_http():
    f = open('lib\data.json')
    data = json.load(f)
    f.close()
    return data

@app.get("/garden/last_watered")
async def read_last_watered():
    f = open('lib\data.json')
    data = json.load(f)
    f.close()
    return data

@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}