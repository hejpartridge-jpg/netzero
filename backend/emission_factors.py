# backend/emission_factors.py

import pandas as pd
import os

# ── Load the CSV once when the module is imported ──────────────────────────
## os.path.dirname = get the folder that contains this file name
## os.path.join = join that folder path to the CSV workbook, to get the full path to the CSV (so it can ba accessed anywhere)
_CSV_PATH = os.path.join(os.path.dirname(__file__), "Carbon_emissions_factors_-_Sheet1(1).csv")
_df = pd.read_csv(_CSV_PATH, sep='\t') #separated by a tab instead of by a comma

# As I have merged cells, it sees the question cell as empty half the time
## forward fill fills blank cells by copying from the row above
_df["Question"]  = _df["Question"].ffill()
# Forward fill filter 1 within same Question group
_df["filter 1"] = _df.groupby("Question")["filter 1"].ffill()
# Forward fill filter 2 only within same Question + filter 1 group
_df["filter 2"] = _df.groupby(["Question", "filter 1"])["filter 2"].ffill()
# Forward fill filter 3 only within same Question + filter 1 + filter 2 group
_df["filter 3"] = _df.groupby(["Question", "filter 1", "filter 2"])["filter 3"].ffill()

# ── Helper ─────────────────────────────────────────────────────────────────
# Defining a function so I can just call specific rows in future and get the right number back
## I expect strings under these columns, and I will give you a float back
def _get(question: str, f1: str = None, f2: str = None, f3: str = None) -> float:
    """
    Look up a single factor from the spreadsheet.
    question: matches the Question column
    f1/f2/f3: optional filter columns
    Returns the Factor value as a float.
    """

    # checks if each row is what you are looking for
    ## defaults to None, so if you didn't pass a filter, this line is skipped entirely.
    mask = _df["Question"] == question
    if f1: mask &= _df["filter 1"] == f1
    if f2: mask &= _df["filter 2"] == f2
    if f3: mask &= _df["filter 3"] == f3

# applies the mask to the whole dataframe, and keeps only the true ones
    rows = _df[mask]
    if rows.empty:
        raise ValueError(f"No factor found for: question='{question}' f1='{f1}' f2='{f2}' f3='{f3}'")

    # return the value in the factor column for the first row that matches all the criteria
    return float(rows.iloc[0]["Factor"])

# ── ELECTRICITY ────────────────────────────────────────────────────────────
ELECTRICITY_FACTOR = _get("Electricity Usage (from grid)")

ELECTRICITY_TARIFF_FACTORS = {
    "standard":  ELECTRICITY_FACTOR,
    "PPA": 0.01718,
}

SOLAR_FACTOR = 0.045  # kg CO2e per kWh, self-consumed solar

SOLAR_SYSTEM_SIZE_KW = {
    "terraced": 3.75,
    "semi_detached": 5.75,
    "detached": 8.5,
    "bungalow": 8.5,      # counts as detached
    # "flat" deliberately excluded — not eligible for solar
}

SOLAR_YEARLY_SUNLIGHT_HOURS = 1600 #average, V2 will be more specific
SOLAR_SELF_CONSUMPTION_RATE = 0.5

# ── GAS ────────────────────────────────────────────────────────────────────
GAS_FACTORS = {
    "lpg":         _get("Annual Gas usage (gross)", "LPG"),
    "natural_gas": _get("Annual Gas usage (gross)", "Natural Gas"),
}

# ── WATER ──────────────────────────────────────────────────────────────────
WATER_FACTOR = _get("Annual water usage")

# ── CAR ────────────────────────────────────────────────────────────────────
_CAR_SIZES = ["mini", "supermini", "lower medium", "upper medium",
              "executive", "luxury", "sports", "dual purpose", "mpv"]
_CAR_FUELS = ["petrol", "diesel", "plug in hybrid", "electric"]

CAR_FACTORS = {}
#loops through each fuel
for _fuel in _CAR_FUELS:
    CAR_FACTORS[_fuel] = {}
    #loops through each size in each fuel
    for _size in _CAR_SIZES:
        #finds the factor for each one
        try:
            CAR_FACTORS[_fuel][_size] = _get(
                "Mileage per week / Fuel Efficiency (mpg or mpkwh)", _fuel, _size
            )
        except (ValueError, Exception):
            CAR_FACTORS[_fuel][_size] = None  # N/A entries become None

# ── FLIGHTS ────────────────────────────────────────────────────────────────
FLIGHT_FACTORS = {
    "short_haul": {
        "economy":  _get("number of flights in the last year", "short haul", "economy"),
        "business": _get("number of flights in the last year", "short haul", "business"),
    },
    "long_haul": {
        "economy":         _get("number of flights in the last year", "long haul", "economy"),
        "premium_economy": _get("number of flights in the last year", "long haul", "premium economy"),
        "business":        _get("number of flights in the last year", "long haul", "business"),
        "first":           _get("number of flights in the last year", "long haul", "first class"),
    },
    "domestic": {
        "average": _get("number of flights in the last year", "domestic")
    }
}


