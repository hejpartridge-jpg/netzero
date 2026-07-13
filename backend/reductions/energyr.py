from emission_factors import SOLAR_SYSTEM_SIZE_KW, INSULATION_KWH_SAVING, SOLAR_YEARLY_SUNLIGHT_HOURS, SOLAR_SELF_CONSUMPTION_RATE, BOILER_AGE

## the quiz responses are in the profile, for example in solar panels, you are getting
## the property type from profile so what the person answered in the quiz
## this will be a massive dictionary with everything I need in! :)

# Renewable Tariff
def renewable_tariff_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["tariff"] = "PPA"
    new_adjusted["tariff"] = "PPA"
    return new_global, new_adjusted


# Solar Panels
def solar_panels_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    system_size_kw = SOLAR_SYSTEM_SIZE_KW[property_type]
    yearly_production_kwh = system_size_kw * SOLAR_YEARLY_SUNLIGHT_HOURS
    self_consumed_kwh = yearly_production_kwh * SOLAR_SELF_CONSUMPTION_RATE
    new_global["solar_self_consumed_kwh"] = self_consumed_kwh
    new_global["solar_generated_kwh"] = yearly_production_kwh
    new_adjusted["solar_self_consumed_kwh"] = self_consumed_kwh
    new_adjusted["solar_generated_kwh"] = yearly_production_kwh
    return new_global, new_adjusted

# Battery Storage
def battery_storage_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    system_size_kw = SOLAR_SYSTEM_SIZE_KW[property_type]
    yearly_production_kwh = system_size_kw * SOLAR_YEARLY_SUNLIGHT_HOURS
    self_consumed_kwh = yearly_production_kwh * 0.775
    new_global["solar_self_consumed_kwh"] = self_consumed_kwh
    new_adjusted["solar_self_consumed_kwh"] = self_consumed_kwh
    return new_global, new_adjusted

#Thermostat 1 degree decrease
def one_degree_less_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    
    if global_state.get("fuel_type") == "heat_pump":
        old_heating = global_state["heating_electricity_kwh"]
        new_heating = old_heating * 0.87
        reduction = old_heating - new_heating
        new_global["heating_electricity_kwh"] = new_heating
        new_global["annual_electricity_kwh"] = global_state["annual_electricity_kwh"] - reduction
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        reduction = global_state["heating_baseline"] * 0.13
        new_global["annual_gas_kwh"] = global_state["annual_gas_kwh"] - reduction
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
    
    return new_global, new_adjusted

# Smart Thermostat
def smart_thermostat_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    
    if global_state.get("fuel_type") == "heat_pump":
        old_heating = global_state["heating_electricity_kwh"]
        new_heating = old_heating * 0.94
        reduction = old_heating - new_heating
        new_global["heating_electricity_kwh"] = new_heating
        new_global["annual_electricity_kwh"] = global_state["annual_electricity_kwh"] - reduction
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        reduction = global_state["heating_baseline"] * 0.06
        new_global["annual_gas_kwh"] = global_state["annual_gas_kwh"] - reduction
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
    
    return new_global, new_adjusted

#LED Lighting
def LED_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy() 
    new_global = global_state.copy()
    total_lighting_energy = global_state["lighting_baseline"]
    total_bulbs = (profile.get("incandescent_bulbs", 0) + 
                   profile.get("cfl_bulbs", 0) +  
                   profile.get("led_bulbs", 0))
    if total_bulbs == 0:
        return global_state, adjusted_state
    energy_per_bulb = total_lighting_energy / total_bulbs
    incandescent_reduction = profile.get("incandescent_bulbs", 0) * energy_per_bulb * 0.85
    cfl_reduction          = profile.get("cfl_bulbs", 0)          * energy_per_bulb * 0.308
    total_reduction = incandescent_reduction + cfl_reduction
    new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - total_reduction    
    new_adjusted["lighting_baseline"] = total_lighting_energy - total_reduction
    new_global["lighting_baseline"] = total_lighting_energy - total_reduction
    return new_global, new_adjusted

#Smart sockets
def smart_sockets_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy() 
    new_global = global_state.copy()
    socket_energy = global_state["socket_baseline"]
    new_energy = socket_energy * 0.7
    reduction = socket_energy - new_energy
    new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction    
    new_adjusted["socket_baseline"] = new_energy
    new_global["socket_baseline"] = new_energy
    return new_global, new_adjusted

# Heat Pumps
def heat_pumps_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    boiler_age = profile.get("boiler_age")
    boiler_efficiency = BOILER_AGE[boiler_age]
    efficiency_ratio = boiler_efficiency / 3.5
    hp_elec_needed = adjusted_state["heating_baseline"] * efficiency_ratio
    new_global["annual_electricity_kwh"] = global_state["annual_electricity_kwh"] + hp_elec_needed
    new_global["annual_gas_kwh"] = global_state["cooking_baseline"]  # only cooking gas remains
    new_global["heating_electricity_kwh"] = hp_elec_needed
    new_global["fuel_type"] = "heat_pump"
    new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] + hp_elec_needed
    new_adjusted["annual_gas_kwh"] = adjusted_state["cooking_baseline"]
    new_adjusted["heating_electricity_kwh"] = hp_elec_needed
    new_adjusted["fuel_type"] = "heat_pump"
    return new_global, new_adjusted
    
# Washing Machine Temperature Reduction
def reduce_wm_temperature_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    uses_per_week = profile.get("uses_per_week")
    temperature = profile.get("washing_temperature")
    washing_energy = uses_per_week * 52 * 1
    if temperature == "40":
        reduction = washing_energy * 0.38  # 38% saving switching to 30 degrees
    else:
        reduction = washing_energy * 0.67
    new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    return global_state, new_adjusted

