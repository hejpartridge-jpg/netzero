import 'package:flutter/material.dart';

class ProfileStore extends ChangeNotifier {
  // ── Household ──────────────────────────────────────────
  int numPeople = 1;
  String address = '';
  String postcode = '';

  // ── Energy ─────────────────────────────────────────────
  double annualGasKwh = 0;
  String fuelType = 'natural_gas';
  double annualElectricityKwh = 0;
  String tariff = 'PPA';
  double annualWaterM3 = 0;

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

  // ── Convert to API profile dict ────────────────────────
  Map<String, dynamic> toProfile() {
    return {
      'num_people':               numPeople,
      'annual_gas_kwh':           annualGasKwh,
      'fuel_type':                fuelType,
      'annual_electricity_kwh':   annualElectricityKwh,
      'tariff':                   tariff,
      'annual_water_m3':          annualWaterM3,
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
    };
  }

  // Call this whenever a value changes to notify all screens
  void update() => notifyListeners();
}