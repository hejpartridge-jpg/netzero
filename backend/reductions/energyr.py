from emission_factors import SOLAR_SYSTEM_SIZE_KW, SOLAR_YEARLY_SUNLIGHT_HOURS, SOLAR_SELF_CONSUMPTION_RATE
## answers are the quiz responses, for example in solar panels, you are getting
## the property type from answers so what the person answered in the quiz
## this will be a massive dictionary with everything I need in! :)

# Renewable Tariff
def renewable_tariff_apply(state: dict, answers: dict) -> dict:
    new_state = state.copy()
    new_state["tariff"] = "PPA"
    return new_state

# Solar Panels
def solar_panels_apply(state: dict, answers: dict) -> dict:
    new_state = state.copy()
    property_type = answers.get("property_type")
    system_size_kw = SOLAR_SYSTEM_SIZE_KW[property_type]
    yearly_production_kwh = system_size_kw * SOLAR_YEARLY_SUNLIGHT_HOURS
    self_consumed_kwh = yearly_production_kwh * SOLAR_SELF_CONSUMPTION_RATE
    new_state["solar_self_consumed_kwh"] = self_consumed_kwh
    return new_state

# Thermostat Decrease
def one_degree_less_apply(state: dict, answers: dict) -> dict:
    new_state = state.copy()
    if state.get("heating_type") == "heat_pump":
        old_heating = state["heating_electricity_kwh"]
        new_heating = old_heating * 0.87
        reduction = old_heating - new_heating
        new_state["heating_electricity_kwh"] = new_heating
        new_state["annual_electricity_kwh"] = state["annual_electricity_kwh"] - reduction
    else:
        new_state["annual_gas_kwh"] = state["annual_gas_kwh"] * 0.87
    return new_state
