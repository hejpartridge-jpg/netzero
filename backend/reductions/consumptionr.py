

# Composting
def compost_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["food_waste_action"] = "compost"
    new_adjusted["food_waste_action"] = "compost"
    return new_global, new_adjusted

# Upcycling
def upcycle_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["waste_action"] = "upcycle"
    new_adjusted["waste_action"] = "upcycle"
    return new_global, new_adjusted

# One Less Red Meat Day
def less_rm_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    rm_days = global_state["rm_days"]
    non_meat_spend = global_state["non_meat_spend"]
    num_people = global_state["num_people"]
    if rm_days <= 0:
        return global_state, adjusted_state
    else: 
        new_rm_days = max(rm_days - 1, 0)
        meat_spend_saved = num_people * 1.038
        new_spend = meat_spend_saved + non_meat_spend
        new_global["non_meat_spend"] = new_spend
        new_global["rm_days"] = new_rm_days
        new_adjusted["non_meat_spend"] = new_spend
        new_adjusted["rm_days"] = new_rm_days
    return new_global, new_adjusted

# One Less White Meat Day
def less_wm_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    wm_days = global_state["wm_days"]
    non_meat_spend = global_state["non_meat_spend"]
    num_people = global_state["num_people"]
    if wm_days <= 0:
        return global_state, adjusted_state
    else:
        new_wm_days = max(wm_days - 1, 0)
        meat_spend_saved = num_people * 0.769
        new_spend = meat_spend_saved + non_meat_spend
        new_global["non_meat_spend"] = new_spend
        new_global["wm_days"] = new_wm_days
        new_adjusted["non_meat_spend"] = new_spend
        new_adjusted["wm_days"] = new_wm_days
    return new_global, new_adjusted

# Vegan Pet Food
def vegan_pets_apply(global_state: dict, adjusted_state: dict, profile: dict) -> tuple:
    new_global = global_state.copy()
    new_adjusted = adjusted_state.copy()
    new_global["pets"] = [
        {**animal, "diet": "vegan"} if animal["diet"] == "meaty" else animal
        for animal in global_state["pets"]
    ]
    new_adjusted["pets"] = [
        {**animal, "diet": "vegan"} if animal["diet"] == "meaty" else animal
        for animal in adjusted_state["pets"]
    ]
    return new_global, new_adjusted