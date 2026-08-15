import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

double _d(dynamic v, double fallback) => (v as num?)?.toDouble() ?? fallback;
int _i(dynamic v, int fallback) => (v as num?)?.toInt() ?? fallback;
String _s(dynamic v, String fallback) => v as String? ?? fallback;
bool _b(dynamic v, bool fallback) => v as bool? ?? fallback;


class ProfileStore extends ChangeNotifier {
  // ── Household ──────────────────────────────────────────
  int? numPeople;
  String address = '';
  String postcode = '';

  // ── Energy ─────────────────────────────────────────────
  double monthlyGasSpend = 0;
  String fuelType = 'natural_gas';
  bool fuelTypeAnswered = false;
  double monthlyElecSpend = 0;
  double monthlySolarKwh = 0;
  bool solarPanelsAnswered = false;
  String tariff = 'standard';
  bool tariffAnswered = false;
  double monthlyWaterSpend = 0;
  bool? combinedBilling;
  double monthlyCombinedSpend = 0;
  int billingMonth = DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;

  // ── Transport ──────────────────────────────────────────
  List<Map<String, dynamic>> cars = [];
  String? currentCarSize;
  String? currentCarFuel;
  double monthlyBusSpend = 0;
  double monthlyTrainSpend = 0;

  // ── Flights & Accommodation ────────────────────────────
  List<Map<String, dynamic>> flights = [];
  String? currentTripCountry;
  int? currentTripNights;
  String? currentTripAccommodation;
  double hotelNights = 0;
  double airbnbNights = 0;

  // ── Diet ───────────────────────────────────────────────
  int rmDays = 0;
  int wmDays = 0;
  double nonMeatSpend = 0;

  // ── Waste ──────────────────────────────────────────────
  String? foodWasteAction;
  bool foodWasteAnswered = false;
  String? wasteAction;
  bool wasteAnswered = false;

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
  bool hobTypeAnswered = false;
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
      'monthly_combined_spend':   monthlyCombinedSpend,
      'combined_billing':         combinedBilling ?? false,
      'billing_month':            billingMonth,
      'tariff':                   tariff,
      'monthly_solar':            monthlySolarKwh,
      'monthly_water_spend':      monthlyWaterSpend,
      'cars':                     cars,
      'monthly_bus_spend':        monthlyBusSpend,
      'monthly_train_spend':      monthlyTrainSpend,
      'flights':                  flights,
      'uk_hotel_nights':          hotelNights,
      'uk_airbnb_nights':         airbnbNights,
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

  Map<String, dynamic> _toFirestoreData() {
    return {
      ...toProfile(),
      'completed_actions': completedActions,
      'dismissed_actions': dismissedActions,
      'solar_panels_answered': solarPanelsAnswered,
      'fuel_type_answered': fuelTypeAnswered,
      'hob_type_answered': hobTypeAnswered,
      'tariff_answered': tariffAnswered,
      'waste_answered': wasteAnswered,
      'food_waste_answered': foodWasteAnswered,
    };
  }

