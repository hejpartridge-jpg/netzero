# backend/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from calculator import calculate_total_emissions
from recommendations import get_recommendations

app = FastAPI()

# Allow Flutter to talk to the backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/calculate")
def calculate(profile: dict) -> dict:
    return calculate_total_emissions(profile)

@app.post("/recommendations")
def recommendations(payload: dict) -> dict:
    return get_recommendations(
        payload["profile"],
        payload.get("completed_actions", []),
        payload.get("dismissed_actions", []),
    )
    
@app.get("/")
def root():
    return {"status": "running"}