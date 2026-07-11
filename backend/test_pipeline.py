"""
Test suite for the reduction / CO2 calculation pipeline.

HOW TO USE:
1. Drop this file into your project root (same level as initial_state.py, calculator.py).
2. Fix the import block below to match wherever your real _co2 wrapper functions live
   (you may have them all in one file, or split across energyr.py/travelr.py/consumptionr.py
   alongside the _apply functions - adjust accordingly).
3. Run with:   python3 test_pipeline.py
   or, if you have pytest installed:   pytest test_pipeline.py -v

Each test is a plain function starting with `test_` and uses `assert`. The runner at the
bottom catches failures and prints a pass/fail summary, so you don't need pytest installed
to use this - though pytest gives nicer output if you have it.
"""

from reductions.initial_state import build_initial_state
from calculator import calculate_total_emissions

# --- ADJUST THESE IMPORTS to match your real project structure ---
from reductions.energyr import (
    renewable_tariff_apply, solar_panels_apply, battery_storage_apply,
    one_degree_less_apply, smart_thermostat_apply, LED_apply, smart_sockets_apply,
    heat_pumps_apply, reduce_wm_temperature_apply, bleed_radiators_apply,
    water_cylinder_apply, radiator_panels_apply, window_dp_apply, door_dp_apply,
    shorter_shower_apply, water_saving_shower_apply, loft_insulation_apply,
    cavity_insulation_apply, solid_wall_insulation_apply, floor_insulation_apply,
)
from reductions.travelr import electric_car_apply, economy_not_business_apply, less_car_apply
from reductions.consumptionr import compost_apply, upcycle_apply, less_rm_apply, less_wm_apply, vegan_pets_apply

# Import your actual hand-written _co2 wrappers here instead if they're separate functions,
# e.g.: from co2_calculations import renewable_tariff_co2, solar_panels_co2, ...
from reductions.reduction_calculations import (
    renewable_tariff_co2, solar_panels_co2, battery_storage_co2, one_degree_less_co2,
    smart_thermostat_co2, LED_co2, smart_sockets_co2, heat_pumps_co2,
    reduce_wm_temperature_co2, bleed_radiators_co2, water_cylinder_co2,
    radiator_panels_co2, window_dp_co2, door_dp_co2, shorter_shower_co2,
    water_saving_shower_co2, loft_insulation_co2, cavity_insulation_co2,
    solid_wall_insulation_co2, floor_insulation_co2,
    electric_car_co2, economy_not_business_co2, less_car_co2,
    compost_co2, upcycle_co2, less_rm_co2, less_wm_co2, vegan_pets_co2,
)
# --- END ADJUSTABLE IMPORTS ---


ALL_CO2_FUNCTIONS = [
    renewable_tariff_co2, solar_panels_co2, battery_storage_co2, one_degree_less_co2,
    smart_thermostat_co2, LED_co2, smart_sockets_co2, heat_pumps_co2,
    reduce_wm_temperature_co2, bleed_radiators_co2, water_cylinder_co2,
    radiator_panels_co2, window_dp_co2, door_dp_co2, shorter_shower_co2,
    water_saving_shower_co2, loft_insulation_co2, cavity_insulation_co2,
    solid_wall_insulation_co2, floor_insulation_co2,
    electric_car_co2, economy_not_business_co2, less_car_co2,
    compost_co2, upcycle_co2, less_rm_co2, less_wm_co2, vegan_pets_co2,
]


def make_test_profile_and_answers(property_type="semi_detached", heating_type="gas_boiler",
                                   shower_type="mixer_shower", rm_days=5, wm_days=4):
    profile = {
        "num_people": 3,
        "annual_gas_kwh": 12000,
        "annual_electricity_kwh": 4000,
        "fuel_type": "natural_gas",
        "tariff": "standard",
        "annual_water_m3": 150,
        "weekly_mileage": 150,
        "car_fuel": "petrol",
        "car_size": "mini",
        "monthly_bus_spend": 20,
        "monthly_train_spend": 10,
        "flights": [
            {"country": "Albania", "seat": "economy", "passengers": 3,
             "nights": 7, "accommodation": "hotel"},
        ],
        "uk_stays": [{"people": 3, "nights": 4, "type": "hotel"}],
        "rm_days": rm_days,
        "wm_days": wm_days,
        "non_meat_spend": 60,
        "food_waste_action": "bin",
        "waste_action": "non_recycle",
        "pets": [{"type": "dog", "food": "wet", "brand": "premium", "weight": 15000, "diet": "meaty"}],
        "monthly_takeaway": 40,
        "monthly_drinks": 15,
        "monthly_alcohol": 20,
        "monthly_tobacco": 0,
        "monthly_clothes": 50,
        "monthly_soap": 10,
        "monthly_medicine": 5,
        "yearly_electronics": 300,
        "yearly_machinery": 0,
        "monthly_education": 0,
        "monthly_healthcare": 0,
        "monthly_care": 0,
        "yearly_furniture": 100,
        "monthly_services": 30,
    }
    answers = {
        "property_type": property_type,
        "heating_type": heating_type,
        "hob_type": "gas",
        "boiler_age": "10-15",
        "incandescent_bulbs": 4,
        "cfl_bulbs": 2,
        "led_bulbs": 6,
        "uses_per_week": 5,
        "shower_type": shower_type,
        "shower_time": 8,
        "loft_thickness": 0,
    }
    return profile, answers