  Future<void> loadFromFirestore() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null) return;

    numPeople = (data['num_people'] as num?)?.toInt() ?? numPeople;
    monthlyGasSpend = _d(data['monthly_gas_spend'], monthlyGasSpend);
    fuelTypeAnswered = data['fuel_type_answered'] as bool? ?? fuelTypeAnswered;
    fuelType = _s(data['fuel_type'], fuelType);
    monthlyElecSpend = _d(data['monthly_elec_spend'], monthlyElecSpend);
    monthlyCombinedSpend = _d(data['monthly_combined_spend'], monthlyCombinedSpend);
    combinedBilling = data['combined_billing'] as bool?;
    billingMonth = _i(data['billing_month'], billingMonth);
    tariff = _s(data['tariff'], tariff);
    tariffAnswered = data['tariff_answered'] as bool? ?? tariffAnswered;
    solarPanelsAnswered = data['solar_panels_answered'] as bool? ?? solarPanelsAnswered;
    monthlySolarKwh = _d(data['monthly_solar'], monthlySolarKwh);
    monthlyWaterSpend = _d(data['monthly_water_spend'], monthlyWaterSpend);
    if (data['cars'] != null) {
      cars = List<Map<String, dynamic>>.from(
          (data['cars'] as List).map((e) => Map<String, dynamic>.from(e)));
    }
    monthlyBusSpend = _d(data['monthly_bus_spend'], monthlyBusSpend);
    monthlyTrainSpend = _d(data['monthly_train_spend'], monthlyTrainSpend);
    hotelNights = _d(data['uk_hotel_nights'], hotelNights);
    airbnbNights = _d(data['uk_airbnb_nights'], airbnbNights);

    if (data['flights'] != null) {
      flights = List<Map<String, dynamic>>.from(
          (data['flights'] as List).map((e) => Map<String, dynamic>.from(e)));
    }
    if (data['pets'] != null) {
      pets = List<Map<String, dynamic>>.from(
          (data['pets'] as List).map((e) => Map<String, dynamic>.from(e)));
    }

    rmDays = _i(data['rm_days'], rmDays);
    wmDays = _i(data['wm_days'], wmDays);
    nonMeatSpend = _d(data['non_meat_spend'], nonMeatSpend);
    foodWasteAction = data['food_waste_action'] as String? ?? foodWasteAction;
    foodWasteAnswered = data['food_waste_answered'] as bool? ?? foodWasteAnswered;
    wasteAction = data['waste_action'] as String? ?? wasteAction;
    wasteAnswered = data['waste_answered'] as bool? ?? wasteAnswered;
    monthlyTakeaway = _d(data['monthly_takeaway'], monthlyTakeaway);
    monthlyDrinks = _d(data['monthly_drinks'], monthlyDrinks);
    monthlyAlcohol = _d(data['monthly_alcohol'], monthlyAlcohol);
    monthlyTobacco = _d(data['monthly_tobacco'], monthlyTobacco);
    monthlyClothes = _d(data['monthly_clothes'], monthlyClothes);
    monthlySoap = _d(data['monthly_soap'], monthlySoap);
    monthlyMedicine = _d(data['monthly_medicine'], monthlyMedicine);
    yearlyElectronics = _d(data['yearly_electronics'], yearlyElectronics);
    yearlyMachinery = _d(data['yearly_machinery'], yearlyMachinery);
    monthlyEducation = _d(data['monthly_education'], monthlyEducation);
    monthlyHealthcare = _d(data['monthly_healthcare'], monthlyHealthcare);
    monthlyCare = _d(data['monthly_care'], monthlyCare);
    yearlyFurniture = _d(data['yearly_furniture'], yearlyFurniture);
    monthlyServices = _d(data['monthly_services'], monthlyServices);
    smartThermostat = _b(data['smart_thermostat'], smartThermostat);
    savingSockets = _b(data['energy_saving_sockets'], savingSockets);
    solarPanels = _b(data['solar_panels'], solarPanels);
    batteryStorage = _b(data['battery_storage'], batteryStorage);
    hobTypeAnswered = data['hob_type_answered'] as bool? ?? hobTypeAnswered;
    hobType = _s(data['hob_type'], hobType);
    incandescentBulbs = _i(data['incandescent_bulbs'], incandescentBulbs);
    cflBulbs = _i(data['cfl_bulbs'], cflBulbs);
    ledBulbs = _i(data['led_bulbs'], ledBulbs);
    propertyType = _s(data['property_type'], propertyType);
    boilerAge = _s(data['boiler_age'], boilerAge);
    insulationThickness = _s(data['loft_thickness'], insulationThickness);
    windowDP = _b(data['window_draught_proofing'], windowDP);
    doorDP = _b(data['door_draught_proofing'], doorDP);
    cylinderJacket = _b(data['water_cylinder_jacket'], cylinderJacket);
    radiatorPanels = _b(data['radiator_panels'], radiatorPanels);
    showerType = _s(data['shower_type'], showerType);
    savingShower = _b(data['water_saving_shower'], savingShower);
    wallType = _s(data['wall_type'], wallType);
    wallInsulation = _b(data['wall_insulation'], wallInsulation);
    floorInsulation = _b(data['floor_insulation'], floorInsulation);
    showerTime = _i(data['shower_time'], showerTime);
    radiatorBleeding = _s(data['last_radiator_bleed'], radiatorBleeding);
    washingFrequency = _i(data['uses_per_week'], washingFrequency);
    washingTemperature = _s(data['washing_temperature'], washingTemperature);
    homeowner = _s(data['homeowner'], homeowner);

    if (data['completed_actions'] != null) {
      completedActions = List<String>.from(data['completed_actions']);
    }
    if (data['dismissed_actions'] != null) {
      dismissedActions = List<Map<String, dynamic>>.from(
          (data['dismissed_actions'] as List).map((e) => Map<String, dynamic>.from(e)));
    }
  } catch (e) {
    print('Failed to load saved progress: $e');
  }
  }

  Future<void> _saveToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(_toFirestoreData());
    } catch (e) {
      print('Failed to save progress: $e');
    }
  }

  void update() {
    notifyListeners();
    _saveToFirestore();
  }
}
