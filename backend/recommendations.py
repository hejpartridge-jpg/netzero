from reductions.initial_state import build_initial_state
from reductions.reduction_calculations import (
    renewable_tariff_co2,
    solar_panels_co2,
    battery_storage_co2,
    one_degree_less_co2,
    smart_thermostat_co2,
    LED_co2,
    smart_sockets_co2,
    heat_pumps_co2,
    reduce_wm_temperature_co2,
    bleed_radiators_co2,
    water_cylinder_co2,
    radiator_panels_co2,
    window_dp_co2,
    door_dp_co2,
    shorter_shower_co2,
    water_saving_shower_co2,
    loft_insulation_co2,
    cavity_insulation_co2,
    solid_wall_insulation_co2,
    floor_insulation_co2,
    electric_car_co2,
    economy_not_business_co2,
    less_car_co2,
    compost_co2,
    upcycle_co2,
    less_rm_co2,
    less_wm_co2,
    vegan_pets_co2,
)

# cost: "free" | "cheap" | "expensive" - DEFAULTS, NOT RESEARCHED FIGURES.
#       Review these - actual cost depends on supplier/region/property.
# difficulty: "easy" | "hard" - also a best-guess default, worth reviewing.
#
# Tier ordering for display: free actions shown before cheap, before
# expensive, REGARDLESS of impact size - i.e. tier beats magnitude.
# Within a tier, sorted by reduction_kg_co2e descending.
# eligibilty = true/false depending on their profile
# not.() means that you flip the boolean, i.e. if it gives true then the actual answer is false

ACTIONS = [
    {
        "name": "renewable_tariff",
        "label": "Switch to a renewable (PPA) tariff",
        "co2_fn": renewable_tariff_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: p.get("tariff") != "PPA",
    },
    {
        "name": "one_degree_less",
        "label": "Turn your thermostat down by 1 degree",
        "co2_fn": one_degree_less_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: True,
    },
    {
        "name": "shorter_shower",
        "label": "Take 2 minutes less in the shower",
        "co2_fn": shorter_shower_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: True,
    },
    {
        "name": "reduce_wm_temperature",
        "label": "Wash clothes at 30 degrees",
        "co2_fn": reduce_wm_temperature_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: p.get("washing_temperature") != "30",
    },
    {
        "name": "less_car",
        "label": "Take one less car journey a week",
        "co2_fn": less_car_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: p.get("weekly_mileage", 0) > 0,
    },
    {
        "name": "economy_not_business",
        "label": "Fly economy instead of business/first",
        "co2_fn": economy_not_business_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: any(
            trip.get("seat") in ("business", "first") for trip in p.get("flights", [])
        ),
    },
    {
        "name": "compost",
        "label": "Start composting food waste",
        "co2_fn": compost_co2,
        "cost": "free",
        "difficulty": "easy",
        "eligible": lambda p: p.get("food_waste_action") != "compost",
    },
    {
        "name": "upcycle",
        "label": "Upcycle instead of throwing away",
        "co2_fn": upcycle_co2,
        "cost": "free",
        "difficulty": "medium",
        "eligible": lambda p: p.get("waste_action") != "upcycle",
    },
    {
        "name": "less_red_meat",
        "label": "Eat one less red meat day a week",
        "co2_fn": less_rm_co2,
        "cost": "free",
        "difficulty": "medium",
        "eligible": lambda p: p.get("rm_days", 0) > 1,
    },
    {
        "name": "less_white_meat",
        "label": "Eat one less white meat day a week",
        "co2_fn": less_wm_co2,
        "cost": "free",
        "difficulty": "medium",
        "eligible": lambda p: p.get("wm_days", 0) > 1,
    },
    {
        "name": "bleed_radiators",
        "label": "Bleed your radiators",
        "co2_fn": bleed_radiators_co2,
        "cost": "cheap",
        "difficulty": "easy",
        "eligible": lambda p: p.get("last_radiator_bleed") != "this_year",
    },
    {
        "name": "LED_lighting",
        "label": "Switch remaining bulbs to LED",
        "co2_fn": LED_co2,
        "cost": "cheap",
        "difficulty": "easy",
        "eligible": lambda p: (p.get("incandescent_bulbs", 0) + p.get("cfl_bulbs", 0)) > 0,
    },
    {
        "name": "smart_sockets",
        "label": "Use energy-saving sockets",
        "co2_fn": smart_sockets_co2,
        "cost": "cheap",
        "difficulty": "hard",
        "eligible": lambda p: not p.get("energy_saving_sockets", False),
    },
    {
        "name": "water_cylinder_jacket",
        "label": "Fit a water cylinder jacket",
        "co2_fn": water_cylinder_co2,
        "cost": "cheap",
        "difficulty": "easy",
        "eligible": lambda p: not p.get("water_cylinder_jacket", False),
    },
    {
        "name": "radiator_panels",
        "label": "Add reflective radiator panels",
        "co2_fn": radiator_panels_co2,
        "cost": "cheap",
        "difficulty": "medium",
        "eligible": lambda p: not p.get("radiator_panels", False),
    },
    {
        "name": "window_draught_proofing",
        "label": "Draught-proof your windows",
        "co2_fn": window_dp_co2,
        "cost": "cheap",
        "difficulty": "medium",
        "eligible": lambda p: not p.get("window_draught_proofing", False),
    },
    {
        "name": "door_draught_proofing",
        "label": "Draught-proof your doors",
        "co2_fn": door_dp_co2,
        "cost": "cheap",
        "difficulty": "medium",
        "eligible": lambda p: not p.get("door_draught_proofing", False),
    },
    {
        "name": "water_saving_shower",
        "label": "Fit a water-saving shower head",
        "co2_fn": water_saving_shower_co2,
        "cost": "cheap",
        "difficulty": "easy",
        "eligible": lambda p: (
            not p.get("water_saving_shower", False)
            and p.get("shower_type") != "electric_shower"
        ),
    },
    {
        "name": "vegan_pet_food",
        "label": "Switch pets to vegan food",
        "co2_fn": vegan_pets_co2,
        "cost": "cheap",
        "difficulty": "easy",
        "eligible": lambda p: any(
            pet.get("diet") == "meaty" for pet in p.get("pets", [])
        ),
    },
    {
        "name": "smart_thermostat",
        "label": "Install a smart thermostat",
        "co2_fn": smart_thermostat_co2,
        "cost": "expensive",
        "difficulty": "easy",
        "eligible": lambda p: not p.get("smart_thermostat", False),
    },
    {
        "name": "loft_insulation",
        "label": "Top up your loft insulation",
        "co2_fn": loft_insulation_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: p.get("loft_thickness") != "270mm",
    },
    {
        "name": "cavity_insulation",
        "label": "Install cavity wall insulation",
        "co2_fn": cavity_insulation_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: (
            p.get("wall_type") == "cavity" and not p.get("wall_insulation", False)
        ),
    },
    {
        "name": "solid_wall_insulation",
        "label": "Install solid wall insulation",
        "co2_fn": solid_wall_insulation_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: (
            p.get("wall_type") == "solid_wall" and not p.get("wall_insulation", False)
        ),
    },
    {
        "name": "floor_insulation",
        "label": "Install floor insulation",
        "co2_fn": floor_insulation_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: not p.get("floor_insulation", False),
    },
    {
        "name": "solar_panels",
        "label": "Install solar panels",
        "co2_fn": solar_panels_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: not p.get("solar_panels", False),
    },
    {
        "name": "battery_storage",
        "label": "Add battery storage",
        "co2_fn": battery_storage_co2,
        "cost": "expensive",
        "difficulty": "medium",
        "eligible": lambda p: p.get("solar_panels", False) and not p.get("battery_storage", False),
    },
    {
        "name": "heat_pump",
        "label": "Install a heat pump",
        "co2_fn": heat_pumps_co2,
        "cost": "expensive",
        "difficulty": "hard",
        "eligible": lambda p: p.get("fuel_type") != "heat_pump",
    },
    {
        "name": "electric_car",
        "label": "Switch to an electric car",
        "co2_fn": electric_car_co2,
        "cost": "expensive",
        "difficulty": "medium",
        "eligible": lambda p: p.get("car_fuel") != "electric",
    },
]

