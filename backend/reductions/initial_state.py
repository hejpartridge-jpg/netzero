from calculator import calculate_total_emissions

def build_initial_state(profile: dict) -> dict:
    total_energy = profile["annual_gas_kwh"] + profile["annual_electricity_kwh"]
    cooking_energy = total_energy * 0.03
    
    if profile.get("fuel_type") == "heat_pump":
        heating_baseline = profile["annual_electricity_kwh"] * 0.78
    elif profile.get("hob_type") == "gas":
        heating_baseline = profile["annual_gas_kwh"] - cooking_energy
    else:
        heating_baseline = profile["annual_gas_kwh"]
    
    if profile.get("fuel_type") == "heat_pump":        
        non_heating_electricity = profile["annual_electricity_kwh"] * (1 - 0.78)
        lighting_baseline = non_heating_electricity * 0.15
        socket_baseline   = non_heating_electricity * 0.75
    elif profile.get("hob_type") == "electric":
        non_cooking_electricity = profile["annual_electricity_kwh"] - cooking_energy
        lighting_baseline = non_cooking_electricity * 0.03
        socket_baseline   = non_cooking_electricity * 0.15
    else:
        lighting_baseline = profile["annual_electricity_kwh"] * 0.03
        socket_baseline   = profile["annual_electricity_kwh"] * 0.15

    shared = {
        "annual_gas_kwh":           profile["annual_gas_kwh"],
        "annual_electricity_kwh":   profile["annual_electricity_kwh"],
        "lighting_baseline":        lighting_baseline,
        "socket_baseline":          socket_baseline,
        "cooking_baseline":         cooking_energy,
        "heating_baseline":         heating_baseline,
        "heating_electricity_kwh":  heating_baseline if profile.get("fuel_type") == "heat_pump" else 0,
        "water_heating_kwh":        heating_baseline * 0.23,
        **profile,
    }

    global_state  = shared.copy()  # only updated by global actions
    adjusted_state = shared.copy() # updated by all actions

    co2_state = {
        "total_co2": calculate_total_emissions(global_state)["total_kg_co2e"]
    }

    return global_state, adjusted_state, co2_state