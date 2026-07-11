from calculator import calculate_total_emissions
from emission_factors import INSULATION_CO2_SAVING

from reductions.energyr import (
    renewable_tariff_apply,
    solar_panels_apply,
    battery_storage_apply,
    one_degree_less_apply,
    smart_thermostat_apply,
    LED_apply,
    smart_sockets_apply,
    heat_pumps_apply,
    reduce_wm_temperature_apply,
    bleed_radiators_apply,
    water_cylinder_apply,
    radiator_panels_apply,
    window_dp_apply,
    door_dp_apply,
    shorter_shower_apply,
    water_saving_shower_apply,
    loft_insulation_apply,
    cavity_insulation_apply,
    solid_wall_insulation_apply,
    floor_insulation_apply,
)

from reductions.travelr import (
    electric_car_apply,
    economy_not_business_apply,
    less_car_apply,
)

from reductions.consumptionr import (
    compost_apply,
    upcycle_apply,
    less_rm_apply,
    less_wm_apply,
    vegan_pets_apply,
)

# Renewable Tariff
def renewable_tariff_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = renewable_tariff_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Solar Panels
def solar_panels_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = solar_panels_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Battery Storage
def battery_storage_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = battery_storage_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

#Thermostat 1 degree decrease
def one_degree_less_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = one_degree_less_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Smart Thermostat
def smart_thermostat_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = smart_thermostat_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

#LED Lighting
def LED_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = LED_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

#Smart sockets
def smart_sockets_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = smart_sockets_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Heat Pumps
def heat_pumps_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = heat_pumps_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2


# Washing Machine Temperature Reduction
def reduce_wm_temperature_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = reduce_wm_temperature_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2


# Window Draught Proofing
def window_dp_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = window_dp_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]     
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Bleeding Radiators
def bleed_radiators_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = bleed_radiators_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Water Cylinder Jacket
def water_cylinder_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = water_cylinder_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Reflective Radiator Panels
def radiator_panels_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = radiator_panels_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Door Draught Proofing
def door_dp_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = door_dp_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# 2 Minutes Less In The Shower
def shorter_shower_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = shorter_shower_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Water Saving Shower Heads
def water_saving_shower_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = water_saving_shower_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Loft Insulation
def loft_insulation_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = loft_insulation_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Cavity Insulation
def cavity_insulation_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = cavity_insulation_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Solid Wall Insulation
def solid_wall_insulation_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = solid_wall_insulation_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Floor Insulation
def floor_insulation_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = floor_insulation_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Electric Car
def electric_car_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = electric_car_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Economy Not Business/First
def economy_not_business_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = economy_not_business_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# 1 Less Car Journey
def less_car_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = less_car_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Composting
def compost_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = compost_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Upcycling
def upcycle_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = upcycle_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# One Less Red Meat Day
def less_rm_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = less_rm_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# One Less White Meat Day
def less_wm_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = less_wm_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2

# Vegan Pet Food
def vegan_pets_co2(global_state: dict, adjusted_state: dict, co2_state: dict, profile: dict) -> tuple:
    beginning_co2 = co2_state["total_co2"]
    new_co2 = co2_state.copy()
    new_global, new_adjusted = vegan_pets_apply(global_state, adjusted_state, profile)
    co2_before = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    co2_after = calculate_total_emissions(new_adjusted)["total_kg_co2e"]      
    reduction = co2_before - co2_after
    new_co2["total_co2"] = beginning_co2 - reduction
    return new_global, new_adjusted, reduction, new_co2