# ---------------------------------------------------------------------------
# TESTS
# ---------------------------------------------------------------------------

def test_full_chain_runs_without_crashing():
    """Every _co2 wrapper can be called in sequence without raising."""
    profile, answers = make_test_profile_and_answers()
    global_state, adjusted_state, co2_state = build_initial_state(profile, answers)
    for fn in ALL_CO2_FUNCTIONS:
        global_state, adjusted_state, reduction, co2_state = fn(
            global_state, adjusted_state, co2_state, answers
        )
    assert isinstance(co2_state["total_co2"], (int, float))


def test_running_total_matches_fresh_recalculation():
    """
    The most important consistency check: after applying a chain of actions,
    co2_state['total_co2'] (built incrementally) must exactly match what you'd
    get from running calculate_total_emissions() fresh on the final adjusted_state.
    If these diverge, some action's reduction isn't being calculated against the
    true current state.
    """
    profile, answers = make_test_profile_and_answers()
    global_state, adjusted_state, co2_state = build_initial_state(profile, answers)
    for fn in ALL_CO2_FUNCTIONS:
        global_state, adjusted_state, reduction, co2_state = fn(
            global_state, adjusted_state, co2_state, answers
        )
    fresh_total = calculate_total_emissions(adjusted_state)["total_kg_co2e"]
    assert abs(co2_state["total_co2"] - fresh_total) < 0.01, (
        f"Running total {co2_state['total_co2']} != fresh recalculation {fresh_total}"
    )


def test_all_reductions_non_negative_in_isolation():
    """
    Each action, applied on its own to a fresh baseline state, should reduce
    emissions. This does NOT hold when actions are chained (e.g. solar panels
    applied AFTER switching to a renewable PPA tariff can legitimately show a
    negative marginal reduction, since PPA electricity may already be cleaner
    than self-consumed solar's embodied-carbon factor) - that's the intended
    order-sensitivity behavior, not a bug.
    """
    profile, answers = make_test_profile_and_answers()
    for fn in ALL_CO2_FUNCTIONS:
        g, a, c = build_initial_state(profile, answers)
        g, a, reduction, c = fn(g, a, c, answers)
        assert reduction >= -0.01, f"{fn.__name__} produced a negative reduction in isolation: {reduction}"


def test_order_sensitivity_heat_pump_vs_insulation():
    """
    Applying insulation before a heat pump vs after should give DIFFERENT
    individual reduction values (since the heat pump sizes off the current
    heating_baseline) but the SAME final total regardless of order.
    """
    profile, answers = make_test_profile_and_answers()

    # Order A: insulation first, then heat pump
    g, a, c = build_initial_state(profile, answers)
    g, a, r_window, c = window_dp_co2(g, a, c, answers)
    g, a, r_door, c = door_dp_co2(g, a, c, answers)
    g, a, r_heatpump_A, c = heat_pumps_co2(g, a, c, answers)
    total_A = c["total_co2"]

    # Order B: heat pump first, then insulation
    g, a, c = build_initial_state(profile, answers)
    g, a, r_heatpump_B, c = heat_pumps_co2(g, a, c, answers)
    g, a, r_window_B, c = window_dp_co2(g, a, c, answers)
    g, a, r_door_B, c = door_dp_co2(g, a, c, answers)
    total_B = c["total_co2"]

    assert abs(r_heatpump_A - r_heatpump_B) > 0.01, (
        "Heat pump reduction should differ depending on whether insulation "
        "was applied first (this is the order-sensitivity feature)."
    )
    assert abs(total_A - total_B) < 0.5, (
        f"Final totals should match regardless of order: {total_A} vs {total_B}"
    )


def test_less_red_meat_floors_at_zero_and_stops_reducing():
    """Applying 'less red meat' more times than rm_days allows should not go negative,
    and should stop producing further reduction once rm_days hits 0."""
    profile, answers = make_test_profile_and_answers(rm_days=2)
    g, a, c = build_initial_state(profile, answers)

    for _ in range(2):
        g, a, reduction, c = less_rm_co2(g, a, c, answers)
        assert g["rm_days"] >= 0

    assert g["rm_days"] == 0

    # A third application should no-op: rm_days stays at 0, reduction should be 0
    g, a, reduction, c = less_rm_co2(g, a, c, answers)
    assert g["rm_days"] == 0
    assert abs(reduction) < 0.01, f"Expected zero reduction once rm_days hits 0, got {reduction}"


