import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'profile_store.dart';
import 'theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ProfileStore(),
      child: NetZeroApp(),
    ),
  );
}

// ── Router ──────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/welcome',
  routes: [
    GoRoute(path: '/welcome',      builder: (context, state) => WelcomeScreen()),
    GoRoute(path: '/household',    builder: (context, state) => HouseholdScreen()),
    GoRoute(path: '/energy',       builder: (context, state) => EnergyScreen()),
    GoRoute(path: '/transport',    builder: (context, state) => TransportScreen()),
    GoRoute(path: '/flights',      builder: (context, state) => FlightsScreen()),
    GoRoute(path: '/diet',         builder: (context, state) => DietScreen()),
    GoRoute(path: '/pets',         builder: (context, state) => PetsScreen()),
    GoRoute(path: '/spending',     builder: (context, state) => SpendingScreen()),
    GoRoute(path: '/results',      builder: (context, state) => ResultsScreen()),
  ],
);

// ── App ─────────────────────────────────────────────────
class NetZeroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Net Zero Planner',
      routerConfig: _router,
      theme: buildTheme(),
    );
  }
}

// ── Placeholder screen builder ───────────────────────────
Widget _placeholder(String title, String next, BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          onPressed: () => context.go(next),
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 18),
            shape: StadiumBorder(),
          ),
          child: Text(
            'Next →',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ),
  );
}

// ── Welcome Screen ─────────────────────────────────────────────────────────
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo/icon
                Icon(
                  Icons.eco,
                  size: 64,
                  color: kPrimary,
                ),
                SizedBox(height: 32),

                // Title
                Text(
                  'Net Zero\nPlanner',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  'Calculate your household\'s carbon footprint and get a personalised plan to reach net zero.',
                  style: TextStyle(
                    fontSize: 18,
                    color: kTextSubtle,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 48),

                // Start button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/household'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Get Started',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Time estimate
                Center(
                  child: Text(
                    'Takes about 10 minutes',
                    style: TextStyle(color: kTextSubtle),
                  ),
                ),
              ],
            ),
          ),
        ),   // ← closes screenWrapper
      ),     // ← closes SafeArea
    );       // ← closes Scaffold
  }
}


// ── Household Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
class HouseholdScreen extends StatefulWidget {
  @override
  _HouseholdScreenState createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends State<HouseholdScreen> {
  final _postcodeController = TextEditingController();
  int _numPeople = 1;

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(

      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                // Progress indicator

                SizedBox(height: 0), //these are empty spaces, put them wherever you want a gap
                
                Text(
                  'Your Household',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                progressBar(0.1),
                SizedBox(height: 24),

                Text(
                  'Tell us about your household',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This helps us personalise your results.',
                  style: TextStyle(color: kTextSubtle),
                ),
                SizedBox(height: 50),

                // Postcode input
                Text('Postcode',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                TextField(
                  controller: _postcodeController,
                  decoration: InputDecoration(
                    hintText: 'e.g. SW1A 1AA',
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                SizedBox(height: 65),

                // Number of people
                Text('Number of people in your household',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_numPeople > 1) setState(() => _numPeople--);
                      },
                      icon: Icon(Icons.remove_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                    Text(
                      '$_numPeople',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: kText),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _numPeople++),
                      icon: Icon(Icons.add_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                  ],
                ),

                Spacer(),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.postcode = _postcodeController.text;
                      profile.numPeople = _numPeople;
                      profile.update();
                      context.go('/energy');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),   // ← closes screenWrapper
      ),     // ← closes SafeArea
    );       // ← closes Scaffold
  }
}

// ── Energy Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

class EnergyScreen extends StatefulWidget {
  @override
  _EnergyScreenState createState() => _EnergyScreenState();
}

class _EnergyScreenState extends State<EnergyScreen> {
  final _gasController = TextEditingController();
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();
  final _solarController = TextEditingController();
  String _fuelType = 'natural_gas';
  String _tariff = 'PPA';

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  SizedBox(height: 0),

                  Text(
                    'Home Energy',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  progressBar(0.2),
                  SizedBox(height: 24),

                  Text(
                    'How much energy does your home use?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find these figures on your energy bills.',
                    style: TextStyle(color: kTextSubtle),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Fuel type dropdown
                  Text('Heating fuel type',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _fuelType,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'natural_gas', child: Text('Natural Gas')),
                      DropdownMenuItem(value: 'lpg', child: Text('LPG')),
                    ],
                    onChanged: (value) => setState(() => _fuelType = value!),
                  ),
                  SizedBox(height: 24),