# Bleeding Radiators
def bleed_radiators_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    if global_state.get("fuel_type") == "heat_pump":
        radiator_heating = global_state["heating_electricity_kwh"] * 0.77
        reduction = radiator_heating * 0.14  # 14% improvement
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        radiator_gas = global_state["heating_baseline"] * 0.77
        reduction = radiator_gas * 0.14
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - reduction
    return global_state, new_adjusted

# Water Cylinder Jacket
def water_cylinder_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    water_heating = global_state["water_heating_kwh"]
    reduction = water_heating * 0.75
    
    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
    
    # Both states update water_heating_kwh
    new_global["water_heating_kwh"] = global_state["water_heating_kwh"] - reduction
    new_adjusted["water_heating_kwh"] = adjusted_state["water_heating_kwh"] - reduction
    
    return new_global, new_adjusted

# Reflective Radiator Panels
def radiator_panels_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    if global_state.get("fuel_type") == "heat_pump":
        radiator_wall_heat = global_state["heating_electricity_kwh"] * 0.0385
        reduction = radiator_wall_heat * 0.95
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        radiator_wall_heat = global_state["heating_baseline"] * 0.0385
        reduction = radiator_wall_heat * 0.95
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - reduction
    return global_state, new_adjusted

# Window Draught Proofing
def window_dp_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    if global_state.get("fuel_type") == "heat_pump":
        window_heat = global_state["heating_electricity_kwh"] * 0.077
        reduction = window_heat * 0.2
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        window_heat = global_state["heating_baseline"] * 0.077
        reduction = window_heat * 0.2
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - reduction
    return global_state, new_adjusted

# Door Draught Proofing
def door_dp_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    if global_state.get("fuel_type") == "heat_pump":
        door_heat = global_state["heating_electricity_kwh"] * 0.1155
        reduction = door_heat * 0.2
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - reduction
    else:
        door_heat = global_state["heating_baseline"] * 0.1155
        reduction = door_heat * 0.2
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - reduction
    return global_state, new_adjusted

# Loft Insulation
def loft_insulation_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    if profile.get("loft_thickness") == '0mm':
        kwh_reduction = INSULATION_KWH_SAVING[property_type]["loft_big"]
    else:
        kwh_reduction = INSULATION_KWH_SAVING[property_type]["loft_small"]

    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - kwh_reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - kwh_reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - kwh_reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - kwh_reduction

    return global_state, new_adjusted


# Cavity Insulation
def cavity_insulation_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    kwh_reduction = INSULATION_KWH_SAVING[property_type]["cavity"]

    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - kwh_reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - kwh_reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - kwh_reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - kwh_reduction

    return global_state, new_adjusted


# Solid Wall Insulation
def solid_wall_insulation_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    kwh_reduction = INSULATION_KWH_SAVING[property_type]["solid_wall"]

    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - kwh_reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - kwh_reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - kwh_reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - kwh_reduction

    return global_state, new_adjusted


# Floor Insulation
def floor_insulation_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_adjusted = adjusted_state.copy()
    property_type = profile.get("property_type")
    kwh_reduction = INSULATION_KWH_SAVING[property_type]["floor"]

    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - kwh_reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - kwh_reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - kwh_reduction
        new_adjusted["heating_baseline"] = adjusted_state["heating_baseline"] - kwh_reduction

    return global_state, new_adjusted


# 2 Minutes Less In The Shower
def shorter_shower_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    num_people = global_state["num_people"]
    water_usage = global_state["annual_water_m3"]
    if global_state.get("shower_type") == "electric_shower":
        water_saving = num_people * 365 * 0.012
        new_global["annual_water_m3"] = water_usage - water_saving
        new_adjusted["annual_water_m3"] = water_usage - water_saving
    else:
        water_saving = num_people * 365 * 0.03
        new_global["annual_water_m3"] = water_usage - water_saving
        new_adjusted["annual_water_m3"] = water_usage - water_saving
    heat_reduction = water_saving * 35.1
    if global_state.get("shower_type") != "electric_shower":
        if global_state.get("fuel_type") == "heat_pump":
            new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - heat_reduction
            new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - heat_reduction
        else:
            new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - heat_reduction
        new_global["water_heating_kwh"] = global_state["water_heating_kwh"] - heat_reduction
        new_adjusted["water_heating_kwh"] = adjusted_state["water_heating_kwh"] - heat_reduction
    return new_global, new_adjusted

# Water Saving Shower Heads
def water_saving_shower_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    num_people = global_state["num_people"]
    water_usage = global_state["annual_water_m3"]
    time = profile.get("shower_time")
    shower_usage = time * num_people * 0.015 * 365 # per-person daily minutes -> yearly household m3
    new_shower_usage = shower_usage * 0.48
    reduction = shower_usage - new_shower_usage
    new_global["annual_water_m3"] = water_usage - reduction
    new_adjusted["annual_water_m3"] = water_usage - reduction
    heat_reduction = reduction * 35.1
    if global_state.get("fuel_type") == "heat_pump":
        new_adjusted["heating_electricity_kwh"] = adjusted_state["heating_electricity_kwh"] - heat_reduction
        new_adjusted["annual_electricity_kwh"] = adjusted_state["annual_electricity_kwh"] - heat_reduction
    else:
        new_adjusted["annual_gas_kwh"] = adjusted_state["annual_gas_kwh"] - heat_reduction
    new_global["water_heating_kwh"] = global_state["water_heating_kwh"] - heat_reduction
    new_adjusted["water_heating_kwh"] = adjusted_state["water_heating_kwh"] - heat_reduction
    return new_global, new_adjusted