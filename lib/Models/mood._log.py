<<<<<<< HEAD
=======
<<<<<<<< HEAD:Database/Models/mood._log.py
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




 
========
>>>>>>> ed8b4257907ace75124e121a3ba78aa69f4f7b06
from typing import Annotated
from fastapi import Depends, FastAPI, HTTPException, Query
from sqlmodel import Field, Session, SQLModel, create_engine, select, Column
from datetime import date, time


class mood_log(SQLModel, table=True):
  mood_id: int | None = Field(default=None, primary_key=True)
<<<<<<< HEAD
  mood_date: date = Field (nullable=False)
=======
  mood_date: date = Field (date, nullable=False)
>>>>>>> ed8b4257907ace75124e121a3ba78aa69f4f7b06
  mood_time: time =  Field (nullable=False)
  mood_rating: int = Field (nullable=False, ge=1, le=5 )
  mood_text: str | None = Field (default=None)




 
<<<<<<< HEAD
=======
>>>>>>>> ed8b4257907ace75124e121a3ba78aa69f4f7b06:lib/Models/mood._log.py
>>>>>>> ed8b4257907ace75124e121a3ba78aa69f4f7b06