                  // Gas usage
                  Text('Annual gas usage (kWh)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _gasController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 12000',
                      suffixText: 'kWh',
                    ),
                  ),
                  SizedBox(height: 24),

                  // Electricity usage
                  Text('Annual electricity usage (kWh)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  Text(
                    'Energy you buy from the grid, plus any additional energy you consume from solar panels.',
                    style: TextStyle(color: kTextSubtle),
                    textAlign: TextAlign.center,
                  ),
                  TextField(
                    controller: _electricityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 3100',
                      suffixText: 'kWh',
                    ),
                  ),
                  SizedBox(height: 24),

                  // Tariff type dropdown
                  Text('Tariff type',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _tariff,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'standard', child: Text('Standard Tariff')),
                      DropdownMenuItem(value: 'PPA', child: Text('PPA Tariff')),
                    ],
                    onChanged: (value) => setState(() => _tariff = value!),
                  ),
                  SizedBox(height: 24),

                  // Solar usage
                  Text('Annual electricity you consume from any solar panels (kWh)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  Text(
                    'Energy you use NOT energy you export.',
                    style: TextStyle(color: kTextSubtle),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _solarController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 2000',
                      suffixText: 'kWh',
                    ),
                  ),
                  SizedBox(height: 24),

                  // Water usage
                  Text('Annual water usage (m³)',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _waterController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 100',
                      suffixText: 'm³',
                    ),
                  ),

                  SizedBox(height: 32),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.fuelType = _fuelType;
                        profile.tariff = _tariff;
                        profile.annualGasKwh = double.tryParse(_gasController.text) ?? 0;
                        profile.annualElectricityKwh = double.tryParse(_electricityController.text) ?? 0;
                        profile.annualSolarKwh = double.tryParse(_solarController.text) ?? 0;
                        profile.annualWaterM3 = double.tryParse(_waterController.text) ?? 0;
                        profile.update();
                        context.go('/transport');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: Text(
                        'Next →',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Transport Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

class TransportScreen extends StatefulWidget {
  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _mileageController = TextEditingController();
  final _busController = TextEditingController();
  final _trainController = TextEditingController();
  String _fuelType = 'petrol';
  String _carSize = 'supermini';

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 0),

                Text(
                  'Transport',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                progressBar(0.3),
                SizedBox(height: 24),

                Text(
                  'CO2 emissions from transport',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Car type dropdown
                Text('Car type',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _carSize,
                  selectedItemBuilder: (context) => [
                    Text('Mini'),
                    Text('Supermini'),
                    Text('Lower Medium'),
                    Text('Upper Medium'),
                    Text('Executive'),
                    Text('Luxury'),
                    Text('Sports'),
                    Text('Dual Purpose / SUV'),
                    Text('MPV / People Carrier'),
                  ],
                  decoration: InputDecoration(),
                  items: [
                    DropdownMenuItem(
                      value: 'mini',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Mini'),
                          Text('e.g. Fiat 500, Smart Car', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'supermini',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Supermini'),
                          Text('e.g. VW Polo, Ford Fiesta', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'lower medium',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Lower Medium'),
                          Text('e.g. VW Golf, Ford Focus', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'upper medium',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Upper Medium'),
                          Text('e.g. BMW 3 Series, Audi A4', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'executive',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Executive'),
                          Text('e.g. BMW 5 Series, Mercedes E-Class', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'luxury',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Luxury'),
                          Text('e.g. Mercedes S-Class, Bentley', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'sports',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Sports'),
                          Text('e.g. Porsche 911, Mazda MX-5', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'dual purpose',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Dual Purpose / SUV'),
                          Text('e.g. Toyota RAV4, VW Tiguan', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'mpv',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('MPV / People Carrier'),
                          Text('e.g. Ford Galaxy, VW Sharan', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _carSize = value!),
                ),
                SizedBox(height: 24),

                // Fuel type dropdown
                Text('Fuel type',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _fuelType,
                  decoration: InputDecoration(),
                  items: [
                    DropdownMenuItem(value: 'petrol', child: Text('Petrol')),
                    DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                    DropdownMenuItem(value: 'plug in hybrid', child: Text('Plug In Hybrid')),
                    DropdownMenuItem(value: 'electric', child: Text('Electric')),
                  ],
                  onChanged: (value) => setState(() => _fuelType = value!),
                ),
                SizedBox(height: 24),


                // Car Mileage
                Text('Weekly Mileage',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                TextField(
                  controller: _mileageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 150',
                    suffixText: 'miles',
                  ),
                ),
                SizedBox(height: 24),

                // Public transport usage
                Text('Monthly Spending On Buses Or Taxis (£)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                TextField(
                  controller: _busController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 20',
                    suffixText: '£',
                  ),
                ),
                SizedBox(height: 24),

                // Train usage
                Text('Monthly Spending On Trains (£)',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                TextField(
                  controller: _trainController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. 25',
                    suffixText: '£',
                  ),
                ),

                Spacer(),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.carFuel = _fuelType;
                      profile.carSize = _carSize;
                      profile.weeklyMileage = double.tryParse(_mileageController.text) ?? 0;
                      profile.monthlyBusSpend = double.tryParse(_busController.text) ?? 0;
                      profile.monthlyTrainSpend = double.tryParse(_trainController.text) ?? 0;
                      profile.update();
                      context.go('/flights');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Flights Screen ────────────────────────────────────────────────────────────
class FlightsScreen extends StatefulWidget {
  @override
  _FlightsScreenState createState() => _FlightsScreenState();
}

class _FlightsScreenState extends State<FlightsScreen> {
  List<Map<String, dynamic>> _trips = [];
  List<Map<String, dynamic>> _ukStays = [];

  void _addTrip() {
    setState(() {
      _trips.add({
        'country': 'France',
        'seat': 'economy',
        'passengers': 1,
        'nights': 0,
        'accommodation': 'hotel',
      });
    });
  }

  void _removeTrip(int index) {
    setState(() => _trips.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 0),
                Text(
                  'Flights & Holidays',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                progressBar(0.4),
                SizedBox(height: 24),

                Text(
                  'Where did you travel last year?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Add each trip separately.',
                  style: TextStyle(color: kTextSubtle),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Scrollable list of trips + UK stays
                Expanded(
                  child: ListView(
                    children: [

                      // Abroad trips
                      ..._trips.asMap().entries.map((entry) {
                        int i = entry.key;
                        Map<String, dynamic> trip = entry.value;
                        return _buildTripCard(i, trip);
                      }).toList(),

                      // Add trip button
                      SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: _addTrip,
                        icon: Icon(Icons.add, color: kPrimary),
                        label: Text('Add a trip',
                            style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: kPrimary),
                          shape: StadiumBorder(),
                        ),
                      ),

                      // UK stays section
                      SizedBox(height: 24),
                      Text(
                        'UK hotel or Airbnb stays',
                        style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      _buildUkStayCard(),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.flights = _trips;
                      profile.ukStays = _ukStays;
                      profile.update();
                      context.go('/diet');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getHaulType(String country) {
    const domestic = ['United Kingdom', 'Guernsey', 'Isle Of Man', 'Jersey'];
    const shortHaul = ['France', 'Germany', 'Spain', 'Italy', 'Greece', 
      'Portugal', 'Netherlands', 'Belgium', 'Ireland', 'Austria', 'Switzerland',
      'Denmark', 'Norway', 'Sweden', 'Finland', 'Poland', 'Czech Republic',
      'Hungary', 'Romania', 'Bulgaria', 'Croatia', 'Albania', 'Algeria',
      'Belarus', 'Bosnia-Herzegovina', 'Cyprus', 'Egypt', 'Estonia',
      'Faroe Islands', 'Gibraltar', 'Greenland', 'Iceland', 'Kosovo',
      'Latvia', 'Libya', 'Lithuania', 'Luxembourg', 'Macedonia', 'Malta',
      'Moldova', 'Montenegro', 'Morocco', 'Serbia', 'Slovak Republic',
      'Slovenia', 'Tunisia', 'Turkey', 'Ukraine', 'Western Sahara',
      'DR Congo', 'Lithuania',
    ];
    if (domestic.contains(country)) return 'domestic';
    if (shortHaul.contains(country)) return 'short_haul';
    return 'long_haul';
  }

  List<DropdownMenuItem<String>> _getSeatItems(String country) {
    String haul = _getHaulType(country);
    if (haul == 'domestic') {
      return [
        DropdownMenuItem(value: 'average', child: Text('Average')),
      ];
    } else if (haul == 'short_haul') {
      return [
        DropdownMenuItem(value: 'economy', child: Text('Economy')),
        DropdownMenuItem(value: 'business', child: Text('Business')),
      ];
    } else {
      return [
        DropdownMenuItem(value: 'economy', child: Text('Economy')),
        DropdownMenuItem(value: 'premium_economy', child: Text('Premium Economy')),
        DropdownMenuItem(value: 'business', child: Text('Business')),
        DropdownMenuItem(value: 'first', child: Text('First Class')),
      ];
    }
  }

  Widget _buildTripCard(int index, Map<String, dynamic> trip) {
    final countries = [
      'Afghanistan', 'Albania', 'Algeria', 'American Samoa', 'Angola',
      'Anguilla', 'Antigua and Barbuda', 'Argentina', 'Armenia', 'Aruba',
      'Ascension Island', 'Australia', 'Austria', 'Azerbaijan', 'Bahamas',
      'Bahrain', 'Bangladesh', 'Barbados', 'Belarus', 'Belgium', 'Belize',
      'Benin', 'Bermuda', 'Bolivia', 'Bosnia-Herzegovina', 'Botswana',
      'Brazil', 'British Virgin Islands', 'Brunei', 'Bulgaria', 'Burkina Faso',
      'Burundi', 'Cambodia', 'Cameroon', 'Canada', 'Cape Verde',
      'Cayman Islands', 'Central African Republic', 'Chad', 'Chile', 'China',
      'Colombia', 'Comoros', 'Congo-Brazzaville', 'Cook Islands', 'Costa Rica',
      'Croatia', 'Cuba', 'Curacao', 'Cyprus', 'Czech Republic', 'Denmark',
      'Djibouti', 'Dominica', 'Dominican Republic', 'DR Congo', 'Ecuador',
      'Egypt', 'El Salvador', 'Equatorial Guinea', 'Eritrea', 'Estonia',
      'Ethiopia', 'Falkland Islands', 'Faroe Islands', 'Fiji', 'Finland',
      'France', 'French Guiana', 'Gabon', 'Gambia', 'Georgia', 'Germany',
      'Ghana', 'Gibraltar', 'Greece', 'Greenland', 'Grenada', 'Guadeloupe',
      'Guam', 'Guatemala', 'Guernsey', 'Guinea', 'Guinea-Bissau', 'Guyana',
      'Haiti', 'Honduras', 'Hong Kong', 'Hungary', 'Iceland', 'India',
      'Indonesia', 'Iran', 'Iraq', 'Ireland', 'Isle Of Man', 'Israel',
      'Italy', 'Ivory Coast', 'Jamaica', 'Japan', 'Jersey', 'Jordan',
      'Kazakhstan', 'Kenya', 'Kosovo', 'Kuwait', 'Kyrgyzstan', 'Laos',
      'Latvia', 'Lebanon', 'Lesotho', 'Liberia', 'Libya', 'Lithuania',
      'Luxembourg', 'Macao', 'Macedonia', 'Madagascar', 'Malawi', 'Malaysia',
      'Maldives', 'Mali', 'Malta', 'Marshall Islands', 'Martinique',
      'Mauritania', 'Mauritius', 'Mexico', 'Moldova', 'Mongolia', 'Montenegro',
      'Morocco', 'Mozambique', 'Myanmar', 'Namibia', 'Nepal', 'Netherlands',
      'New Caledonia', 'New Zealand', 'Nicaragua', 'Niger', 'Nigeria',
      'North Korea', 'Norway', 'Oman', 'Pakistan', 'Palau', 'Panama',
      'Papua New Guinea', 'Paraguay', 'Peru', 'Philippines', 'Poland',
      'Portugal', 'Puerto Rico', 'Qatar', 'Reunion', 'Romania', 'Russia',
      'Rwanda', 'Sao Tome Islands', 'Saudi Arabia', 'Senegal', 'Serbia',
      'Seychelles', 'Sierra Leone', 'Singapore', 'Slovak Republic', 'Slovenia',
      'Solomon Islands', 'Somali Republic', 'South Africa', 'South Korea',
      'South Sudan', 'Spain', 'Sri Lanka', 'St Kitts and Nevis', 'St Lucia',
      'St Vincent and the Grenadines', 'Sudan', 'Surinam', 'Swaziland',
      'Sweden', 'Switzerland', 'Syria', 'Tahiti', 'Taiwan', 'Tajikistan',
      'Tanzania', 'Thailand', 'Timor', 'Togo', 'Tonga', 'Trinidad and Tobago',
      'Tunisia', 'Turkey', 'Turkmenistan', 'Turks and Caicos Islands', 'Uganda',
      'Ukraine', 'United Arab Emirates', 'United Kingdom', 'United States',
      'Uruguay', 'Uzbekistan', 'Vanuatu', 'Venezuela', 'Vietnam',
      'Virgin Islands (U.S.A)', 'Wake Islands', 'Western Sahara', 'Yemen',
      'Zambia', 'Zimbabwe',
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header with remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trip ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
              IconButton(
                onPressed: () => _removeTrip(index),
                icon: Icon(Icons.close, color: kTextSubtle, size: 20),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // Country dropdown
          Text('Destination', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: trip['country'],
            decoration: InputDecoration(isDense: true),
            items: countries.map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (value) {
              setState(() {
                _trips[index]['country'] = value!;
                String haul = _getHaulType(value);
                if (haul == 'domestic') {
                  _trips[index]['seat'] = 'average';
                } else {
                  _trips[index]['seat'] = 'economy';
                }
              });
            },
          ),
          if (trip['country'] == 'United Kingdom' ||
              trip['country'] == 'Guernsey' ||
              trip['country'] == 'Isle Of Man' ||
              trip['country'] == 'Jersey')
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                '✈ Domestic flight — e.g. London to Edinburgh',
                style: TextStyle(fontSize: 11, color: kPrimary),
              ),
            ),
          SizedBox(height: 12),

          // Seat class — dynamic based on country
          Text('Seat class', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: trip['seat'],
            decoration: InputDecoration(isDense: true),
            items: _getSeatItems(trip['country']),
            onChanged: (value) => setState(() => _trips[index]['seat'] = value!),
          ),
          SizedBox(height: 12),

          // Passengers and nights
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Passengers', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (trip['passengers'] > 1)
                              setState(() => _trips[index]['passengers']--);
                          },
                          icon: Icon(Icons.remove_circle_outline, color: kPrimary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        Text('${trip['passengers']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setState(() => _trips[index]['passengers']++),
                          icon: Icon(Icons.add_circle_outline, color: kPrimary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nights', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (trip['nights'] > 0)
                              setState(() => _trips[index]['nights']--);
                          },
                          icon: Icon(Icons.remove_circle_outline, color: kPrimary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                        Text('${trip['nights']}',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => setState(() => _trips[index]['nights']++),
                          icon: Icon(Icons.add_circle_outline, color: kPrimary, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Accommodation type
          Text('Accommodation', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: trip['accommodation'],
            decoration: InputDecoration(isDense: true),
            items: [
              DropdownMenuItem(value: 'hotel', child: Text('Hotel')),
              DropdownMenuItem(value: 'airbnb', child: Text('Airbnb / Holiday Let')),
              DropdownMenuItem(value: 'camping', child: Text('Camping')),
              DropdownMenuItem(value: 'homestay', child: Text('Staying with Friends/Family')),
            ],
            onChanged: (value) => setState(() => _trips[index]['accommodation'] = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildUkStayCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UK Stays', style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
          SizedBox(height: 4),
          Text('Hotels, Airbnbs or B&Bs within the UK',
              style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 12),

          // Existing UK stays
          ..._ukStays.asMap().entries.map((entry) {
            int i = entry.key;
            Map<String, dynamic> stay = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Stay ${i + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
                      IconButton(
                        onPressed: () => setState(() => _ukStays.removeAt(i)),
                        icon: Icon(Icons.close, color: kTextSubtle, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Type dropdown
                  Text('Type', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                  SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: stay['type'],
                    decoration: InputDecoration(isDense: true),
                    items: [
                      DropdownMenuItem(value: 'hotel', child: Text('Hotel / B&B')),
                      DropdownMenuItem(value: 'airbnb', child: Text('Airbnb / Holiday Let')),
                      DropdownMenuItem(value: 'camping', child: Text('Camping')),
                      DropdownMenuItem(value: 'homestay', child: Text('Friends / Family')),
                    ],
                    onChanged: (value) => setState(() => _ukStays[i]['type'] = value!),
                  ),
                  SizedBox(height: 8),

                  // People and nights
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('People', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (stay['people'] > 1)
                                      setState(() => _ukStays[i]['people']--);
                                  },
                                  icon: Icon(Icons.remove_circle_outline, color: kPrimary, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                Text('${stay['people']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () => setState(() => _ukStays[i]['people']++),
                                  icon: Icon(Icons.add_circle_outline, color: kPrimary, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Nights', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (stay['nights'] > 0)
                                      setState(() => _ukStays[i]['nights']--);
                                  },
                                  icon: Icon(Icons.remove_circle_outline, color: kPrimary, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                                Text('${stay['nights']}',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  onPressed: () => setState(() => _ukStays[i]['nights']++),
                                  icon: Icon(Icons.add_circle_outline, color: kPrimary, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),

          // Add UK stay button
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _ukStays.add({'people': 1, 'nights': 1, 'type': 'hotel'});
              });
            },
            icon: Icon(Icons.add, color: kPrimary),
            label: Text('Add UK stay',
                style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: kPrimary),
              shape: StadiumBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Diet Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

class DietScreen extends StatefulWidget {
  @override
  _DietScreenState createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  int _rmDays = 0;  
  int _wmDays = 0;
  final _shoppingController = TextEditingController();
  String _foodWaste = 'compost';
  String _normalWaste = 'recycle';

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 0),

                Text(
                  'Diet And Waste',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                progressBar(0.5),
                SizedBox(height: 24),

                Text(
                  'Eating and waste habits',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),

                // Red meat days
                Text('Number of days a week that you eat red meat',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_rmDays > 0) setState(() => _rmDays--);
                      },
                      icon: Icon(Icons.remove_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                    Text(
                      '$_rmDays',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: kText),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_rmDays < 7) setState(() => _rmDays++);
                      },
                      icon: Icon(Icons.add_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                  ],
                ),

                // White meat days
                Text('Number of days a week that you eat white meat',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_wmDays > 0) setState(() => _wmDays--);
                      },
                      icon: Icon(Icons.remove_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                    Text(
                      '$_wmDays',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: kText),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_wmDays < 7) setState(() => _wmDays++);
                      },
                      icon: Icon(Icons.add_circle_outline),
                      color: kPrimary,
                      iconSize: 32,
                    ),
                  ],
                ),

                // Shopping spend
                Text('Weekly shopping spend on non-meat items',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                TextField(
                  controller: _shoppingController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'e.g. £60',
                    suffixText: 'per week',
                  ),
                ),
                SizedBox(height: 24),

                // Food waste dropdown
                Text('What do you generally do with your food waste?',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _foodWaste,
                  decoration: InputDecoration(),
                  items: [
                    DropdownMenuItem(value: 'bin', child: Text('Normal bin')),
                    DropdownMenuItem(value: 'compost', child: Text('Compost/Food waste bin')),
                  ],
                  onChanged: (value) => setState(() => _foodWaste = value!),
                ),
                SizedBox(height: 24),

                // Normal waste dropdown
                Text('What do you generally do with your everyday waste?',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _normalWaste,
                  decoration: InputDecoration(),
                  items: [
                    DropdownMenuItem(value: 'recycle', child: Text('Recycle')),
                    DropdownMenuItem(value: 'non_recycle', child: Text('Normal bin')),
                    DropdownMenuItem(value: 'upcycle', child: Text('Upcycle')),
                  ],
                  onChanged: (value) => setState(() => _normalWaste = value!),
                ),
                SizedBox(height: 24),                

                Spacer(),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.rmDays = _rmDays;
                      profile.wmDays = _wmDays;
                      profile.nonMeatSpend = double.tryParse(_shoppingController.text) ?? 0;
                      profile.foodWasteAction = _foodWaste;
                      profile.wasteAction = _normalWaste;
                      profile.update();
                      context.go('/pets');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pets Screen ────────────────────────────────────────────────────────────
class PetsScreen extends StatefulWidget {
  @override
  _PetsScreenState createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  List<Map<String, dynamic>> _pets = [];

  void _addPet() {
    setState(() {
      _pets.add({
        'type': 'dog',
        'food': 'dry',
        'brand': 'standard',
        'diet': 'meaty',
        'weight': 0,
      });
    });
  }

  void _removePet(int index) {
    setState(() => _pets.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 0),
                Text(
                  'Pets',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                progressBar(0.7),
                SizedBox(height: 24),

                Text(
                  'What pets do you have?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Add each pet separately.',
                  style: TextStyle(color: kTextSubtle),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Scrollable list of trips + UK stays
                Expanded(
                  child: ListView(
                    children: [

                      // Pets
                      ..._pets.asMap().entries.map((entry) {
                        int i = entry.key;
                        Map<String, dynamic> pet = entry.value;
                        return _buildPetCard(i, pet);
                      }).toList(),

                      // Add pet button
                      SizedBox(height: 4),
                      OutlinedButton.icon(
                        onPressed: _addPet,
                        icon: Icon(Icons.add, color: kPrimary),
                        label: Text('Add a pet',
                            style: TextStyle(color: kPrimary, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: kPrimary),
                          shape: StadiumBorder(),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.pets = _pets;
                      profile.update();
                      context.go('/spending');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(int index, Map<String, dynamic> pet) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header with remove button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pet ${index + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
              IconButton(
                onPressed: () => _removePet(index),
                icon: Icon(Icons.close, color: kTextSubtle, size: 20),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Species dropdown
          Text('Species', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: pet['type'],
            decoration: InputDecoration(isDense: true),
            items: [
              DropdownMenuItem(value: 'dog', child: Text('Dog')),
              DropdownMenuItem(value: 'cat', child: Text('Cat')),
            ],
            onChanged: (value) => setState(() => _pets[index]['type'] = value!),
          ),
          SizedBox(height: 8),

          // Food type dropdown
          Text('Food Type', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: pet['food'],
            decoration: InputDecoration(isDense: true),
            items: [
              DropdownMenuItem(value: 'wet', child: Text('Wet')),
              DropdownMenuItem(value: 'dry', child: Text('Dry')),
            ],
            onChanged: (value) => setState(() => _pets[index]['food'] = value!),
          ),
          SizedBox(height: 8),

          // Brand dropdown
          Text('Brand', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: pet['brand'],
            decoration: InputDecoration(isDense: true),
            items: [
              DropdownMenuItem(value: 'premium', child: Text('Premium')),
              DropdownMenuItem(value: 'standard', child: Text('Standard')),
            ],
            onChanged: (value) => setState(() => _pets[index]['brand'] = value!),
          ),
          SizedBox(height: 8),

          // Diet dropdown
          Text('Diet', style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: pet['diet'],
            decoration: InputDecoration(isDense: true),
            items: [
              DropdownMenuItem(value: 'meaty', child: Text('Meat-based')),
              DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
            ],
            onChanged: (value) => setState(() => _pets[index]['diet'] = value!),
          ),
          SizedBox(height: 8),

          // Daily food weight
          Text('Daily food amount (grams)',
              style: TextStyle(fontSize: 12, color: kTextSubtle)),
          SizedBox(height: 4),
          TextField(
            controller: TextEditingController(
                text: pet['weight'] == 0 ? '' : pet['weight'].toString()),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              hintText: 'e.g. 500g',
              suffixText: 'per day',
            ),
            onChanged: (value) =>
                setState(() => _pets[index]['weight'] = int.tryParse(value) ?? 0),
          ),
        ],
      ),
    );
  }
}

// ── Spending Screen ────────────────────────────────────────────────────────────
class SpendingScreen extends StatefulWidget {
  @override
  _SpendingScreenState createState() => _SpendingScreenState();
}

class _SpendingScreenState extends State<SpendingScreen> {
  final _takeawayController = TextEditingController(text: '0');
  final _drinksController = TextEditingController(text: '0');
  final _alcoholController = TextEditingController(text: '0');
  final _tobaccoController = TextEditingController(text: '0');
  final _clothesController = TextEditingController(text: '0');
  final _soapController = TextEditingController(text: '0');
  final _medicineController = TextEditingController(text: '0');
  final _electronicsController = TextEditingController(text: '0');
  final _machineryController = TextEditingController(text: '0');
  final _educationController = TextEditingController(text: '0');
  final _healthcareController = TextEditingController(text: '0');
  final _careController = TextEditingController(text: '0');
  final _furnitureController = TextEditingController(text: '0');
  final _servicesController = TextEditingController(text: '0');

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                SizedBox(height: 0),
                Text(
                  'Spending',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                progressBar(0.8),
                SizedBox(height: 24),

                Text(
                  'Your spending habits',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Enter 0 for categories that don\'t apply to you.',
                  style: TextStyle(color: kTextSubtle),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Scrollable list of inputs
                Expanded(
                  child: ListView(
                    children: [

                      // ── Monthly spending ──────────────────────────
                      _sectionHeader('Monthly Spending'),
                      SizedBox(height: 12),

                      _spendField('Eating out & takeaways', _takeawayController, '£', 'per month'),
                      _spendField('Soft drinks', _drinksController, '£', 'per month'),
                      _spendField('Alcohol', _alcoholController, '£', 'per month'),
                      _spendField('Tobacco', _tobaccoController, '£', 'per month'),
                      _spendField('Clothing & footwear', _clothesController, '£', 'per month'),
                      _spendField('Soaps & detergents', _soapController, '£', 'per month'),
                      _spendField('Medicines', _medicineController, '£', 'per month'),
                      _spendField('Education (e.g. tuition, courses)', _educationController, '£', 'per month'),
                      _spendField('Healthcare (e.g. private appointments)', _healthcareController, '£', 'per month'),
                      _spendField('Care homes', _careController, '£', 'per month'),
                      _spendField('Services (e.g. haircuts, repairs)', _servicesController, '£', 'per month'),

                      SizedBox(height: 24),

                      // ── Yearly spending ───────────────────────────
                      _sectionHeader('Yearly Spending'),
                      SizedBox(height: 12),

                      _spendField('Electronics (phones, laptops, gadgets)', _electronicsController, '£', 'per year'),
                      _spendField('Tools & machinery', _machineryController, '£', 'per year'),
                      _spendField('Furniture & homewares', _furnitureController, '£', 'per year'),

                      SizedBox(height: 16),
                    ],
                  ),
                ),

                // Next button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      profile.monthlyTakeaway   = double.tryParse(_takeawayController.text) ?? 0;
                      profile.monthlyDrinks     = double.tryParse(_drinksController.text) ?? 0;
                      profile.monthlyAlcohol    = double.tryParse(_alcoholController.text) ?? 0;
                      profile.monthlyTobacco    = double.tryParse(_tobaccoController.text) ?? 0;
                      profile.monthlyClothes    = double.tryParse(_clothesController.text) ?? 0;
                      profile.monthlySoap       = double.tryParse(_soapController.text) ?? 0;
                      profile.monthlyMedicine   = double.tryParse(_medicineController.text) ?? 0;
                      profile.monthlyEducation  = double.tryParse(_educationController.text) ?? 0;
                      profile.monthlyHealthcare = double.tryParse(_healthcareController.text) ?? 0;
                      profile.monthlyCare       = double.tryParse(_careController.text) ?? 0;
                      profile.monthlyServices   = double.tryParse(_servicesController.text) ?? 0;
                      profile.yearlyElectronics = double.tryParse(_electronicsController.text) ?? 0;
                      profile.yearlyMachinery   = double.tryParse(_machineryController.text) ?? 0;
                      profile.yearlyFurniture   = double.tryParse(_furnitureController.text) ?? 0;
                      profile.update();
                      context.go('/results');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Next →',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────────

  Widget _sectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: kPrimary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: kText),
      ),
    );
  }

  Widget _spendField(String label, TextEditingController controller,
      String prefix, String suffix) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: kText, fontSize: 14)),
          SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              isDense: true,
              hintText: '0',
              prefix: Text('£ ', style: TextStyle(color: kText)),
              suffixText: suffix,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Results Screen ────────────────────────────────────────────────────────────
class ResultsScreen extends StatefulWidget {
  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _results;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Future<void> _calculate() async {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('https://netzero-production.up.railway.app/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toProfile()),
      );
      if (response.statusCode == 200) {
        setState(() {
          _results = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Could not connect to server. Is the backend running?';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: _loading
                ? Center(child: CircularProgressIndicator(color: kPrimary))
                : _error != null
                    ? _buildError()
                    : _buildResults(),
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: kTextSubtle, size: 48),
          SizedBox(height: 16),
          Text(_error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSubtle)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _calculate();
            },
            child: Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final total = _results!['total_kg_co2e'] as double;
    final breakdown = _results!['breakdown'] as Map<String, dynamic>;
    final treeAmount = _results!['trees'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        SizedBox(height: 16),
        Text(
          'Your Results',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        progressBar(1.0),
        SizedBox(height: 32),

        // Total
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimary),
          ),
          child: Column(
            children: [
              Text(
                'Your household\'s annual footprint',
                style: TextStyle(color: kText, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                '${(total / 1000).toStringAsFixed(1)} tonnes CO₂e',
                style: TextStyle(
                    fontSize: 36, fontWeight: FontWeight.bold, color: kText),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'This is equivalent to the CO2 stored in $treeAmount trees',
                style: TextStyle(fontSize: 12, color: kTextSubtle),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 24),

        // Breakdown
        Expanded(
          child: ListView(
            children: [
              Text(
                'Breakdown by category',
                style: TextStyle(fontWeight: FontWeight.bold, color: kText, fontSize: 16),
              ),
              SizedBox(height: 12),
              _categoryRow('🏠 Home Energy', breakdown['home']['total'], total),
              _categoryRow('🚗 Transport', breakdown['transport']['total'], total),
              _categoryRow('🛒 Consumption', 
                (breakdown['diet']['total'] as num) +
                (breakdown['waste']['total'] as num) +
                (breakdown['pets']['total'] as num) +
                (breakdown['spending']['total'] as num), total),
              SizedBox(height: 24),
            ],
          ),
        ),

        // Start again button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/welcome'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: StadiumBorder(),
            ),
            child: Text(
              'Start Again',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _categoryRow(String label, dynamic value, double total) {
    final kg = (value as num).toDouble();
    final percent = total > 0 ? (kg / total * 100) : 0.0;
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: kText, fontSize: 14)),
              Text(
                '${(kg / 1000).toStringAsFixed(2)}t  (${percent.toStringAsFixed(0)}%)',
                style: TextStyle(color: kTextSubtle, fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: kBorder,
              color: kPrimary,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}