

# Electric Car
def electric_car_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["car_fuel"] = "electric"
    new_adjusted["car_fuel"] = "electric"
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
    new_global["weekly_mileage"] = max(0, global_state["weekly_mileage"] - 2)
    new_adjusted["weekly_mileage"] = max(0, adjusted_state["weekly_mileage"] - 2)
    return new_global, new_adjusted