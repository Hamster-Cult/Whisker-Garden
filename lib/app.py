# Uhh I need to figure out how to merge the firebase files but for now
# This currently just fetches the (hardcoded) exp value from the data.json file

from fastAPI import FastAPI
import json
from fastapi.middleware.cors import CORSMiddleware # Allows fetching from different ports (don't ask how this works rn pls)

app = FastAPI()


# Allow all origins (You can restrict this to specific domains for security)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Or specify allowed origins like ["http://localhost:3000"]
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods
    allow_headers=["*"],  # Allows all headers
)

@app.get("/")
async def read_root_http():
    f = open('data.json')
    data = json.load(f)
    f.close()
    return data