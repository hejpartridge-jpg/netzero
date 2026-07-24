import 'package:flutter/material.dart';

class ProfileStore extends ChangeNotifier {
  // ── Household ──────────────────────────────────────────
  int numPeople = 1;
  String address = '';
  String postcode = '';

  // ── Energy ─────────────────────────────────────────────
  double monthlyGasSpend = 0;
  String fuelType = 'natural_gas';
  double monthlyElecSpend = 0;
  double monthlySolarKwh = 0;
  String tariff = 'PPA';
  double monthlyWaterSpend = 0;
  int billingMonth = DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;

  // ── Transport ──────────────────────────────────────────
  double weeklyMileage = 0;
  String carFuel = 'petrol';
  String carSize = 'supermini';
  double monthlyBusSpend = 0;
  double monthlyTrainSpend = 0;

  // ── Flights & Accommodation ────────────────────────────
  List<Map<String, dynamic>> flights = [];
  List<Map<String, dynamic>> ukStays = [];

  // ── Diet ───────────────────────────────────────────────
  int rmDays = 0;
  int wmDays = 0;
  double nonMeatSpend = 0;

  // ── Waste ──────────────────────────────────────────────
  String foodWasteAction = 'bin';
  String wasteAction = 'non_recycle';

  // ── Pets ───────────────────────────────────────────────
  List<Map<String, dynamic>> pets = [];

  // ── Spending ───────────────────────────────────────────
  double monthlyTakeaway = 0;
  double monthlyDrinks = 0;
  double monthlyAlcohol = 0;
  double monthlyTobacco = 0;
  double monthlyClothes = 0;
  double monthlySoap = 0;
  double monthlyMedicine = 0;
  double yearlyElectronics = 0;
  double yearlyMachinery = 0;
  double monthlyEducation = 0;
  double monthlyHealthcare = 0;
  double monthlyCare = 0;
  double yearlyFurniture = 0;
  double monthlyServices = 0;

  // ── Energy Action Questions ───────────────────────────────────────────
  bool smartThermostat = false;
  bool savingSockets = false;
  bool solarPanels = false;
  bool batteryStorage = false;

  // ── Home Info Questions ───────────────────────────────────────────
  String hobType = 'gas';
  int incandescentBulbs = 0;
  int cflBulbs = 0;
  int ledBulbs = 0;
  String propertyType = 'semi_detached';
  String boilerAge = '10-15';
  String showerType = 'power_mixer';
  bool savingShower = false;
  String wallType = 'cavity';
  
  // ── Insulation Questions ───────────────────────────────────────────
  String insulationThickness = '0mm';
  bool windowDP = false;
  bool doorDP = false;
  bool cylinderJacket = false;
  bool radiatorPanels = false;
  bool wallInsulation = false;
  bool floorInsulation = false;

  // ── Habit Questions ──────────────────────────────────────────────────────────
  int showerTime = 5;
  String radiatorBleeding = 'this_year';
  int washingFrequency = 1;
  String washingTemperature = '40';

  // ── Habit Questions ──────────────────────────────────────────────────────────
  String homeowner = 'homeowner';

  // ── Action Tracking ─────────────────────────────────────────────────────────
  List<String> completedActions = [];
  List<Map<String, dynamic>> dismissedActions = [];

  // ── Convert to API profile dict ────────────────────────
  Map<String, dynamic> toProfile() {
    return {
      'num_people':               numPeople,
      'monthly_gas_spend':        monthlyGasSpend,
      'fuel_type':                fuelType,
      'monthly_elec_spend':       monthlyElecSpend,
      'billing_month':            billingMonth,
      'tariff':                   tariff,
      'monthly_solar':            monthlySolarKwh,
      'monthly_water_spend':      monthlyWaterSpend,
      'weekly_mileage':           weeklyMileage,
      'car_fuel':                 carFuel,
      'car_size':                 carSize,
      'monthly_bus_spend':        monthlyBusSpend,
      'monthly_train_spend':      monthlyTrainSpend,
      'flights':                  flights,
      'uk_stays':                 ukStays,
      'rm_days':                  rmDays,
      'wm_days':                  wmDays,
      'non_meat_spend':           nonMeatSpend,
      'food_waste_action':        foodWasteAction,
      'waste_action':             wasteAction,
      'pets':                     pets,
      'monthly_takeaway':         monthlyTakeaway,
      'monthly_drinks':           monthlyDrinks,
      'monthly_alcohol':          monthlyAlcohol,
      'monthly_tobacco':          monthlyTobacco,
      'monthly_clothes':          monthlyClothes,
      'monthly_soap':             monthlySoap,
      'monthly_medicine':         monthlyMedicine,
      'yearly_electronics':       yearlyElectronics,
      'yearly_machinery':         yearlyMachinery,
      'monthly_education':        monthlyEducation,
      'monthly_healthcare':       monthlyHealthcare,
      'monthly_care':             monthlyCare,
      'yearly_furniture':         yearlyFurniture,
      'monthly_services':         monthlyServices,
      'smart_thermostat':         smartThermostat,
      'energy_saving_sockets':    savingSockets,
      'solar_panels':             solarPanels,
      'battery_storage':          batteryStorage,
      'hob_type':                 hobType,
      'incandescent_bulbs':       incandescentBulbs,
      'cfl_bulbs':                cflBulbs,
      'led_bulbs':                ledBulbs,
      'property_type':            propertyType,
      'boiler_age':               boilerAge,
      'loft_thickness':           insulationThickness,
      'window_draught_proofing':  windowDP,
      'door_draught_proofing':    doorDP,
      'water_cylinder_jacket':    cylinderJacket,
      'radiator_panels':          radiatorPanels,   
      'shower_type':              showerType,  
      'water_saving_shower':      savingShower,
      'wall_type':                wallType,
      'wall_insulation':          wallInsulation,
      'floor_insulation':         floorInsulation,
      'shower_time':              showerTime,
      'last_radiator_bleed':      radiatorBleeding,
      'uses_per_week':            washingFrequency,
      'washing_temperature':      washingTemperature,
      'homeowner':                homeowner,
    };
  }

  // Call this whenever a value changes to notify all screens
  void update() => notifyListeners();
}