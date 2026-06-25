# backend/calculator.py

from calculators.energy import (
    calculate_gas_emissions,
    calculate_electricity_emissions,
    calculate_water_emissions,
)

from calculators.travel import (
    calculate_car_emissions,
    calculate_bus_emissions,
    calculate_train_emissions,
    calculate_flight_emissions,
    calculate_abroad_accomodation_emissions,
    calculate_uk_accomodation_emissions,
)

from calculators.consumption import (
    calculate_pet_food_emissions,
    calculate_red_meat_emissions,
    calculate_white_meat_emissions,
    calculate_food_emissions,
    calculate_food_waste_emissions,
    calculate_household_waste_emissions,
    calculate_takeaway_emissions,
    calculate_drink_emissions,
    calculate_alcohol_emissions,
    calculate_tobacco_emissions,
    calculate_clothes_emissions,
    calculate_soap_emissions,
    calculate_medicine_emissions,
    calculate_electronics_emissions,
    calculate_machinery_emissions,
    calculate_education_emissions,
    calculate_healthcare_emissions,
    calculate_care_home_emissions,
    calculate_furniture_emissions,
    calculate_services_emissions,
)

# Essentially what I put in the terminal
# It is now in a way where it takes user inputs from flutter, stores them in a dictionary, and now pastes those dictionary inputs in here!
def calculate_total_emissions(profile: dict) -> dict:
    
    num_people = profile["num_people"]
    
    # HOME
    gas_co2   = calculate_gas_emissions(
                    profile["annual_gas_kwh"], 
                    profile["fuel_type"])
    elec_co2  = calculate_electricity_emissions(
                    profile["annual_electricity_kwh"])
    water_co2 = calculate_water_emissions(
                    profile["annual_water_m3"])

    # TRANSPORT
    car_co2   = calculate_car_emissions(
                    profile["weekly_mileage"],
                    profile["car_fuel"],
                    profile["car_size"])
    bus_co2   = calculate_bus_emissions(
                    profile["monthly_bus_spend"])
    train_co2 = calculate_train_emissions(
                    profile["monthly_train_spend"])
    flight_co2 = calculate_flight_emissions(
                    profile["flights"])
    abroad_co2 = calculate_abroad_accomodation_emissions(
                    profile["flights"])
    uk_co2    = calculate_uk_accomodation_emissions(
                    profile["uk_stays"])

    # DIET
    red_meat_co2  = calculate_red_meat_emissions(
                    profile["rm_days"], num_people)
    white_meat_co2 = calculate_white_meat_emissions(
                    profile["wm_days"], num_people)
    food_co2      = calculate_food_emissions(
                    profile["non_meat_spend"])
    
    # WASTE
    food_waste_co2 = calculate_food_waste_emissions(
                    profile["food_waste_action"], num_people)
    waste_co2     = calculate_household_waste_emissions(
                    profile["waste_action"], num_people)

    # PETS
    pet_co2 = calculate_pet_food_emissions(
                    profile["pets"])

    # SPENDING
    takeaway_co2   = calculate_takeaway_emissions(profile["monthly_takeaway"])
    drinks_co2     = calculate_drink_emissions(profile["monthly_drinks"])
    alcohol_co2    = calculate_alcohol_emissions(profile["monthly_alcohol"])
    tobacco_co2    = calculate_tobacco_emissions(profile["monthly_tobacco"])
    clothes_co2    = calculate_clothes_emissions(profile["monthly_clothes"])
    soap_co2       = calculate_soap_emissions(profile["monthly_soap"])
    medicine_co2   = calculate_medicine_emissions(profile["monthly_medicine"])
    electronics_co2 = calculate_electronics_emissions(profile["yearly_electronics"])
    machinery_co2  = calculate_machinery_emissions(profile["yearly_machinery"])
    education_co2  = calculate_education_emissions(profile["monthly_education"])
    healthcare_co2 = calculate_healthcare_emissions(profile["monthly_healthcare"])
    care_co2       = calculate_care_home_emissions(profile["monthly_care"])
    furniture_co2  = calculate_furniture_emissions(profile["yearly_furniture"])
    services_co2   = calculate_services_emissions(profile["monthly_services"])

    # ── TOTALS BY CATEGORY ──────────────────────────────────────────
    home_total      = gas_co2 + elec_co2 + water_co2
    transport_total = car_co2 + bus_co2 + train_co2 + flight_co2 + abroad_co2 + uk_co2
    diet_total      = red_meat_co2 + white_meat_co2 + food_co2
    waste_total     = food_waste_co2 + waste_co2
    pet_total       = pet_co2
    spending_total  = (takeaway_co2 + drinks_co2 + alcohol_co2 + tobacco_co2 +
                      clothes_co2 + soap_co2 + medicine_co2 + electronics_co2 +
                      machinery_co2 + education_co2 + healthcare_co2 + care_co2 +
                      furniture_co2 + services_co2)

    grand_total = home_total + transport_total + diet_total + waste_total + pet_total + spending_total
    total_trees = grand_total // 20

    return {
        "total_kg_co2e": grand_total,
        "trees": total_trees,
        "breakdown": {
            "home":      {"total": home_total,      "gas": gas_co2, "electricity": elec_co2, "water": water_co2},
            "transport": {"total": transport_total, "car": car_co2, "bus": bus_co2, "train": train_co2, "flights": flight_co2, "abroad_stays": abroad_co2, "uk_stays": uk_co2},
            "diet":      {"total": diet_total,      "red_meat": red_meat_co2, "white_meat": white_meat_co2, "food": food_co2},
            "waste":     {"total": waste_total,     "food_waste": food_waste_co2, "household": waste_co2},
            "pets":      {"total": pet_total},
            "spending":  {"total": spending_total,  "takeaway": takeaway_co2, "drinks": drinks_co2, "alcohol": alcohol_co2, "tobacco": tobacco_co2, "clothes": clothes_co2, "soap": soap_co2, "medicine": medicine_co2, "electronics": electronics_co2, "machinery": machinery_co2, "education": education_co2, "healthcare": healthcare_co2, "care": care_co2, "furniture": furniture_co2, "services": services_co2}
        }
    }