_TIER_ORDER = {"free": 0, "cheap": 1, "expensive": 2}

_ACTIONS_BY_NAME = {a["name"]: a for a in ACTIONS}


def get_recommendations(profile: dict, completed_actions: list = None, dismissed_actions: list = None) -> dict:
    """
    Returns:
    {
        "starting_total_kg_co2e": ...,   # footprint before anything was done
        "current_total_kg_co2e": ...,    # footprint right now, after completed actions
        "total_saved_kg_co2e": ...,      # starting - current
        "recommendations": [
            {"name", "label", "cost", "difficulty", "reduction_kg_co2e"},
            ...  # sorted: tier (free < cheap < expensive) first, then reduction descending
        ]
    }

    `completed_actions` is a list of action `name`s (matching ACTIONS' "name"
    field) the user has already marked done, in the order they did them.
    Each completed action is replayed against the state in that order to
    build the CURRENT state - so remaining actions' reductions correctly
    reflect what's already been done, and completed actions are excluded
    from the returned recommendations list.
    """
    completed_actions = completed_actions or []
    dismissed_actions = dismissed_actions or []

    global_state, adjusted_state, co2_state = build_initial_state(profile)
    starting_total = co2_state["total_co2"]

    # Replay completed actions in order to build current state.
    for action_name in completed_actions:
        action = _ACTIONS_BY_NAME.get(action_name)
        if action is None:
            print(f"Unknown completed action name: '{action_name}' - skipping")
            continue
        global_state, adjusted_state, _reduction, co2_state = action["co2_fn"](
            global_state, adjusted_state, co2_state, profile
        )

    current_total = co2_state["total_co2"]
    total_saved = starting_total - current_total

    # Calculate remaining eligible (and not-yet-completed) actions against
    # the CURRENT (post-replay) state, each independently - so two
    # not-yet-done actions don't "double count" against each other, but
    # both correctly reflect anything already completed.
    results = []
    for action in ACTIONS:
        if action["name"] in completed_actions:
            continue
        if action["name"] in dismissed_actions:
            continue
        if not action["eligible"](profile):
            continue

        try:
            _, _, reduction, _ = action["co2_fn"](global_state, adjusted_state, co2_state, profile)
        except Exception as e:
            print(f"Recommendation '{action['name']}' failed to calculate: {e}")
            continue

        results.append({
            "name": action["name"],
            "label": action["label"],
            "cost": action["cost"],
            "difficulty": action["difficulty"],
            "reduction_kg_co2e": round(reduction, 1),
        })

    results.sort(key=lambda r: (_TIER_ORDER[r["cost"]], -r["reduction_kg_co2e"]))

    return {
        "starting_total_kg_co2e": round(starting_total, 1),
        "current_total_kg_co2e": round(current_total, 1),
        "total_saved_kg_co2e": round(total_saved, 1),
        "recommendations": results,
    }