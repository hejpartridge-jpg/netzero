# backend/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from calculator import calculate_total_emissions

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

@app.get("/")
def root():
    return {"status": "running"}