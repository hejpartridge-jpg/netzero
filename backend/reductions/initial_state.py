from calculator import calculate_total_emissions
from emission_factors import ELECTRICITY_MONTHLY_FACTORS, SOLAR_MONTHLY_FACTORS, GAS_MONTHLY_FACTORS

def build_initial_state(profile: dict) -> dict:

    billing_month = profile.get("billing_month")
    monthly_gas_weighting = GAS_MONTHLY_FACTORS[billing_month]
    yearly_gas_spend = profile.get("monthly_gas_spend")/monthly_gas_weighting
    yearly_gas_kwh = yearly_gas_spend/0.0733

    monthly_solar_weighting = SOLAR_MONTHLY_FACTORS[billing_month]
    solar_self_consumed_kwh = profile.get("monthly_solar")/monthly_solar_weighting

    monthly_elec_weighting = ELECTRICITY_MONTHLY_FACTORS[billing_month]
    yearly_elec_spend = profile.get("monthly_elec_spend")/monthly_elec_weighting
    yearly_elec_kwh = solar_self_consumed_kwh + yearly_elec_spend/0.2611

    yearly_water_spend = profile.get("monthly_water_spend") * 12
    annual_water_m3 = yearly_water_spend/4.21

    
    total_energy = yearly_gas_kwh + yearly_elec_kwh
    
    cooking_energy = total_energy * 0.03
    
    if profile.get("fuel_type") == "heat_pump":
        heating_baseline = yearly_elec_kwh * 0.78
    elif profile.get("hob_type") == "gas":
        heating_baseline = yearly_gas_kwh - cooking_energy
    else:
        heating_baseline = yearly_gas_kwh
    
    if profile.get("fuel_type") == "heat_pump":        
        non_heating_electricity = yearly_elec_kwh * (1 - 0.78)
        lighting_baseline = non_heating_electricity * 0.15
        socket_baseline   = non_heating_electricity * 0.75
    elif profile.get("hob_type") == "electric":
        non_cooking_electricity = yearly_elec_kwh - cooking_energy
        lighting_baseline = non_cooking_electricity * 0.03
        socket_baseline   = non_cooking_electricity * 0.15
    else:
        lighting_baseline = yearly_elec_kwh * 0.03
        socket_baseline   = yearly_elec_kwh * 0.15

    shared = {
        **profile,
        "annual_gas_kwh":           yearly_gas_kwh,
        "annual_electricity_kwh":   yearly_elec_kwh,
        "lighting_baseline":        lighting_baseline,
        "socket_baseline":          socket_baseline,
        "cooking_baseline":         cooking_energy,
        "heating_baseline":         heating_baseline,
        "heating_electricity_kwh":  heating_baseline if profile.get("fuel_type") == "heat_pump" else 0,
        "water_heating_kwh":        heating_baseline * 0.23,
        "solar_self_consumed_kwh":  solar_self_consumed_kwh,
        "annual_water_m3":          annual_water_m3,
    }

    global_state  = shared.copy()  # only updated by global actions
    adjusted_state = shared.copy() # updated by all actions

    co2_state = {
        "total_co2": calculate_total_emissions(global_state)["total_kg_co2e"]
    }

    return global_state, adjusted_state, co2_state