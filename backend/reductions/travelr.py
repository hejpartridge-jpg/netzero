

# Electric Car
def electric_car_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["cars"] = [{**car, "fuel": "electric"} for car in global_state.get("cars", [])]
    new_adjusted["cars"] = [{**car, "fuel": "electric"} for car in adjusted_state.get("cars", [])]
    return new_global, new_adjusted

# Economy Not Business/First
def economy_not_business_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["flights"] = [
        {**trip, "seat": "economy"} if trip["seat"] in ("business", "first") else trip
        for trip in global_state["flights"]
    ]
    new_adjusted["flights"] = [
        {**trip, "seat": "economy"} if trip["seat"] in ("business", "first") else trip
        for trip in adjusted_state["flights"]
    ]
    return new_global, new_adjusted

# 1 Less Car Journey
def less_car_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["cars"] = [
        {**car, "mileage": max(0, car.get("mileage", 0) - 2)}
        for car in global_state.get("cars", [])
    ]
    new_adjusted["cars"] = [
        {**car, "mileage": max(0, car.get("mileage", 0) - 2)}
        for car in adjusted_state.get("cars", [])
    ]
    return new_global, new_adjusted