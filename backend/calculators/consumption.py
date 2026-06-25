from emission_factors import DIET_FACTORS, WASTE_FACTORS, FOOD_WASTE_FACTORS, SPEND_FACTORS,PET_FACTORS

# ── Pet food emissions ──────────────────────────────────────────────────
def calculate_pet_food_emissions(pets: list) -> float:
    total_co2 = 0
    for animal in pets:
        what = animal["type"]
        food = animal["food"]
        brand = animal["brand"]
        weight = animal["weight"]/1000
        diet = animal["diet"]
        factor = PET_FACTORS.get(what, {}).get(food, {}).get(brand, {}).get(diet)
        if factor is None:
            # {} means to insert the value of the variable here
            raise ValueError(f"Unknown combination: {what}/{food}/{brand}/{diet}")
        co2 = factor * 365 * weight
        total_co2 += co2
    return total_co2

# ── Human food emissions ──────────────────────────────────────────────────
def calculate_red_meat_emissions(rm_days: float, num_people: int) -> float:
    factor = DIET_FACTORS.get("red_meat")
    if factor is None:
        raise ValueError("red meat factor not found in emission factors")
    return factor * rm_days * num_people * 52

def calculate_white_meat_emissions(wm_days: float, num_people: int) -> float:
    factor = DIET_FACTORS.get("non_red_meat")
    if factor is None:
        raise ValueError("white meat factor not found in emission factors")
    return factor * wm_days * num_people * 52

def calculate_food_emissions(non_meat_spend: float) -> float:
    factor = SPEND_FACTORS.get("food_non_meat")
    if factor is None:
        raise ValueError("food factor not found in emission factors")
    return factor * 52 * non_meat_spend

# ── Food waste emissions ──────────────────────────────────────────────────
def calculate_food_waste_emissions(action: str, num_people: int) -> float:
    factor = FOOD_WASTE_FACTORS.get(action)
    if factor is None:
        raise ValueError(f"Unknown waste action: '{action}'. Must be 'bin' or 'compost'")
    return factor * 0.088 * num_people

# ── Household waste emissions ──────────────────────────────────────────────────
def calculate_household_waste_emissions(action: str, num_people: int) -> float:
    auto_waste_factor = 41.076 * num_people
    factor = WASTE_FACTORS.get(action)
    if factor is None:
        raise ValueError(f"Unknown waste action: '{action}'. Must be 'recycle', 'non_recycle' or 'upcycle'")
    action_waste_factor = 0.3304 * factor * num_people
    return auto_waste_factor + action_waste_factor

# ── Takeaway emissions ─────────────────────────────────────────────────────
def calculate_takeaway_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("eat_out")
    if factor is None:
        raise ValueError("Takeaway factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Soft drink emissions ─────────────────────────────────────────────────────
def calculate_drink_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("soft_drinks")
    if factor is None:
        raise ValueError("Soft drink factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Alcohol emissions ─────────────────────────────────────────────────────
def calculate_alcohol_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("alcohol")
    if factor is None:
        raise ValueError("Alcohol factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Tobacco emissions ─────────────────────────────────────────────────────
def calculate_tobacco_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("tobacco")
    if factor is None:
        raise ValueError("Tobacco factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Clothes emissions ─────────────────────────────────────────────────────
def calculate_clothes_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("clothes")
    if factor is None:
        raise ValueError("Clothes factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Soaps and detergents emissions ─────────────────────────────────────────────────────
def calculate_soap_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("soap_detergents")
    if factor is None:
        raise ValueError("Soaps and detergents factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Medicine emissions ─────────────────────────────────────────────────────
def calculate_medicine_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("medicines")
    if factor is None:
        raise ValueError("Medicines factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Electronics emissions ─────────────────────────────────────────────────────
def calculate_electronics_emissions(yearly_spend: float) -> float:
    factor = SPEND_FACTORS.get("electronics")
    if factor is None:
        raise ValueError("Electronics factor not found in emission factors")
    return yearly_spend * factor

# ── Machinery emissions ─────────────────────────────────────────────────────
def calculate_machinery_emissions(yearly_spend: float) -> float:
    factor = SPEND_FACTORS.get("machinery")
    if factor is None:
        raise ValueError("Machinery factor not found in emission factors")
    return yearly_spend * factor


# ── Education emissions ─────────────────────────────────────────────────────
def calculate_education_emissions(yearly_spend: float) -> float:
    factor = SPEND_FACTORS.get("education")
    if factor is None:
        raise ValueError("Education factor not found in emission factors")
    return yearly_spend * factor

# ── Healthcare emissions ─────────────────────────────────────────────────────
def calculate_healthcare_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("healthcare")
    if factor is None:
        raise ValueError("Healthcare factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Care home emissions ─────────────────────────────────────────────────────
def calculate_care_home_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("care_homes")
    if factor is None:
        raise ValueError("Care home factor not found in emission factors")
    return monthly_spend * 12 * factor

# ── Furniture emissions ─────────────────────────────────────────────────────
def calculate_furniture_emissions(yearly_spend: float) -> float:
    factor = SPEND_FACTORS.get("furniture")
    if factor is None:
        raise ValueError("Furniture factor not found in emission factors")
    return yearly_spend * factor

# ── Services emissions ─────────────────────────────────────────────────────
def calculate_services_emissions(monthly_spend: float) -> float:
    factor = SPEND_FACTORS.get("other_services")
    if factor is None:
        raise ValueError("Services factor not found in emission factors")
    return monthly_spend * 12 * factor