# ── ACCOMMODATION ABROAD ─────────────────────────────────────────────────────
_CSV_PATH2 = os.path.join(os.path.dirname(__file__), "Overnight_hotel_stays_-_Sheet1.csv")
_hotel_df = pd.read_csv(_CSV_PATH2, sep='\t')

def _getnights(country: str) -> float:
    UK_HOTEL_FACTOR = _get("holidays", "hotel")
    rows = _hotel_df[_hotel_df["Country"] == country]
    if rows.empty:
        return UK_HOTEL_FACTOR
    factor = rows.iloc[0]["kg CO2e"]
    if pd.isna(factor): #if the factor column is n/a
        return UK_HOTEL_FACTOR
    return float(factor)


# ── ACCOMMODATION ──────────────────────────────────────────────────────────
ACCOMMODATION_FACTORS = {
    "hotel":   _get("holidays", "hotel"),
    "airbnb":  _get("holidays", "hotel") * 0.11,   # 89% less than hotel
    "camping":    0.0,
    "homestay":   0.0,
    
}

# ── FLIGHTS ─────────────────────────────────────────────────────
_DIST_PATH = os.path.join(os.path.dirname(__file__), "country_distances.csv")
_dist_df = pd.read_csv(_DIST_PATH, sep='\t')

def get_country_info(country: str) -> dict:
    rows = _dist_df[_dist_df["Country"] == country]
    if rows.empty:
        raise ValueError(f"Country '{country}' not found in distance lookup")
    row = rows.iloc[0]
    return{
        "distance_km":   float(row["distance_km"]),
        "haul_type":     row["Haul definition"].strip().lower().replace(" ", "_"),
        "N_america":     row["North America"] == "Yes",
        "europe":     row["Europe"] == "Yes"
        }


# ── DIET ───────────────────────────────────────────────────────────────────
DIET_FACTORS = {
    "red_meat":     _get("diet", "red meat"),
    "non_red_meat": _get("diet", "non red meat"),
}

PROTEIN_GRAMS_PER_SERVING = 26  # assumed average serving

# ── WASTE ──────────────────────────────────────────────────────────────────
WASTE_FACTORS = {
    "recycle":     _get("waste", "recycle"),
    "non_recycle": _get("waste", "non recycle"),
    "upcycle":     0.0,   # negligible per spreadsheet
}

FOOD_WASTE_FACTORS = {
    "bin":     _get("food waste", "bin"),
    "compost": _get("food waste", "compost"),
}

# ── SPENDING ───────────────────────────────────────────────────────────────
SPEND_FACTORS = {
    "food_non_meat":   _get("spending", "food (- meat)"),
    "eat_out":         _get("spending", "eat out/takeaways"),
    "soft_drinks":     _get("spending", "soft drinks"),
    "alcohol":         _get("spending", "alcohol"),
    "tobacco":         _get("spending", "tobacco"),
    "clothes":         _get("spending", "clothes"),
    "soap_detergents": _get("spending", "soaps/detergents"),
    "medicines":       _get("spending", "medicines"),
    "electronics":     _get("spending", "electronics"),
    "machinery":       _get("spending", "machinery/equipment"),
    "education":       _get("spending", "education"),
    "healthcare":      _get("spending", "healthcare"),
    "care_homes":      _get("spending", "carehomes"),
    "furniture":       _get("spending", "furniture"),
    "other_services":  _get("spending", "other (services)"),
    "train":           _get("transport", "train"),
    "bus_taxi":        _get("transport", "bus/taxi etc..."),
}

# ── PET FOOD ───────────────────────────────────────────────────────────────
PET_FACTORS = {
    "dog": {
        "wet": {
            "premium":  {"vegan": _get("dog food", "wet", "premium", "vegan"),
                         "meaty": _get("dog food", "wet", "premium", "meaty")},
            "standard": {"vegan": _get("dog food", "wet", "standard", "vegan"),
                         "meaty": _get("dog food", "wet", "standard", "meaty")},
        },
        "dry": {
            "premium":  {"vegan": _get("dog food", "dry", "premium", "vegan"),
                         "meaty": _get("dog food", "dry", "premium", "meaty")},
            "standard": {"vegan": _get("dog food", "dry", "standard", "vegan"),
                         "meaty": _get("dog food", "dry", "standard", "meaty")},
        },
    },
    "cat": {
        "wet": {
            "premium":  {"vegan": _get("cat food", "wet", "premium", "vegan"),
                         "meaty": _get("cat food", "wet", "premium", "meaty")},
            "standard": {"vegan": _get("cat food", "wet", "standard", "vegan"),
                         "meaty": _get("cat food", "wet", "standard", "meaty")},
        },
        "dry": {
            "premium":  {"vegan": _get("cat food", "dry", "premium", "vegan"),
                         "meaty": _get("cat food", "dry", "premium", "meaty")},
            "standard": {"vegan": _get("cat food", "dry", "standard", "vegan"),
                         "meaty": _get("cat food", "dry", "standard", "meaty")},
        },
    },
}