def test_less_white_meat_floors_at_zero():
    profile, answers = make_test_profile_and_answers(wm_days=1)
    g, a, c = build_initial_state(profile, answers)
    g, a, reduction, c = less_wm_co2(g, a, c, answers)
    assert g["wm_days"] == 0
    g, a, reduction, c = less_wm_co2(g, a, c, answers)
    assert g["wm_days"] == 0
    assert abs(reduction) < 0.01


def test_flat_property_zero_insulation_values_dont_crash():
    """Flats have 0 for loft_big/loft_small/floor in the insulation table -
    make sure applying these doesn't crash and produces a zero (not negative) reduction."""
    profile, answers = make_test_profile_and_answers(property_type="flat")
    g, a, c = build_initial_state(profile, answers)
    g, a, reduction, c = loft_insulation_co2(g, a, c, answers)
    assert abs(reduction) < 0.01, f"Expected ~0 reduction for flat loft insulation, got {reduction}"
    g, a, reduction, c = floor_insulation_co2(g, a, c, answers)
    assert abs(reduction) < 0.01, f"Expected ~0 reduction for flat floor insulation, got {reduction}"


def test_heat_pump_household_uses_electricity_branch_not_gas():
    """After a heat pump is installed, subsequent local heating actions should
    modify heating_electricity_kwh/annual_electricity_kwh, NOT annual_gas_kwh."""
    profile, answers = make_test_profile_and_answers()
    g, a, c = build_initial_state(profile, answers)
    g, a, r, c = heat_pumps_co2(g, a, c, answers)
    assert g["heating_type"] == "heat_pump"

    gas_before = a["annual_gas_kwh"]
    g, a, r, c = window_dp_co2(g, a, c, answers)
    assert a["annual_gas_kwh"] == gas_before, (
        "Gas should not change for a heat-pump household after window draughtproofing"
    )


def test_electric_shower_type_flows_through_without_crashing():
    """shorter_shower_co2 should run cleanly for an electric-shower household
    and should NOT reduce annual_gas_kwh (since an electric shower bypasses
    central heating)."""
    profile, answers = make_test_profile_and_answers(shower_type="electric_shower")
    g, a, c = build_initial_state(profile, answers)
    gas_before = a["annual_gas_kwh"]
    g, a, reduction, c = shorter_shower_co2(g, a, c, answers)
    assert a["annual_gas_kwh"] == gas_before, (
        "Electric shower household's gas use should be unaffected by shorter showers"
    )


def test_LED_zero_bulbs_is_a_safe_noop():
    """If a household reports zero bulbs of any type, LED_co2 should not crash
    and should produce zero reduction."""
    profile, answers = make_test_profile_and_answers()
    answers = {**answers, "incandescent_bulbs": 0, "cfl_bulbs": 0, "led_bulbs": 0}
    g, a, c = build_initial_state(profile, answers)
    g, a, reduction, c = LED_co2(g, a, c, answers)
    assert abs(reduction) < 0.01, f"Expected ~0 reduction with zero bulbs, got {reduction}"


def test_required_profile_keys_present():
    """Sanity check: build_initial_state + calculate_total_emissions shouldn't
    KeyError on a well-formed profile/answers. Catches schema drift early."""
    profile, answers = make_test_profile_and_answers()
    g, a, c = build_initial_state(profile, answers)
    result = calculate_total_emissions(g)
    assert "total_kg_co2e" in result
    assert result["total_kg_co2e"] > 0


# ---------------------------------------------------------------------------
# SIMPLE TEST RUNNER (works without pytest installed)
# ---------------------------------------------------------------------------

def _run_all_tests():
    import traceback
    test_fns = [obj for name, obj in list(globals().items())
                if name.startswith("test_") and callable(obj)]
    passed, failed = 0, 0
    print(f"Running {len(test_fns)} tests...\n" + "=" * 60)
    for fn in test_fns:
        try:
            fn()
            print(f"PASS  {fn.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"FAIL  {fn.__name__}\n      {e}")
            failed += 1
        except Exception as e:
            print(f"ERROR {fn.__name__}\n      {type(e).__name__}: {e}")
            traceback.print_exc(limit=3)
            failed += 1
    print("=" * 60)
    print(f"{passed} passed, {failed} failed out of {len(test_fns)}")
    return failed == 0


if __name__ == "__main__":
    import sys
    success = _run_all_tests()
    sys.exit(0 if success else 1)
