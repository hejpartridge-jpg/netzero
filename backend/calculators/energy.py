from emission_factors import GAS_FACTORS, ELECTRICITY_FACTOR, WATER_FACTOR

def calculate_gas_emissions(annual_kwh: float, fuel_type: str) -> float:
    """
    The user types in their annual_kwh and fuel_type in a separate file
    This function uses the GAS_FACTORS previously defined in emission_factors.py based on the specified fuel type
    It then looks up the emissions factor and multiplies it by the kwh
    It is a calculation function which will be called in a separate location
    """
    factor = GAS_FACTORS.get(fuel_type)    
    if factor is None:
        raise ValueError(f"Unknown fuel type: '{fuel_type}'. Must be 'natural_gas' or 'lpg'")
    
    return annual_kwh * factor


def calculate_electricity_emissions(annual_kwh: float, tariff: str = "standard", solar_self_consumed_kwh: float = 0) -> float:
    grid_kwh = max(0, annual_kwh - solar_self_consumed_kwh)
    tariff_factor = ELECTRICITY_TARIFF_FACTORS.get(tariff)
    if tariff_factor is None:
        raise ValueError(f"Unknown tariff type: '{tariff}'. Must be 'standard', or 'PPA'")
    grid_emissions = grid_kwh * tariff_factor
    solar_emissions = solar_self_consumed_kwh * SOLAR_FACTOR
    return grid_emissions + solar_emissions


def calculate_water_emissions(annual_m3: float) -> float:
    return annual_m3 * WATER_FACTOR
