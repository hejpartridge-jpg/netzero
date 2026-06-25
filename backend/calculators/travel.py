from emission_factors import CAR_FACTORS, FLIGHT_FACTORS, ACCOMMODATION_FACTORS, SPEND_FACTORS, get_country_info, _getnights 

# ── Bus/taxi emissions ──────────────────────────────────────────────────
def calculate_bus_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("bus_taxi")
    if factor is None:
        raise ValueError("Bus/taxi factor not found in emission factors")
    return monthly_spend * 12 * factor

"""
i need strings as i am finding the "bus_taxi" factors from inside
the SPEND_FACTORS dictionary, but with fuel type I don't as that 
is a variable name, and the variable needs to match the string 
inside GAS_FACTORS not the name of the variable
"""

# ── Train emissions ─────────────────────────────────────────────────────
def calculate_train_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("train")
    if factor is None:
        raise ValueError("Train factor not found in emission factors")
    return monthly_spend * 12 * factor


# ── Car emissions ─────────────────────────────────────────────────────
def calculate_car_emissions(weekly_mileage: float, _fuel: str, _size: str) -> float:
    #nested function, so you have to call .get() in two goes
    # .get() only gets one thing at a time, so you filter for fuel first and then size
    fuel_dict = CAR_FACTORS.get(_fuel)
    factor = fuel_dict.get(_size)
    if factor is None:
        raise ValueError(f"Unknown car size or fuel type")
    return weekly_mileage * 52 * factor

# ── Flight emissions ──────────────────────────────────────────────────
def calculate_flight_emissions(flights: list) -> float:
    total_co2 = 0
    for trip in flights:
        info = get_country_info(trip["country"])
        distance = info["distance_km"]
        haul_type = info["haul_type"]
        haul_dict = FLIGHT_FACTORS.get(haul_type)
        factor = haul_dict.get(trip["seat"])
        people = trip["passengers"]
        if factor is None:
            raise ValueError(f"Unknown seat type or country")
        co2 = factor * distance * people *2
        total_co2 += co2
    return total_co2

# ── Accommodation emissions ──────────────────────────────────────────────────
def calculate_abroad_accomodation_emissions(flights: list) -> float:
    total_co2 = 0
    for trip in flights:
        people = trip["passengers"]
        nights = trip["nights"]
        info = get_country_info(trip["country"])
        is_north_america = info["N_america"]
        is_europe = info["europe"]
        if trip["accommodation"] == "hotel":
            nemission = _getnights(trip["country"])
        elif trip["accommodation"] == "airbnb":
            if is_north_america:
                airbnb_reduction = 0.39   
            elif is_europe:
                airbnb_reduction = 0.11
            else:
                airbnb_reduction = 1
            emission = _getnights(trip["country"])
            nemission = emission * airbnb_reduction
        else: nemission = 0
        if nemission is None:
            raise ValueError(f"Unknown combination: {people}/{nights}")
        co2 = nemission * people * nights
        total_co2 += co2
    return total_co2

# ── UK Accommodation emissions ──────────────────────────────────────────────────
def calculate_uk_accomodation_emissions(trip: list) -> float:
    total_co2 = 0
    for stay in trip:
        people = stay["people"]
        nights = stay["nights"]
        lodging = stay ["type"]
        factor = ACCOMMODATION_FACTORS.get(lodging)    
        if factor is None:
            raise ValueError(f"Unknown accomodation type: '{type}'. ")
    
        co2 = nights * factor * people
        total_co2 += co2
    return total_co2
