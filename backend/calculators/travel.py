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
def calculate_car_emissions(cars: list) -> float:
    total_co2 = 0
    for car in cars:
        weekly_mileage = car.get("mileage", 0)
        fuel = car.get("fuel")
        size = car.get("size")
        fuel_dict = CAR_FACTORS.get(fuel)
        if fuel_dict is None:
            raise ValueError(f"Unknown car fuel type: '{fuel}'")
        factor = fuel_dict.get(size)
        if factor is None:
            raise ValueError(f"Unknown car size: '{size}' for fuel type '{fuel}'")
        total_co2 += weekly_mileage * 52 * factor
    return total_co2

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
def calculate_uk_accomodation_emissions(hotel_nights: float, airbnb_nights: float, num_people: int) -> float:
    if num_people is None:
        return 0

    hotel_factor = ACCOMMODATION_FACTORS.get('hotel')
    if hotel_factor is None:
        raise ValueError("Unknown accommodation type: 'hotel'")

    airbnb_factor = ACCOMMODATION_FACTORS.get('airbnb')
    if airbnb_factor is None:
        raise ValueError("Unknown accommodation type: 'airbnb'")

    hotel_co2 = hotel_nights * hotel_factor * num_people
    airbnb_co2 = airbnb_nights * airbnb_factor * num_people

    return hotel_co2 + airbnb_co2
