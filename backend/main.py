# backend/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from calculator import calculate_total_emissions
from recommendations import get_recommendations
from reductions.initial_state import build_initial_state

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
    global_state, adjusted_state, co2_state = build_initial_state(profile)
    return calculate_total_emissions(global_state)

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