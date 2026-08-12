import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'profile_store.dart';
import 'theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_globe_3d/flutter_globe_3d.dart';
import 'dart:math';

const bool kUnderConstruction = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
  observers: [Earth3D.routeObserver],
  redirect: (context, state) {
    final bypassKey = state.uri.queryParameters['preview'];
    final isDeveloper = bypassKey == 'letmein123';

    if (kUnderConstruction && !isDeveloper && state.matchedLocation != '/maintenance') {
      return '/maintenance';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/maintenance', builder: (context, state) => UnderConstructionScreen()), 
    GoRoute(path: '/auth', builder: (context, state) => AuthChoiceScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final redirectTo = state.uri.queryParameters['redirect'] ?? '/info';
        return LoginScreen(redirectTo: redirectTo);
      },
    ),    
    GoRoute(path: '/welcome',      builder: (context, state) => WelcomeScreen()),
    GoRoute(path: '/info',         builder: (context, state) => InfoScreen()),
    GoRoute(path: '/energy-intro', builder: (context, state) => EnergyIntroScreen()),
    GoRoute(path: '/num-people', builder: (context, state) => NumPeopleScreen()),
    GoRoute(path: '/solar', builder: (context, state) => SolarPanelsScreen()),
    GoRoute(path: '/solar-usage', builder: (context, state) => SolarUsageScreen()),
    GoRoute(path: '/heating-fuel', builder: (context, state) => HeatingFuelScreen()),
    GoRoute(path: '/hob-type', builder: (context, state) => HobTypeScreen()),
    GoRoute(path: '/combined-billing', builder: (context, state) => CombinedBillingScreen()),
    GoRoute(path: '/gas-elec-spend', builder: (context, state) => CombinedSpendScreen()),
    GoRoute(path: '/gas-spend', builder: (context, state) => GasSpendScreen()),
    GoRoute(path: '/elec-spend', builder: (context, state) => ElecSpendScreen()),
    GoRoute(path: '/water-spend', builder: (context, state) => WaterSpendScreen()),
    GoRoute(path: '/tariff-type', builder: (context, state) => TariffTypeScreen()),
    GoRoute(path: '/transport-intro', builder: (context, state) => TransportIntroScreen()),
    GoRoute(path: '/car-size', builder: (context, state) => CarSizeScreen()),
    GoRoute(path: '/car-fuel', builder: (context, state) => CarFuelScreen()),
    GoRoute(path: '/weekly-mileage', builder: (context, state) => WeeklyMileageScreen()),
    GoRoute(path: '/bus-spend', builder: (context, state) => BusSpendScreen()),
    GoRoute(path: '/train-spend', builder: (context, state) => TrainSpendScreen()),
    GoRoute(path: '/flights-intro', builder: (context, state) => FlightsIntroScreen()),
    GoRoute(path: '/flights-question', builder: (context, state) => FlightsGlobeScreen()),
    GoRoute(path: '/uk-intro', builder: (context, state) => UKIntroScreen()),
    GoRoute(path: '/hotel-nights', builder: (context, state) => HotelNightsScreen()),
    GoRoute(path: '/airbnb-nights', builder: (context, state) => AirbnbNightsScreen()),
    GoRoute(path: '/pets-intro', builder: (context, state) => PetsIntroScreen()),
    GoRoute(path: '/pets-question', builder: (context, state) => PetsQuestionScreen()),
    GoRoute(path: '/diet-intro', builder: (context, state) => DietIntroScreen()),
    GoRoute(path: '/weekly-shop', builder: (context, state) => WeeklyShopScreen()),
    GoRoute(path: '/rm-days', builder: (context, state) => RMDaysScreen()),
    GoRoute(path: '/wm-days', builder: (context, state) => WMDaysScreen()),
    GoRoute(path: '/waste', builder: (context, state) => WasteScreen()),
    GoRoute(path: '/food-waste', builder: (context, state) => FoodWasteScreen()),
    GoRoute(path: '/household',    builder: (context, state) => HouseholdScreen()),
    GoRoute(path: '/diet',         builder: (context, state) => DietScreen()),
    GoRoute(path: '/spending',     builder: (context, state) => SpendingScreen()),
    GoRoute(path: '/results',      builder: (context, state) => ResultsScreen()),
    GoRoute(path: '/login-reminder', builder: (context, state) => LoginReminderScreen()),
    GoRoute(path: '/phase2',       builder: (context, state) => Phase2Screen()),
    GoRoute(path: '/quiz',         builder: (context, state) => QuizScreen()),
    GoRoute(path: '/energyaction', builder: (context, state) => EnergyActionScreen()),
    GoRoute(path: '/homeinfo',     builder: (context, state) => HomeInfoScreen()),
    GoRoute(path: '/insulation',   builder: (context, state) => InsulationScreen()),
    GoRoute(path: '/habit',        builder: (context, state) => HabitScreen()),
    GoRoute(path: '/homeowner',    builder: (context, state) => HomeownerScreen()),
    GoRoute(path: '/phase3',       builder: (context, state) => Phase3Screen()),
    GoRoute(path: '/actions',      builder: (context, state) => ActionScreen()),
  ],
);

// ── Icons ─────────────────────────────────────────────────
// --- Ligtning Bolt -----------------------------------------


// ── App ─────────────────────────────────────────────────
class NetZeroApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Net Zero Planner',
      routerConfig: _router,
      theme: buildTheme(),
      builder: (context, child) {
        return Container(
          color: kBackground,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 480),
              child: child,
            ),
          ),
        );
      },
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

// ── Login/Logout Bar ───────────────────────────
Widget _authBarButton(BuildContext context, {Color accentColor = kPrimary}) {
  final user = FirebaseAuth.instance.currentUser;
  final isLoggedIn = user != null && !user.isAnonymous;

  if (isLoggedIn) {
    return TextButton(
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
        if (context.mounted) context.go('/auth');
      },
      child: Text('Log out', style: TextStyle(color: kTextSubtle)),
    );
  } else {
    return TextButton(
      onPressed: () => context.go('/login'),
      child: Text('Log in', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
    );
  }
}

// ── Country Co-ordinates ───────────────────────────
const Map<String, List<double>> countryCoordinates = {
  'Afghanistan': [33.0, 66.0],
  'Albania': [41.0, 20.0],
  'Algeria': [28.0, 3.0],
  'American Samoa': [-14.270972, -170.132217],
  'Angola': [-12.5, 18.5],
  'Anguilla': [18.220554, -63.068615],
  'Antigua and Barbuda': [17.05, -61.8],
  'Argentina': [-34.0, -64.0],
  'Armenia': [40.0, 45.0],
  'Aruba': [12.52111, -69.968338],
  'Ascension Island': [-7.9467, -14.3559],
  'Australia': [-25.0, 135.0],
  'Austria': [47.333333, 13.333333],
  'Azerbaijan': [40.5, 47.5],
  'Bahamas': [24.0, -76.0],
  'Bahrain': [26.0, 50.5],
  'Bangladesh': [24.0, 90.0],
  'Barbados': [13.166667, -59.533333],
  'Belarus': [53.0, 28.0],
  'Belgium': [50.833333, 4.0],
  'Belize': [17.25, -88.75],
  'Benin': [9.5, 2.25],
  'Bermuda': [32.321384, -64.75737],
  'Bolivia': [-17.0, -65.0],
  'Bosnia-Herzegovina': [44.25, 17.833333],
  'Botswana': [-22.0, 24.0],
  'Brazil': [-10.0, -55.0],
  'British Virgin Islands': [18.4207, -64.64],
  'Brunei': [4.5, 114.666667],
  'Bulgaria': [43.0, 25.0],
  'Burkina Faso': [13.0, -2.0],
  'Burundi': [-3.5, 30.0],
  'Cambodia': [13.0, 105.0],
  'Cameroon': [6.0, 12.0],
  'Canada': [60.0, -96.0],
  'Cape Verde': [16.0, -24.0],
  'Cayman Islands': [19.513469, -80.566956],
  'Central African Republic': [7.0, 21.0],
  'Chad': [15.0, 19.0],
  'Chile': [-30.0, -71.0],
  'China': [35.0, 105.0],
  'Colombia': [4.0, -72.0],
  'Comoros': [-12.166667, 44.25],
  'Congo-Brazzaville': [-1.0, 15.0],
  'Cook Islands': [-21.236736, -159.777671],
  'Costa Rica': [10.0, -84.0],
  'Croatia': [45.166667, 15.5],
  'Cuba': [22.0, -79.5],
  'Curacao': [12.1696, -68.99],
  'Cyprus': [35.0, 33.0],
  'Czech Republic': [49.75, 15.0],
  'Denmark': [56.0, 10.0],
  'Djibouti': [11.5, 42.5],
  'Dominica': [15.5, -61.333333],
  'Dominican Republic': [19.0, -70.666667],
  'DR Congo': [0.0, 25.0],
  'Ecuador': [-2.0, -77.5],
  'Egypt': [27.0, 30.0],
  'El Salvador': [13.833333, -88.916667],
  'Equatorial Guinea': [2.0, 10.0],
  'Eritrea': [15.0, 39.0],
  'Estonia': [59.0, 26.0],
  'Ethiopia': [8.0, 38.0],
  'Falkland Islands': [-51.796253, -59.523613],
  'Faroe Islands': [61.892635, -6.911806],
  'Fiji': [-18.0, 178.0],
  'Finland': [64.0, 26.0],
  'France': [46.0, 2.0],
  'French Guiana': [3.933889, -53.125782],
  'Gabon': [-1.0, 11.75],
  'Gambia': [13.5, -15.5],
  'Georgia': [41.999981, 43.499905],
  'Germany': [51.5, 10.5],
  'Ghana': [8.0, -2.0],
  'Gibraltar': [36.137741, -5.345374],
  'Greece': [39.0, 22.0],
  'Greenland': [71.706936, -42.604303],
  'Grenada': [12.116667, -61.666667],
  'Guadeloupe': [16.995971, -62.067641],
  'Guam': [13.444304, 144.793731],
  'Guatemala': [15.5, -90.25],
  'Guernsey': [49.465691, -2.585278],
  'Guinea': [11.0, -10.0],
  'Guinea-Bissau': [12.0, -15.0],
  'Guyana': [5.0, -59.0],
  'Haiti': [19.0, -72.416667],
  'Honduras': [15.0, -86.5],
  'Hong Kong': [22.396428, 114.109497],
  'Hungary': [47.0, 20.0],
  'Iceland': [65.0, -18.0],
  'India': [20.0, 77.0],
  'Indonesia': [-5.0, 120.0],
  'Iran': [32.0, 53.0],
  'Iraq': [33.0, 44.0],
  'Ireland': [53.0, -8.0],
  'Isle Of Man': [54.236107, -4.548056],
  'Israel': [31.5, 34.75],
  'Italy': [42.833333, 12.833333],
  'Ivory Coast': [8.0, -5.0],
  'Jamaica': [18.25, -77.5],
  'Japan': [36.0, 138.0],
  'Jersey': [49.214439, -2.13125],
  'Jordan': [31.0, 36.0],
  'Kazakhstan': [48.0, 68.0],
  'Kenya': [1.0, 38.0],
  'Kosovo': [42.6026, 20.903],
  'Kuwait': [29.5, 47.75],
  'Kyrgyzstan': [41.0, 75.0],
  'Laos': [18.0, 105.0],
  'Latvia': [57.0, 25.0],
  'Lebanon': [33.833333, 35.833333],
  'Lesotho': [-29.5, 28.25],
  'Liberia': [6.5, -9.5],
  'Libya': [25.0, 17.0],
  'Lithuania': [56.0, 24.0],
  'Luxembourg': [49.75, 6.166667],
  'Macao': [22.1987, 113.5439],
  'Macedonia': [41.833333, 22.0],
  'Madagascar': [-20.0, 47.0],
  'Malawi': [-13.5, 34.0],
  'Malaysia': [2.5, 112.5],
  'Maldives': [3.2, 73.0],
  'Mali': [17.0, -4.0],
  'Malta': [35.916667, 14.433333],
  'Marshall Islands': [10.0, 167.0],
  'Martinique': [14.6415, -61.0242],
  'Mauritania': [20.0, -12.0],
  'Mauritius': [-20.3, 57.583333],
  'Mexico': [23.0, -102.0],
  'Moldova': [47.0, 29.0],
  'Mongolia': [46.0, 105.0],
  'Montenegro': [42.5, 19.3],
  'Morocco': [32.0, -5.0],
  'Mozambique': [-18.25, 35.0],
  'Myanmar': [22.0, 98.0],
  'Namibia': [-22.0, 17.0],
  'Nepal': [28.0, 84.0],
  'Netherlands': [52.5, 5.75],
  'New Caledonia': [-20.9043, 165.618],
  'New Zealand': [-42.0, 174.0],
  'Nicaragua': [13.0, -85.0],
  'Niger': [16.0, 8.0],
  'Nigeria': [10.0, 8.0],
  'North Korea': [40.0, 127.0],
  'Norway': [62.0, 10.0],
  'Oman': [21.0, 57.0],
  'Pakistan': [30.0, 70.0],
  'Palau': [6.0, 134.0],
  'Panama': [9.0, -80.0],
  'Papua New Guinea': [-6.0, 147.0],
  'Paraguay': [-22.993333, -57.996389],
  'Peru': [-10.0, -76.0],
  'Philippines': [13.0, 122.0],
  'Poland': [52.0, 20.0],
  'Portugal': [39.5, -8.0],
  'Puerto Rico': [18.2208, -66.5901],
  'Qatar': [25.5, 51.25],
  'Reunion': [-21.1151, 55.5364],
  'Romania': [46.0, 25.0],
  'Russia': [60.0, 100.0],
  'Rwanda': [-2.0, 30.0],
  'Sao Tome Islands': [1.0, 7.0],
  'Saudi Arabia': [25.0, 45.0],
  'Senegal': [14.0, -14.0],
  'Serbia': [44.0, 21.0],
  'Seychelles': [-4.583333, 55.666667],
  'Sierra Leone': [8.5, -11.5],
  'Singapore': [1.366667, 103.8],
  'Slovak Republic': [48.666667, 19.5],
  'Slovenia': [46.25, 15.166667],
  'Solomon Islands': [-8.0, 159.0],
  'Somali Republic': [6.0, 48.0],
  'South Africa': [-30.0, 26.0],
  'South Korea': [37.0, 127.5],
  'South Sudan': [8.0, 30.0],
  'Spain': [40.0, -4.0],
  'Sri Lanka': [7.0, 81.0],
  'St Kitts and Nevis': [17.333333, -62.75],
  'St Lucia': [13.883333, -60.966667],
  'St Vincent and the Grenadines': [13.083333, -61.2],
  'Sudan': [16.0, 30.0],
  'Surinam': [4.0, -56.0],
  'Swaziland': [-26.5, 31.5],
  'Sweden': [62.0, 15.0],
  'Switzerland': [47.0, 8.0],
  'Syria': [35.0, 38.0],
  'Tahiti': [-17.6797, -149.4068],
  'Taiwan': [23.6978, 120.9605],
  'Tajikistan': [39.0, 71.0],
  'Tanzania': [-6.0, 35.0],
  'Thailand': [15.0, 100.0],
  'Timor': [-8.833333, 125.75],
  'Togo': [8.0, 1.166667],
  'Tonga': [-20.0, -175.0],
  'Trinidad and Tobago': [11.0, -61.0],
  'Tunisia': [34.0, 9.0],
  'Turkey': [39.059012, 34.911546],
  'Turkmenistan': [40.0, 60.0],
  'Turks and Caicos Islands': [21.694, -71.7979],
  'Uganda': [2.0, 33.0],
  'Ukraine': [49.0, 32.0],
  'United Arab Emirates': [24.0, 54.0],
  'United Kingdom': [54.0, -4.0],
  'United States': [39.828175, -98.5795],
  'Uruguay': [-33.0, -56.0],
  'Uzbekistan': [41.707542, 63.84911],
  'Vanuatu': [-16.0, 167.0],
  'Venezuela': [8.0, -66.0],
  'Vietnam': [16.166667, 107.833333],
  'Virgin Islands (U.S.A)': [18.3358, -64.8963],
  'Wake Islands': [19.2823, 166.6470],
  'Western Sahara': [24.215527, -12.885834],
  'Yemen': [15.5, 47.5],
  'Zambia': [-15.0, 30.0],
  'Zimbabwe': [-19.0, 29.0],
};

// ── Distance Calculation ───────────────────────────
double _distanceBetween(double lat1, double lon1, double lat2, double lon2) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(lat2 - lat1);
  final dLon = _degToRad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadiusKm * c;
}

double _degToRad(double deg) => deg * (pi / 180);

List<String> findNearbyCountries(double tapLat, double tapLon, {double radiusKm = 3000}) {
  final nearby = <String>[];
  countryCoordinates.forEach((country, coords) {
    final distance = _distanceBetween(tapLat, tapLon, coords[0], coords[1]);
    if (distance <= radiusKm) {
      nearby.add(country);
    }
  });
  nearby.sort();
  return nearby;
}

// ── Anchor Markers ───────────────────────────
const List<Map<String, dynamic>> globeRegions = [
  {'id': 'w_europe', 'lat': 48.0, 'lon': 5.0},
  {'id': 'e_europe', 'lat': 50.0, 'lon': 25.0},
  {'id': 'n_africa', 'lat': 25.0, 'lon': 15.0},
  {'id': 'w_africa', 'lat': 10.0, 'lon': -5.0},
  {'id': 'e_africa', 'lat': -2.0, 'lon': 35.0},
  {'id': 's_africa', 'lat': -25.0, 'lon': 25.0},
  {'id': 'middle_east', 'lat': 27.0, 'lon': 45.0},
  {'id': 'central_asia', 'lat': 42.0, 'lon': 65.0},
  {'id': 's_asia', 'lat': 22.0, 'lon': 80.0},
  {'id': 'se_asia', 'lat': 10.0, 'lon': 105.0},
  {'id': 'e_asia', 'lat': 35.0, 'lon': 105.0},
  {'id': 'n_america', 'lat': 45.0, 'lon': -100.0},
  {'id': 'central_america', 'lat': 15.0, 'lon': -85.0},
  {'id': 'caribbean', 'lat': 18.0, 'lon': -65.0},
  {'id': 'n_south_america', 'lat': 5.0, 'lon': -65.0},
  {'id': 's_south_america', 'lat': -30.0, 'lon': -65.0},
  {'id': 'oceania', 'lat': -25.0, 'lon': 140.0},
  {'id': 'pacific_islands', 'lat': -15.0, 'lon': -175.0},
];

// ── Standardised Questions ───────────────────────────
// ── Yes/No ───────────────────────────
Widget buildYesNoOptions({
  required bool? selected,
  required void Function(bool) onSelect,
  String leftLabel = 'Yes',
  IconData leftIcon = Icons.check_circle_outline,
  String? leftSubtitle,
  String rightLabel = 'No',
  IconData rightIcon = Icons.cancel_outlined,
  String? rightSubtitle,
}) {
  final hasSubtitles = leftSubtitle != null || rightSubtitle != null;
  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => onSelect(true),
          child: Container(
            constraints: BoxConstraints(minHeight: hasSubtitles ? 170 : 120),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected == true ? kPrimary.withOpacity(0.15) : kSurface,
              border: Border.all(
                color: selected == true ? kPrimary : kBorder,
                width: selected == true ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(leftIcon, color: kPrimary, size: 32),
                SizedBox(height: 8),
                Text(leftLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText), textAlign: TextAlign.center),
                if (leftSubtitle != null) ...[
                  SizedBox(height: 8),
                  Text(leftSubtitle, style: TextStyle(fontSize: 12, color: kTextSubtle), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: GestureDetector(
          onTap: () => onSelect(false),
          child: Container(
            constraints: BoxConstraints(minHeight: hasSubtitles ? 170 : 120),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selected == false ? kPrimary.withOpacity(0.15) : kSurface,
              border: Border.all(
                color: selected == false ? kPrimary : kBorder,
                width: selected == false ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rightIcon, color: kTextSubtle, size: 32),
                SizedBox(height: 8),
                Text(rightLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText), textAlign: TextAlign.center),
                if (rightSubtitle != null) ...[
                  SizedBox(height: 8),
                  Text(rightSubtitle, style: TextStyle(fontSize: 12, color: kTextSubtle), textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// ── Single Select List ───────────────────────────
Widget buildSingleSelectOptions({
  required List<Map<String, dynamic>> options,
  required String? selected,
  required void Function(String) onSelect,
  Color accentColor = kPrimary,
}) {
  return Column(
    children: options.map((opt) {
      final isSelected = selected == opt['value'];
      return Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: GestureDetector(
          onTap: () => onSelect(opt['value'] as String),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? accentColor.withOpacity(0.1) : kSurface,
              border: Border.all(color: isSelected ? accentColor : kBorder, width: isSelected ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (opt['icon'] != null) ...[
                  Icon(opt['icon'] as IconData, color: accentColor),
                  SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(opt['label'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText)),
                      if (opt['subtitle'] != null) ...[
                        SizedBox(height: 2),
                        Text(opt['subtitle'] as String, style: TextStyle(fontSize: 12, color: kTextSubtle)),
                      ],
                    ],
                  ),
                ),
                if (isSelected) Icon(Icons.check_circle, color: accentColor),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ── Two Options ───────────────────────────
Widget buildTwoOptionBoxes({
  required String? selected,
  required void Function(String) onSelect,
  required String leftValue,
  required String leftLabel,
  required IconData leftIcon,
  required String rightValue,
  required String rightLabel,
  required IconData rightIcon,
}) {
  return Row(
    children: [
      Expanded(
        child: GestureDetector(
          onTap: () => onSelect(leftValue),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: selected == leftValue ? kPrimary.withOpacity(0.15) : kSurface,
              border: Border.all(
                color: selected == leftValue ? kPrimary : kBorder,
                width: selected == leftValue ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(leftIcon, color: kPrimary, size: 32),
                SizedBox(height: 8),
                Text(leftLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: GestureDetector(
          onTap: () => onSelect(rightValue),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: selected == rightValue ? kPrimary.withOpacity(0.15) : kSurface,
              border: Border.all(
                color: selected == rightValue ? kPrimary : kBorder,
                width: selected == rightValue ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(rightIcon, color: kPrimary, size: 32),
                SizedBox(height: 8),
                Text(rightLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

// ── Reusable Quiz Frame ──────────────────────────────────────────────────
class QuizFrame extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final String question;
  final String? subheading;
  final Widget answerContent;
  final bool answered;
  final VoidCallback onNext;
  final String backRoute;
  final String? motivationalMessage;
  final Color accentColor;

  const QuizFrame({
    required this.progress,
    required this.question,
    this.subheading,
    required this.answerContent,
    required this.answered,
    required this.onNext,
    required this.backRoute,
    this.motivationalMessage,
    this.accentColor = kPrimary,
  });

  @override
  _QuizFrameState createState() => _QuizFrameState();
}

class _QuizFrameState extends State<QuizFrame> {
  double? _currentCo2;

  @override
  void initState() {
    super.initState();
    _fetchLiveTotal();
  }

  Future<void> _fetchLiveTotal() async {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('https://netzero-production.up.railway.app/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toProfile()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Full breakdown: ${data['breakdown']}');
        setState(() => _currentCo2 = (data['total_kg_co2e'] as num).toDouble());
      }
    } catch (e) {
      // Silently fail - the live counter just won't update this time
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go(widget.backRoute),
        ),
        actions: [
          _authBarButton(context, accentColor: widget.accentColor),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/leaf_icon.png', height: 32),
                    Row(
                      children: [
                        Icon(Icons.eco, color: kPrimary, size: 20),
                        SizedBox(width: 4),
                        Text(
                          _currentCo2 != null ? '${_currentCo2!.toStringAsFixed(0)} kgCO₂' : '...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: widget.progress,
                    minHeight: 8,
                    backgroundColor: kBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
                  ),
                ),
                SizedBox(height: 32),
                Text(
                  widget.question,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                if (widget.subheading != null) ...[
                  SizedBox(height: 8),
                  Text(
                    widget.subheading!,
                    style: TextStyle(fontSize: 14, color: kTextSubtle, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
                Spacer(flex: 2),
                widget.answerContent,
                if (widget.motivationalMessage != null) ...[
                  SizedBox(height: 32),
                  Text(
                    widget.motivationalMessage!,
                    style: TextStyle(fontSize: 14, color: kTextSubtle, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
                Spacer(flex: 3),
                if (widget.answered)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: Text('Next →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                else
                  SizedBox(height: 54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hover Reveal ───────────────────────────
class HoverRevealField extends StatefulWidget {
  final String displayValue;
  final Widget Function(BuildContext context) editorBuilder;

  const HoverRevealField({required this.displayValue, required this.editorBuilder});

  @override
  _HoverRevealFieldState createState() => _HoverRevealFieldState();
}

class _HoverRevealFieldState extends State<HoverRevealField> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _open = true),
      child: _open
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: kPetsPurple),
                borderRadius: BorderRadius.circular(6),
              ),
              child: widget.editorBuilder(context),
            )
          : MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  widget.displayValue.isEmpty ? '—' : widget.displayValue,
                  style: TextStyle(color: kText),
                ),
              ),
            ),
    );
  }
}

const Color kLavender = Color(0xFFF3EAFB);
// ── Pet Card ───────────────────────────
class PetCard extends StatefulWidget {
  final Map<String, dynamic> pet;
  final void Function(Map<String, dynamic>) onChanged;
  final VoidCallback onRemove;

  const PetCard({required this.pet, required this.onChanged, required this.onRemove});

  @override
  _PetCardState createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet['name'] ?? '');
    _weightController = TextEditingController(text: widget.pet['weight']?.toString() ?? '');
  }

  void _update(String key, dynamic value) {
    final updated = Map<String, dynamic>.from(widget.pet);
    updated[key] = value;
    widget.onChanged(updated);
  }

  Widget _row(String label, Widget field) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 70, child: Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, color: kText))),
          Expanded(child: field),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kLavender,
        border: Border.all(color: kPetsPurple, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(pet['type'] == 'dog' ? Icons.pets : Icons.pets, color: kPetsPurple),
              SizedBox(width: 8),
              Text(pet['type'] == 'dog' ? 'Dog' : 'Cat', style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.close, color: kTextSubtle, size: 20),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          Divider(color: kBorder),
          _row(
            'Name',
            HoverRevealField(
              displayValue: pet['name'] ?? '',
              editorBuilder: (context) => TextField(
                controller: _nameController,
                style: TextStyle(color: kText),
                decoration: InputDecoration(border: InputBorder.none, isDense: true),
                onChanged: (value) => _update('name', value),
              ),
            ),
          ),
          _row(
            'Food Type',
            HoverRevealField(
              displayValue: pet['food'] ?? '',
              editorBuilder: (context) => DropdownButton<String>(
                value: pet['food'],
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select'),
                items: ['dry', 'wet'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (value) => _update('food', value),
              ),
            ),
          ),
          _row(
            'Brand',
            HoverRevealField(
              displayValue: pet['brand'] ?? '',
              editorBuilder: (context) => DropdownButton<String>(
                value: pet['brand'],
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select'),
                items: ['standard', 'premium'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (value) => _update('brand', value),
              ),
            ),
          ),
          _row(
            'Diet',
            HoverRevealField(
              displayValue: pet['diet'] ?? '',
              editorBuilder: (context) => DropdownButton<String>(
                value: pet['diet'],
                isExpanded: true,
                underline: SizedBox(),
                hint: Text('Select'),
                items: ['meaty', 'vegetarian'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (value) => _update('diet', value),
              ),
            ),
          ),
          _row(
            'Daily Weight Of Food',
            HoverRevealField(
              displayValue: pet['weight'] != null ? '${pet['weight']} kg' : '',
              editorBuilder: (context) => TextField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: kText),
                decoration: InputDecoration(border: InputBorder.none, isDense: true),
                onChanged: (value) => _update('weight', double.tryParse(value) ?? 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Under Construction Screen ─────────────────────────────────────────────
class UnderConstructionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/leaf_icon.png', height: 64),
                SizedBox(height: 24),
                Text(
                  'We\'ll be right back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'My Net Zero Planner is currently getting a fresh coat of paint. Please check back soon!',
                  style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
                Image.asset(
                  'assets/images/leaf_icon.png',
                  height: 64,
                ),
                SizedBox(height: 32),

                // Title
                Text(
                  'My Net Zero\nPlanner',
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
                    onPressed: () => context.go('/auth'),
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
              ],
            ),
          ),
        ),   // ← closes screenWrapper
      ),     // ← closes SafeArea
    );       // ← closes Scaffold
  }
}

// ── Auth Choice Screen ──────────────────────────────────────────────────────
class AuthChoiceScreen extends StatefulWidget {
  @override
  _AuthChoiceScreenState createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final profile = Provider.of<ProfileStore>(context, listen: false);
      await profile.loadFromFirestore();
      if (mounted) context.go('/info');
      return;
    }
    setState(() => _checking = false);
  }

  Future<void> _continueAsGuest() async {
    await FirebaseAuth.instance.signInAnonymously();
    context.go('/info');
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/leaf_icon.png', height: 64),
                SizedBox(height: 32),
                Text(
                  'My Net Zero Planner',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text('Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _continueAsGuest,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Continue without logging in',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextSubtle),
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

// ── Login Screen ────────────────────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  final String redirectTo;
  const LoginScreen({this.redirectTo = '/info'});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;


  Future<void> _submitEmailPassword() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      UserCredential credential;

      if (_isSignUp) {
        if (currentUser != null && currentUser.isAnonymous) {
          final authCredential = EmailAuthProvider.credential(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
          credential = await currentUser.linkWithCredential(authCredential);
        } else {
          credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
        }
      } else {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      if (credential.user != null) {
        final profile = Provider.of<ProfileStore>(context, listen: false);
        await profile.loadFromFirestore();
        if (mounted) context.go(widget.redirectTo);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        setState(() => _error = 'Incorrect email or password. If you\'re new here, try creating an account instead.');
      } else {
        setState(() => _error = e.message ?? 'Something went wrong. Please try again.');
      }
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      final currentUser = FirebaseAuth.instance.currentUser;
      UserCredential credential;

      if (currentUser != null && currentUser.isAnonymous) {
        credential = await currentUser.linkWithPopup(authProvider);
      } else {
        credential = await FirebaseAuth.instance.signInWithPopup(authProvider);
      }

      if (credential.user != null) {
        final profile = Provider.of<ProfileStore>(context, listen: false);
        await profile.loadFromFirestore();
        if (mounted) context.go(widget.redirectTo);
      }
    } catch (e) {
      print('Google sign-in error: $e');
      setState(() => _error = 'Could not sign in with Google. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/auth'),
        ),
      ),
      body: SafeArea(
        child: screenWrapper(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    _isSignUp ? 'Create an account' : 'Log in',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  Text('Email', style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'you@example.com'),
                  ),
                  SizedBox(height: 24),

                  Text('Password', style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: 'At least 6 characters'),
                  ),
                  SizedBox(height: 24),

                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: Colors.red, fontSize: 13), textAlign: TextAlign.center),
                    SizedBox(height: 16),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submitEmailPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: _loading
                          ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_isSignUp ? 'Sign Up' : 'Log In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  SizedBox(height: 12),

                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Already have an account? Log in' : 'New here? Create an account',
                      style: TextStyle(color: kTextSubtle),
                    ),
                  ),
                  SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(child: Divider(color: kBorder)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: kTextSubtle)),
                      ),
                      Expanded(child: Divider(color: kBorder)),
                    ],
                  ),
                  SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _signInWithGoogle,
                      icon: Icon(Icons.g_mobiledata, size: 28),
                      label: Text('Continue with Google'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        side: BorderSide(color: kBorder),
                        shape: StadiumBorder(),
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

// ── Info Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
class InfoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/welcome'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea( //wraps content to avoid physical device intrusion (e.g camera thing)
        child: SingleChildScrollView(
          child: screenWrapper( // applies visual stying and layout from what I have defined already
            child: Padding( // applies padding round the outside so its not all cramped up on the sides
              padding: EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 60,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Center(
                          child: Text(
                            'About This App',
                            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Image.asset(
                            'assets/images/leaf_icon.png',
                            height: 49,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'My Net Zero Planner helps you to understand where your carbon emissions are coming from and how to reduce them.',
                    style: TextStyle(fontSize: 18, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'The app has three phases:',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 15),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'Phase 1:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' Carbon dioxide emissions calculation'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is to give you an understanding about where your emissions are coming from, and the areas that need the most improvements.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'You will need previous energy bill information, so have this to hand before you start.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Try to be as careful as possible as this helps us to give you accurate results and recommendations!',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'Phase 2:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' About you'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is a quiz designed to understand your habits, house characteristics, and any carbon reduction actions you have already taken to tailor reduction actions to your lifestyle.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'It is very short and should only take 2-3 minutes.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                      children: [
                        TextSpan(
                          text: 'Phase 3:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: 'Reduction Actions'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This is where you can see steps you can take to reduce your household emissions.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'There are three tiers: free, cheap and expensive. Within these tiers actions are given to you in order of highest impact.',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Don\'t worry, as if you don\'t like an action you can always skip or remove it!',
                    style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                      children: [
                        TextSpan(text: 'Climate action '),
                        TextSpan(
                          text: 'shouldn\'t force you',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' to give up habits, activities or things you love. It should be integrated seamlessly into everyone\'s lives.'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                      children: [
                        TextSpan(text: 'My Net Zero Planner aims to do just that by giving you '),
                        TextSpan(
                          text: 'easy, impactful',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: ' actions to help make the world a better place for everyone!'),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  // Start button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/energy-intro'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Let\'s go! →',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Energy Section Intro ────────────────────────────────────────────────
class EnergyIntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/info'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.6,
                  child: Image.asset(
                    'assets/images/bolt_icon.png',
                    height: 110,
                    color: kPrimary,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Energy',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About your home\'s energy use',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/num-people'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Number of People Question ─────────────────────────────────────────────
class NumPeopleScreen extends StatefulWidget {
  @override
  _NumPeopleScreenState createState() => _NumPeopleScreenState();
}

class _NumPeopleScreenState extends State<NumPeopleScreen> {
  int? _numPeople;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _numPeople = profile.numPeople;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.01,
      question: 'How many people live in your household?',
      answered: _numPeople != null,
      backRoute: '/energy-intro',
      onNext: () {
        profile.numPeople = _numPeople;
        profile.update();
        context.go('/solar');
      },
      answerContent: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (_numPeople != null && _numPeople! > 1) {
                setState(() => _numPeople = _numPeople! - 1);
              }
            },
            icon: Icon(Icons.remove_circle_outline, color: kPrimary, size: 36),
          ),
          SizedBox(width: 24),
          Text(
            _numPeople?.toString() ?? '–',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kText),
          ),
          SizedBox(width: 24),
          IconButton(
            onPressed: () {
              setState(() => _numPeople = (_numPeople ?? 0) + 1);
            },
            icon: Icon(Icons.add_circle_outline, color: kPrimary, size: 36),
          ),
        ],
      ),
    );
  }
}

// ── Solar Panels Question ─────────────────────────────────────────────────
class SolarPanelsScreen extends StatefulWidget {
  @override
  _SolarPanelsScreenState createState() => _SolarPanelsScreenState();
}

class _SolarPanelsScreenState extends State<SolarPanelsScreen> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.solarPanelsAnswered ? profile.solarPanels : null; 
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.02,
      question: 'Do you have solar panels?',
      answered: _selected != null,
      backRoute: '/num-people',
      onNext: () {
        profile.solarPanels = _selected!;
        profile.solarPanelsAnswered = true;
        profile.update();
        if (_selected == true) {
          context.go('/solar-usage');
        } else {
          context.go('/heating-fuel');
        }
      },
      answerContent: buildYesNoOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
      ),
    );
  }
}

// ── Solar Usage Question ────────────────────────────────────────────────
class SolarUsageScreen extends StatefulWidget {
  @override
  _SolarUsageScreenState createState() => _SolarUsageScreenState();
}

class _SolarUsageScreenState extends State<SolarUsageScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlySolarKwh > 0) {
      _controller.text = profile.monthlySolarKwh.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.04,
      question: 'How much electricity did you use last month from your solar panels?',
      answered: _hasValue,
      backRoute: '/solar',
      onNext: () {
        profile.monthlySolarKwh = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/heating-fuel');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '100',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'kWh',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Energy you use NOT energy you export.',
            style: TextStyle(color: kTextSubtle, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Heating Fuel Question ───────────────────────────────────────────────
class HeatingFuelScreen extends StatefulWidget {
  @override
  _HeatingFuelScreenState createState() => _HeatingFuelScreenState();
}

class _HeatingFuelScreenState extends State<HeatingFuelScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.fuelTypeAnswered ? profile.fuelType : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.06,
      question: 'What type of heating fuel do you use?',
      answered: _selected != null,
      backRoute: profile.solarPanels ? '/solar-usage' : '/solar',
      onNext: () {
        profile.fuelType = _selected!;
        profile.fuelTypeAnswered = true;
        profile.update();
        context.go('/hob-type');
      },
      answerContent: buildSingleSelectOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        options: [
          {
            'value': 'natural_gas',
            'label': 'Mains Gas Heating',
            'subtitle': 'Connected to the gas grid',
            'icon': Icons.local_fire_department,
          },
          {
            'value': 'lpg',
            'label': 'Bottled/Tank Gas (LPG)',
            'subtitle': 'Common in rural areas not on the gas mains',
            'icon': Icons.propane_tank,
          },
          {
            'value': 'heat_pump',
            'label': 'No gas, just a heat pump',
            'icon': Icons.heat_pump,
          },
        ],
      ),
    );
  }
}

// ── Hob Type Question ───────────────────────────────────────────────────
class HobTypeScreen extends StatefulWidget {
  @override
  _HobTypeScreenState createState() => _HobTypeScreenState();
}

class _HobTypeScreenState extends State<HobTypeScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.hobTypeAnswered ? profile.hobType : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.08,
      question: 'What type of hob do you cook with?',
      answered: _selected != null, //for answered to be true, selected has to not equal null. It depends on selected
      backRoute: '/heating-fuel',
      onNext: () {
        profile.hobType = _selected!;
        profile.hobTypeAnswered = true;
        profile.update();
        context.go('/combined-billing');
      },
      answerContent: buildTwoOptionBoxes(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        leftValue: 'gas',
        leftLabel: 'Gas',
        leftIcon: Icons.local_fire_department,
        rightValue: 'electric',
        rightLabel: 'Electric',
        rightIcon: Icons.electric_bolt,
      ),
    );
  }
}

// ── Combined Billing Question ─────────────────────────────────────────────────
class CombinedBillingScreen extends StatefulWidget {
  @override
  _CombinedBillingScreenState createState() => _CombinedBillingScreenState();
}

class _CombinedBillingScreenState extends State<CombinedBillingScreen> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.combinedBilling;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.1,
      question: 'Do you get one combined bill for gas and electricity, or separate bills?',
      answered: _selected != null,
      backRoute: '/hob-type',
      onNext: () {
        profile.combinedBilling = _selected!;
        profile.update();
        if (_selected == true) {
          context.go('/gas-elec-spend');
        } else {
          context.go('/gas-spend');
        }
      },
      answerContent: buildYesNoOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        leftLabel: 'One combined bill',
        leftIcon: Icons.receipt_long,
        rightLabel: 'Separate bills',
        rightIcon: Icons.receipt,
      ),
    );
  }
}

// ── Combined Spend Question ────────────────────────────────────────────────
class CombinedSpendScreen extends StatefulWidget {
  @override
  _CombinedSpendScreenState createState() => _CombinedSpendScreenState();
}

class _CombinedSpendScreenState extends State<CombinedSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyCombinedSpend > 0) {
      _controller.text = profile.monthlyCombinedSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.12,
      question: 'What did you spend last month on your combined gas & electricity bill?',
      answered: _hasValue,
      backRoute: '/combined-billing',
      onNext: () {
        profile.monthlyCombinedSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/water-spend');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '150',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gas Spend Question ────────────────────────────────────────────────
class GasSpendScreen extends StatefulWidget {
  @override
  _GasSpendScreenState createState() => _GasSpendScreenState();
}

class _GasSpendScreenState extends State<GasSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyGasSpend > 0) {
      _controller.text = profile.monthlyGasSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.12,
      question: 'What did you spend last month on your gas bill?',
      answered: _hasValue,
      backRoute: '/combined-billing',
      onNext: () {
        profile.monthlyGasSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/elec-spend');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '70',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Electricity Spend Question ────────────────────────────────────────────────
class ElecSpendScreen extends StatefulWidget {
  @override
  _ElecSpendScreenState createState() => _ElecSpendScreenState();
}

class _ElecSpendScreenState extends State<ElecSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyElecSpend > 0) {
      _controller.text = profile.monthlyElecSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.13,
      question: 'What did you spend last month on your electricity bill?',
      answered: _hasValue,
      backRoute: '/gas-spend',
      onNext: () {
        profile.monthlyElecSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/water-spend');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '75',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Water Spend Question ────────────────────────────────────────────────
class WaterSpendScreen extends StatefulWidget {
  @override
  _WaterSpendScreenState createState() => _WaterSpendScreenState();
}

class _WaterSpendScreenState extends State<WaterSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyWaterSpend > 0) {
      _controller.text = profile.monthlyWaterSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.14,
      question: 'What did you spend last month on your water bill?',
      answered: _hasValue,
      backRoute: profile.combinedBilling == true ? '/gas-elec-spend' : '/elec-spend',
      onNext: () {
        profile.monthlyWaterSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/tariff-type');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '30',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tariff Type Question ────────────────────────────────────────────────
class TariffTypeScreen extends StatefulWidget {
  @override
  _TariffTypeScreenState createState() => _TariffTypeScreenState();
}

class _TariffTypeScreenState extends State<TariffTypeScreen> {
  bool? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.tariffAnswered ? (profile.tariff == 'PPA') : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.16,
      question: 'What type of electricity tariff are you on?',
      answered: _selected != null,
      backRoute: '/water-spend',
      onNext: () {
        profile.tariff = _selected! ? 'PPA' : 'standard';
        profile.tariffAnswered = true;
        profile.update();
        context.go('/transport-intro');
      },
      answerContent: buildYesNoOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        leftLabel: 'Green (PPA)',
        leftIcon: Icons.eco,
        leftSubtitle: 'Power Purchase Agreement tariffs only, sourced directly from renewable sites (for example with Octopus Energy\'s green tariff)',
        rightLabel: 'Standard',
        rightIcon: Icons.bolt,
        rightSubtitle: 'A regular electricity tariff from the general grid mix. Don\'t know? Select this!',
      ),
    );
  }
}

// ── Transport Section Intro ─────────────────────────────────────────────
class TransportIntroScreen extends StatelessWidget {
  static const Color kTransportBlue = Color(0xFF5B84A6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/hob-type'),
        ),
        actions: [
          _authBarButton(context, accentColor: kTransportBlue),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(Icons.directions_car, color: kTransportBlue, size: 90),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Transport',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About how you get around',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/car-size'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTransportBlue,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Car Size Question ───────────────────────────────────────────────────
class CarSizeScreen extends StatefulWidget {
  @override
  _CarSizeScreenState createState() => _CarSizeScreenState();
}

class _CarSizeScreenState extends State<CarSizeScreen> {
  String? _selected;
  static const Color kTransportBlue = Color(0xFF5B84A6);

  final List<Map<String, String>> _options = [
    {'value': 'mini', 'label': 'Very Small Car', 'image': 'assets/images/car_mini.png', 'description': 'e.g. Fiat 500, Smart Car'},
    {'value': 'supermini', 'label': 'Small Car', 'image': 'assets/images/car_supermini.png', 'description': 'e.g. VW Polo, Ford Fiesta'},
    {'value': 'lower_medium', 'label': 'Medium Car', 'image': 'assets/images/car_lower_medium.png', 'description': 'e.g. VW Golf, Ford Focus'},
    {'value': 'upper_medium', 'label': 'Large Car', 'image': 'assets/images/car_upper_medium.png', 'description': 'e.g. BMW 3 Series, Audi A4'},
    {'value': 'executive', 'label': 'Premium Car', 'image': 'assets/images/car_executive.png', 'description': 'e.g. BMW 5 Series, Mercedes E-Class'},
    {'value': 'luxury', 'label': 'Luxury Car', 'image': 'assets/images/car_luxury.png', 'description': 'e.g. Mercedes S-Class, Bentley'},
    {'value': 'sports', 'label': 'Sports Car', 'image': 'assets/images/car_sports.png', 'description': 'e.g. Porsche 911, Mazda MX-5'},
    {'value': 'dual_purpose', 'label': 'SUV / 4x4', 'image': 'assets/images/car_suv.png', 'description': 'e.g. Toyota RAV4, VW Tiguan'},
    {'value': 'mpv', 'label': 'People Carrier', 'image': 'assets/images/car_mpv.png', 'description': 'e.g. Ford Galaxy, VW Sharan'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.carSizeAnswered ? profile.carSize : null;
  }

  void _showDescription(Map<String, String> option) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(option['label']!),
          content: Text(option['description']!),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selected = option['value']);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: kTransportBlue),
              child: Text('Select this car type'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.20,
      question: 'What size is your car?',
      answered: _selected != null,
      backRoute: '/transport-intro',
      accentColor: kTransportBlue,
      onNext: () {
        profile.carSize = _selected!;
        profile.carSizeAnswered = true;
        profile.update();
        context.go('/car-fuel');
      },
      answerContent: SizedBox(
        height: 340,
        child: SingleChildScrollView(
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
            children: _options.map((opt) {
              final isSelected = _selected == opt['value'];
              return GestureDetector(
                onTap: () => _showDescription(opt),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? kTransportBlue.withOpacity(0.15) : kSurface,
                    border: Border.all(color: isSelected ? kTransportBlue : kBorder, width: isSelected ? 2 : 1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Image.asset(
                          opt['image']!,
                          fit: BoxFit.contain,
                          color: isSelected ? kTransportBlue : kTextSubtle,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        opt['label']!,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Car Fuel Question ───────────────────────────────────────────────
class CarFuelScreen extends StatefulWidget {
  @override
  _CarFuelScreenState createState() => _CarFuelScreenState();
}

class _CarFuelScreenState extends State<CarFuelScreen> {
  String? _selected;
  static const Color kTransportBlue = Color(0xFF5B84A6);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.carFuelTypeAnswered ? profile.carFuel : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.22,
      question: 'What type of fuel does your car use?',
      answered: _selected != null,
      backRoute: '/car-size',
      accentColor: kTransportBlue,
      onNext: () {
        profile.carFuel = _selected!;
        profile.carFuelTypeAnswered = true;
        profile.update();
        context.go('/weekly-mileage');
      },
      answerContent: buildSingleSelectOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        accentColor: kTransportBlue,
        options: [
          {
            'value': 'petrol',
            'label': 'Petrol',
            'icon': Icons.local_gas_station,
          },
          {
            'value': 'diesel',
            'label': 'Diesel',
            'icon': Icons.oil_barrel,
          },
          {
            'value': 'plug in hybrid',
            'label': 'Plug In Hybrid',
            'icon': Icons.ev_station,
          },
          {
            'value': 'electric',
            'label': 'Electric',
            'icon': Icons.electric_bolt,
          },
        ],
      ),
    );
  }
}

// ──── Weekly Mileage Question ────────────────────────────────────────────────
class WeeklyMileageScreen extends StatefulWidget {
  @override
  _WeeklyMileageScreenState createState() => _WeeklyMileageScreenState();
}

class _WeeklyMileageScreenState extends State<WeeklyMileageScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;
  static const Color kTransportBlue = Color(0xFF5B84A6);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.weeklyMileage > 0) {
      _controller.text = profile.weeklyMileage.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.24,
      question: 'What is you average weekly mileage?',
      answered: _hasValue,
      backRoute: '/car-fuel',
      accentColor: kTransportBlue,
      onNext: () {
        profile.weeklyMileage = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/bus-spend');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '90',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'miles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Bus/Taxi Question ────────────────────────────────────────────────
class BusSpendScreen extends StatefulWidget {
  @override
  _BusSpendScreenState createState() => _BusSpendScreenState();
}

class _BusSpendScreenState extends State<BusSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;
  static const Color kTransportBlue = Color(0xFF5B84A6);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyBusSpend > 0) {
      _controller.text = profile.monthlyBusSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.26,
      question: 'How much do you spend per month on bus and taxi fares?',
      answered: _hasValue,
      backRoute: '/weekly-mileage',
      accentColor: kTransportBlue,
      onNext: () {
        profile.monthlyBusSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/train-spend');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '25',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Train Question ────────────────────────────────────────────────
class TrainSpendScreen extends StatefulWidget {
  @override
  _TrainSpendScreenState createState() => _TrainSpendScreenState();
}

class _TrainSpendScreenState extends State<TrainSpendScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;
  static const Color kTransportBlue = Color(0xFF5B84A6);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.monthlyTrainSpend > 0) {
      _controller.text = profile.monthlyTrainSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.28,
      question: 'How much do you spend per month on train fares?',
      answered: _hasValue,
      backRoute: '/bus-spend',
      accentColor: kTransportBlue,
      onNext: () {
        profile.monthlyTrainSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/flights-intro');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '45',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const Color kFlightsGreen = Color(0xFF01821F);
// ── Flights Section Intro ───────────────────────────────────────────────
class FlightsIntroScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/train-spend'),
        ),
        actions: [
          _authBarButton(context, accentColor: kFlightsGreen),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(Icons.flight, color: kFlightsGreen, size: 90),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Flights',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About your air travel',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/flights-question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kFlightsGreen,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Flights Question — Interactive Globe ────────────────────────────────
class FlightsGlobeScreen extends StatefulWidget {
  @override
  _FlightsGlobeScreenState createState() => _FlightsGlobeScreenState();
}

enum _TripStep { none, countryList, nights, accommodation, people }

class _FlightsGlobeScreenState extends State<FlightsGlobeScreen> {
  late final EarthController _controller;

  _TripStep _step = _TripStep.none;
  List<String> _countryOptions = [];
  String? _selectedCountry;
  final _nightsController = TextEditingController();
  bool _hasNights = false;
  String? _selectedAccommodation;
  int? _selectedPeople;
  Offset _dragOffset = Offset.zero;
  int? _editingIndex;
  double? _currentCo2;
  bool _showTripsList = false;

  @override
  void initState() {
    super.initState();
    _controller = EarthController();
    _controller.setLightMode(EarthLightMode.followCamera);
    _controller.enableAutoRotate = true;

    _nightsController.addListener(() {
      setState(() => _hasNights = _nightsController.text.trim().isNotEmpty);
    });

    for (final region in globeRegions) {
      final regionLat = region['lat'] as double;
      final regionLon = region['lon'] as double;
      _controller.addNode(
        EarthNode(
          id: region['id'] as String,
          latitude: regionLat,
          longitude: regionLon,
          child: GestureDetector(
            onTap: () => _onRegionTapped(regionLat, regionLon),
            child: Icon(Icons.location_on, color: kFlightsGreen, size: 28),
          ),
        ),
      );
    }

    _fetchLiveTotal();
  }

  Future<void> _fetchLiveTotal() async {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    try {
      final response = await http.post(
        Uri.parse('https://netzero-production.up.railway.app/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(profile.toProfile()),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _currentCo2 = (data['total_kg_co2e'] as num).toDouble());
      }
    } catch (e) {
      // silently ignore
    }
  }

  void _onRegionTapped(double lat, double lon) {
    _controller.enableAutoRotate = false;
    _controller.setCameraFocus(lat, lon);
    _controller.setZoom(2.0);
    setState(() {
      _countryOptions = findNearbyCountries(lat, lon);
      _step = _TripStep.countryList;
    });
  }

  void _selectCountry(String country) {
    setState(() {
      _selectedCountry = country;
      _step = _TripStep.nights;
    });
  }

  void _saveTrip() {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    final tripData = {
      'country': _selectedCountry,
      'nights': int.tryParse(_nightsController.text) ?? 0,
      'accommodation': _selectedAccommodation,
      'passengers': _selectedPeople,
      'seat': 'economy',
    };
    if (_editingIndex != null) {
      profile.flights[_editingIndex!] = tripData;
    } else {
      profile.flights.add(tripData);
    }
    profile.update();
    _controller.enableAutoRotate = true;
    _controller.setZoom(1.0);
    setState(() {
      _step = _TripStep.none;
      _selectedCountry = null;
      _nightsController.clear();
      _selectedAccommodation = null;
      _selectedPeople = null;
      _editingIndex = null;
    });
    _fetchLiveTotal();
  }

  void _editTrip(int index) {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    final trip = profile.flights[index];
    setState(() {
      _selectedCountry = trip['country'];
      _nightsController.text = trip['nights'].toString();
      _hasNights = true;
      _selectedAccommodation = trip['accommodation'];
      _selectedPeople = trip['passengers'];
      _editingIndex = index;
      _step = _TripStep.nights;
    });
  }

  void _removeTrip(int index) {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    setState(() {
      profile.flights.removeAt(index);
    });
    profile.update();
    _fetchLiveTotal();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nightsController.dispose();
    super.dispose();
  }

  Widget _buildTripsList() {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.flights.isEmpty) return SizedBox.shrink();

    return Container(
      constraints: BoxConstraints(maxHeight: 200),
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: profile.flights.length,
        itemBuilder: (context, index) {
          final trip = profile.flights[index];
          return ListTile(
            dense: true,
            title: Text('${trip['country']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${trip['nights']} nights • ${trip['accommodation']} • ${trip['passengers']} people',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: kFlightsGreen, size: 20),
                  onPressed: () => _editTrip(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _removeTrip(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOverlayPanel() {
    switch (_step) {
      case _TripStep.countryList:
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(maxHeight: 320, maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Which country?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
              SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countryOptions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_countryOptions[index]),
                      onTap: () => _selectCountry(_countryOptions[index]),
                    );
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  _controller.enableAutoRotate = true;
                  _controller.setZoom(1.0);
                  setState(() => _step = _TripStep.none);
                },
                child: Text('Cancel', style: TextStyle(color: kTextSubtle)),
              ),
            ],
          ),
        );

      case _TripStep.nights:
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _step = _TripStep.countryList),
                ),
              ),
              Text('How many nights in $_selectedCountry?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              TextField(
                controller: _nightsController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*'))],
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
                decoration: InputDecoration(
                  hintText: 'e.g. 7',
                  hintStyle: TextStyle(color: kText),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _hasNights ? () => setState(() => _step = _TripStep.accommodation) : null,
                style: ElevatedButton.styleFrom(backgroundColor: kFlightsGreen),
                child: Text('Next →', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

      case _TripStep.accommodation:
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _step = _TripStep.nights),
                ),
              ),
              Text('Where did you stay in $_selectedCountry?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              buildSingleSelectOptions(
                selected: _selectedAccommodation,
                onSelect: (value) => setState(() {
                  _selectedAccommodation = value;
                  _step = _TripStep.people;
                }),
                accentColor: kFlightsGreen,
                options: [
                  {'value': 'hotel', 'label': 'Hotel', 'icon': Icons.hotel},
                  {'value': 'airbnb', 'label': 'Airbnb / Rental', 'icon': Icons.house},
                  {'value': 'friends_family', 'label': 'With friends/family', 'icon': Icons.people},
                  {'value': 'hostel', 'label': 'Hostel', 'icon': Icons.bed},
                ],
              ),
            ],
          ),
        );

      case _TripStep.people:
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() => _step = _TripStep.accommodation),
                ),
              ),
              Text('How many people from your household went?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.center),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_selectedPeople != null && _selectedPeople! > 1) {
                        setState(() => _selectedPeople = _selectedPeople! - 1);
                      }
                    },
                    icon: Icon(Icons.remove_circle_outline, color: kFlightsGreen),
                  ),
                  Text(_selectedPeople?.toString() ?? '–', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  IconButton(
                    onPressed: () => setState(() => _selectedPeople = (_selectedPeople ?? 0) + 1),
                    icon: Icon(Icons.add_circle_outline, color: kFlightsGreen),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedPeople == null ? null : _saveTrip,
                style: ElevatedButton.styleFrom(backgroundColor: kFlightsGreen),
                child: Text(_editingIndex != null ? 'Update Trip' : 'Save Trip', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );

      case _TripStep.none:
        return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/flights-intro'),
        ),
        title: Text(
          'Your recent holidays',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kText),
        ),
        centerTitle: true,
        actions: [
          if (_currentCo2 != null)
            Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.eco, color: kFlightsGreen, size: 18),
                    SizedBox(width: 4),
                    Text('${_currentCo2!.toStringAsFixed(0)} kg', style: TextStyle(fontWeight: FontWeight.bold, color: kText)),
                  ],
                ),
              ),
            ),
          _authBarButton(context, accentColor: kFlightsGreen),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onPanStart: (_) => _controller.enableAutoRotate = false,
                child: Earth3D(
                  controller: _controller,
                  texture: const AssetImage('assets/images/2k_earth-day.jpg'),
                  initialScale: 3,
                ),
              ),
            ),
            if (_step == _TripStep.none)
              Positioned(
                left: 24,
                right: 24,
                bottom: 32,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_showTripsList) _buildTripsList(),
                    if (Provider.of<ProfileStore>(context, listen: false).flights.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _showTripsList = !_showTripsList),
                        child: Text(
                          _showTripsList ? 'Hide trips' : 'See trips',
                          style: TextStyle(color: kFlightsGreen, fontWeight: FontWeight.bold),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/uk-intro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kFlightsGreen,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('No more trips →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            if (_step != _TripStep.none)
              Positioned.fill(
                child: Center(
                  child: _buildOverlayPanel(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const Color kTripsRed = Color(0xFFE66051);
// ── UK Trips Section Intro ───────────────────────────────────────────────
class UKIntroScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/flights-question'),
        ),
        actions: [
          _authBarButton(context, accentColor: kTripsRed),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(Icons.flight, color: kTripsRed, size: 90),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'UK Stays',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'About nights away in the UK',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/hotel-nights'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTripsRed,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──── Hotel Stays Question ────────────────────────────────────────────────
class HotelNightsScreen extends StatefulWidget {
  @override
  _HotelNightsScreenState createState() => _HotelNightsScreenState();
}

class _HotelNightsScreenState extends State<HotelNightsScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;
  static const Color kTripsRed = Color(0xFFE66051);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.hotelNights > 0) {
      _controller.text = profile.hotelNights.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.44,
      question: 'Roughly how many nights per year do you stay in UK airbnb\'s or holiday homes?',
      answered: _hasValue,
      backRoute: '/UK-intro',
      accentColor: kTripsRed,
      onNext: () {
        profile.hotelNights = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/airbnb-nights');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '10',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'nights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──── AirBnB Stays Question ────────────────────────────────────────────────
class AirbnbNightsScreen extends StatefulWidget {
  @override
  _AirbnbNightsScreenState createState() => _AirbnbNightsScreenState();
}

class _AirbnbNightsScreenState extends State<AirbnbNightsScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;
  static const Color kTripsRed = Color(0xFFE66051);

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.airbnbNights > 0) {
      _controller.text = profile.airbnbNights.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.44,
      question: 'Roughly how many nights per year do you stay in UK hotels?',
      answered: _hasValue,
      backRoute: '/hotel-nights',
      accentColor: kTripsRed,
      onNext: () {
        profile.airbnbNights = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/pets-intro');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '10',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  'nights',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const Color kPetsPurple = Color(0xFFB660F3);
// ── Pets Section Intro ───────────────────────────────────────────────
class PetsIntroScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/airbnb-nights'),
        ),
        actions: [
          _authBarButton(context, accentColor: kPetsPurple),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(Icons.flight, color: kPetsPurple, size: 90),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Your Pets',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your pets and their diets',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/pets-question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPetsPurple,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pets Question Screen ────────────────────────────────────────────────
class PetsQuestionScreen extends StatefulWidget {
  @override
  _PetsQuestionScreenState createState() => _PetsQuestionScreenState();
}

class _PetsQuestionScreenState extends State<PetsQuestionScreen> {
  List<Map<String, dynamic>> _pets = [];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _pets = profile.pets.map((pet) => Map<String, dynamic>.from(pet)).toList();
  }

  void _showAddPetDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 280,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('What type of pet?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kText)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () => _addPet('dog'),
                    child: Column(
                      children: [
                        Icon(Icons.pets, color: kPetsPurple, size: 40),
                        SizedBox(height: 6),
                        Text('Dog', style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _addPet('cat'),
                    child: Column(
                      children: [
                        Icon(Icons.pets, color: kPetsPurple, size: 40),
                        SizedBox(height: 6),
                        Text('Cat', style: TextStyle(color: kText, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addPet(String type) {
    Navigator.of(context).pop();
    setState(() {
      _pets.add({
        'type': type,
        'name': '',
        'food': null,
        'brand': null,
        'diet': null,
        'weight': null,
      });
    });
  }

  Widget _buildAddPetButton() {
    return GestureDetector(
      onTap: _showAddPetDialog,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          border: Border.all(color: kPetsPurple, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.add_circle_outline, color: kPetsPurple, size: 48),
            SizedBox(height: 8),
            Text('Add a pet', style: TextStyle(color: kPetsPurple, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.75,
      question: 'Do you have any pets?',
      answered: true,
      accentColor: kPetsPurple,
      backRoute: '/pets-intro',
      onNext: () {
        profile.pets = _pets;
        profile.update();
        context.go('/diet-intro');
      },
      answerContent: SizedBox(
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ..._pets.asMap().entries.map((entry) {
                final index = entry.key;
                final pet = entry.value;
                return PetCard(
                  pet: pet,
                  onChanged: (updated) => setState(() => _pets[index] = updated),
                  onRemove: () => setState(() => _pets.removeAt(index)),
                );
              }),
              _buildAddPetButton(),
            ],
          ),
        ),
      ),
    );
  }
}

const Color kDietOrange = Color(0xFFDC983F);
// ── Diet Section Intro ───────────────────────────────────────────────
class DietIntroScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/pets-question'),
        ),
        actions: [
          _authBarButton(context, accentColor: kDietOrange),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                right: 24,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Icon(Icons.restaurant, color: kDietOrange, size: 90),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Diet and Waste',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: kTextSubtle),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your food\'s footprint',
                      style: TextStyle(fontSize: 16, color: kTextSubtle, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.go('/rm-days'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDietOrange,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: StadiumBorder(),
                        ),
                        child: Text('Let\'s Go →', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──── Red Meat Question ────────────────────────────────────────────────
class RMDaysScreen extends StatefulWidget {
  @override
  _RMDaysScreenState createState() => _RMDaysScreenState();
}

class _RMDaysScreenState extends State<RMDaysScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.rmDays > 0) {
      _controller.text = profile.rmDays.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.6,
      question: 'How many days a week do you eat red meat?',
      subheading: '(e.g. beef or pork)',
      answered: _hasValue,
      backRoute: '/diet-intro',
      accentColor: kDietOrange,
      onNext: () {
        profile.rmDays = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/wm-days');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '1',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  (double.tryParse(_controller.text) ?? 0) == 1 ? 'day' : 'days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──── White Meat Question ────────────────────────────────────────────────
class WMDaysScreen extends StatefulWidget {
  @override
  _WMDaysScreenState createState() => _WMDaysScreenState();
}

class _WMDaysScreenState extends State<WMDaysScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.wmDays > 0) {
      _controller.text = profile.wmDays.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.62,
      question: 'How many days a week do you eat white meat?',
      subheading: '(e.g. chicken or fish)',
      answered: _hasValue,
      backRoute: '/rm-spend',
      accentColor: kDietOrange,
      onNext: () {
        profile.wmDays = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/weekly-shop');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '3',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Text(
                  (double.tryParse(_controller.text) ?? 0) == 1 ? 'day' : 'days',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──── Weekly Shop Question ────────────────────────────────────────────────
class WeeklyShopScreen extends StatefulWidget {
  @override
  _WeeklyShopScreenState createState() => _WeeklyShopScreenState();
}

class _WeeklyShopScreenState extends State<WeeklyShopScreen> {
  final _controller = TextEditingController();
  bool _hasValue = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    if (profile.nonMeatSpend > 0) {
      _controller.text = profile.nonMeatSpend.toString();
      _hasValue = true;
    }
    _controller.addListener(() {
      setState(() => _hasValue = _controller.text.trim().isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.64,
      question: 'Roughly how much do you spend on your weekly shop?',
      answered: _hasValue,
      backRoute: '/wm-days',
      accentColor: kDietOrange,
      onNext: () {
        profile.nonMeatSpend = double.tryParse(_controller.text) ?? 0;
        profile.update();
        context.go('/waste');
      },
      answerContent: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: kSurface,
              border: Border.all(color: kBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (!_hasValue)
                  Text(
                    'e.g.',
                    style: TextStyle(fontSize: 20, color: kText),
                  ),
                Text(
                  '£',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: _hasValue ? FontWeight.bold : FontWeight.normal,
                    color: kText,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '60',
                      hintStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: kText),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Waste Question ───────────────────────────────────────────────
class WasteScreen extends StatefulWidget {
  @override
  _WasteScreenState createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.wasteAnswered ? profile.wasteAction : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.66,
      question: 'What do you do with your rubbish?',
      answered: _selected != null,
      backRoute: '/weekly-shop',
      accentColor: kDietOrange,
      onNext: () {
        profile.wasteAction = _selected!;
        profile.wasteAnswered = true;
        profile.update();
        context.go('/food-waste');
      },
      answerContent: buildSingleSelectOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        accentColor: kDietOrange,
        options: [
          {
            'value': 'recycle',
            'label': 'I recycle wherever possible',
            'icon': Icons.recycling,
          },
          {
            'value': 'non_recycle',
            'label': 'I hardly ever recycle',
            'icon': Icons.delete,
          },
          {
            'value': 'upcycle',
            'label': 'I upcycle where possible, and recycle if I can\'t',
            'icon': Icons.checkroom,
          },
        ],
      ),
    );
  }
}

// ── Food Waste Question ───────────────────────────────────────────────
class FoodWasteScreen extends StatefulWidget {
  @override
  _FoodWasteScreenState createState() => _FoodWasteScreenState();
}

class _FoodWasteScreenState extends State<FoodWasteScreen> {
  String? _selected;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _selected = profile.foodWasteAnswered ? profile.foodWasteAction : null;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context, listen: false);

    return QuizFrame(
      progress: 0.68,
      question: 'What do you do with your food waste?',
      answered: _selected != null,
      backRoute: '/waste',
      accentColor: kDietOrange,
      onNext: () {
        profile.foodWasteAction = _selected!;
        profile.foodWasteAnswered = true;
        profile.update();
        context.go('/spending-intro');
      },
      answerContent: buildSingleSelectOptions(
        selected: _selected,
        onSelect: (value) => setState(() => _selected = value),
        accentColor: kDietOrange,
        options: [
          {
            'value': 'bin',
            'label': 'I put it in the normal bin',
            'icon': Icons.delete,
          },
          {
            'value': 'compost',
            'label': 'I try to compost it',
            'icon': Icons.compost,
          },
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
  String? _foodWaste;
  String? _normalWaste;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _rmDays = profile.rmDays;
    _wmDays = profile.wmDays;
    _shoppingController.text = profile.nonMeatSpend > 0 ? profile.nonMeatSpend.toString() : '';
    _foodWaste = profile.foodWasteAction;
    _normalWaste = profile.wasteAction;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/flights'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                  SizedBox(height: 6),
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
                  SizedBox(height: 10),

                  // White meat days
                  Text('Number of days a week that you eat white meat',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 6),
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

                  SizedBox(height: 10),

                  // Shopping spend
                  Text('Weekly shopping spend on non-meat items',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  TextField(
                    controller: _shoppingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
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
                      DropdownMenuItem(value: 'bin', child: Text('Put it in the normal bin')),
                      DropdownMenuItem(value: 'compost', child: Text('Compost it/Food waste bin')),
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
                      DropdownMenuItem(value: 'non_recycle', child: Text('Put it in the normal bin')),
                      DropdownMenuItem(value: 'upcycle', child: Text('Upcycle')),
                    ],
                    onChanged: (value) => setState(() => _normalWaste = value!),
                  ),
                  SizedBox(height: 24),                

                  SizedBox(height: 32),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_foodWaste == null || _normalWaste == null) ? null :() {
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
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _takeawayController.text = profile.monthlyTakeaway > 0 ? profile.monthlyTakeaway.toString() : '0';
    _drinksController.text = profile.monthlyDrinks > 0 ? profile.monthlyDrinks.toString() : '0';
    _alcoholController.text = profile.monthlyAlcohol > 0 ? profile.monthlyAlcohol.toString() : '0';
    _tobaccoController.text = profile.monthlyTobacco > 0 ? profile.monthlyTobacco.toString() : '0';
    _clothesController.text = profile.monthlyClothes > 0 ? profile.monthlyClothes.toString() : '0';
    _soapController.text = profile.monthlySoap > 0 ? profile.monthlySoap.toString() : '0';
    _medicineController.text = profile.monthlyMedicine > 0 ? profile.monthlyMedicine.toString() : '0';
    _electronicsController.text = profile.yearlyElectronics > 0 ? profile.yearlyElectronics.toString() : '0';
    _machineryController.text = profile.yearlyMachinery > 0 ? profile.yearlyMachinery.toString() : '0';
    _educationController.text = profile.monthlyEducation > 0 ? profile.monthlyEducation.toString() : '0';
    _healthcareController.text = profile.monthlyHealthcare > 0 ? profile.monthlyHealthcare.toString() : '0';
    _careController.text = profile.monthlyCare > 0 ? profile.monthlyCare.toString() : '0';
    _furnitureController.text = profile.yearlyFurniture > 0 ? profile.yearlyFurniture.toString() : '0';
    _servicesController.text = profile.monthlyServices > 0 ? profile.monthlyServices.toString() : '0';
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/pets'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                      context.go('/household');
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
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
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

// ── Household Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
class HouseholdScreen extends StatefulWidget {
  @override
  _HouseholdScreenState createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends State<HouseholdScreen> {
  int? _numPeople;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _numPeople = profile.numPeople;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/spending'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),

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
                  'Last Question...',
                  style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                progressBar(0.1),
                SizedBox(height: 24),

                Text(
                  'How many people are there in your household?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 70),

                // Number of people
                Text('Number of people in your household',
                    style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_numPeople != null && _numPeople! > 1) setState(() => _numPeople = _numPeople! - 1);
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
                      onPressed: () => setState(() => _numPeople = (_numPeople ?? 0) + 1),
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
                    onPressed: _numPeople == null ? null : () {
                      profile.numPeople = _numPeople;
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
        ),   // ← closes screenWrapper
      ),     // ← closes SafeArea
    );       // ← closes Scaffold
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/household'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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

        // Start again and Quiz buttons
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go('/login-reminder'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: StadiumBorder(),
            ),
            child: Text(
              'See how to reduce your footprint',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => context.go('/welcome'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18),
              side: BorderSide(color: kPrimary),
              shape: StadiumBorder(),
            ),
            child: Text(
              'Start Again',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimary),
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

// ── Login Reminder Screen ───────────────────────────────────────────────────
class LoginReminderScreen extends StatefulWidget {
  @override
  _LoginReminderScreenState createState() => _LoginReminderScreenState();
}

class _LoginReminderScreenState extends State<LoginReminderScreen> {
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLoggedIn();
  }

  void _checkIfAlreadyLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      context.go('/phase2');
      return;
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimary)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.save_outlined, color: kPrimary, size: 64),
                SizedBox(height: 32),
                Text(
                  'Save your progress',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kText),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Create an account so you can pick up where you left off, on any device.',
                  style: TextStyle(fontSize: 16, color: kTextSubtle, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login?redirect=/phase2'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: StadiumBorder(),
                    ),
                    child: Text('Create an account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/phase2'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      side: BorderSide(color: kBorder),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      'Not now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kTextSubtle),
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

// ── Phase 2 Screen ─────────────────────────────────────────────────────────
class Phase2Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/results'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Logo/icon
                Image.asset(
                  'assets/images/leaf_icon.png',
                  height: 64,
                ),
                SizedBox(height: 32),

                // Title
                Text(
                  'Phase 2',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  'About you and your house',
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
                    onPressed: () => context.go('/quiz'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      padding: EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ready?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),   
      ),     
    );       
  }
}

// ── Quiz Screen ─────────────────────────────────────────────────────────
class QuizScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/phase2'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Logo/icon
                Image.asset(
                  'assets/images/leaf_icon.png',
                  height: 64,
                ),
                SizedBox(height: 32),

                // Title
                Text(
                  'About You',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  'A short quiz about your habits and household to identify the most effective emission reduction actions!',
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
                    onPressed: () => context.go('/energyaction'),
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
              ],
            ),
          ),
        ),   
      ),     
    );       
  }
}

// ── Energy Action Screen ────────────────────────────────────────────────
class EnergyActionScreen extends StatefulWidget {
  @override
  _EnergyActionScreenState createState() => _EnergyActionScreenState();
}

class _EnergyActionScreenState extends State<EnergyActionScreen> {
  bool _smartThermostat = false;
  bool _savingSockets = false;
  bool _batteryStorage = false;
  bool _savingShower = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _smartThermostat = profile.smartThermostat;
    _savingSockets = profile.savingSockets;
    _batteryStorage = profile.batteryStorage;
    _savingShower = profile.savingShower;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/quiz'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                    'Energy Actions',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  progressBar(0.0),
                  SizedBox(height: 24),

                  Text(
                    'Which of these do you already have?',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This stops us recommending things you\'ve already done.',
                    style: TextStyle(color: kTextSubtle),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24),

                  CheckboxListTile(
                    value: _smartThermostat,
                    onChanged: (value) => setState(() => _smartThermostat = value!),
                    title: Text('Smart thermostat', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _savingSockets,
                    onChanged: (value) => setState(() => _savingSockets = value!),
                    title: Text('Energy-saving sockets', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _batteryStorage,
                    onChanged: (value) => setState(() => _batteryStorage = value!),
                    title: Text('Battery storage', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _savingShower,
                    onChanged: (value) => setState(() => _savingShower = value!),
                    title: Text('Water-saving shower head', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.smartThermostat = _smartThermostat;
                        profile.savingSockets = _savingSockets;
                        profile.batteryStorage = _batteryStorage;
                        profile.savingShower = _savingShower;
                        profile.update();
                        context.go('/homeinfo');
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

// ── Home Info Screen ────────────────────────────────────────────────────
class HomeInfoScreen extends StatefulWidget {
  @override
  _HomeInfoScreenState createState() => _HomeInfoScreenState();
}

class _HomeInfoScreenState extends State<HomeInfoScreen> {
  final _incandescentController = TextEditingController(text: '0');
  final _cflController = TextEditingController(text: '0');
  final _ledController = TextEditingController(text: '0');
  String _propertyType = 'semi_detached';
  String _boilerAge = '10-15';
  String _showerType = 'power_mixer';
  String _wallType = 'cavity';

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _incandescentController.text = profile.incandescentBulbs > 0 ? profile.incandescentBulbs.toString() : '0';
    _cflController.text = profile.cflBulbs > 0 ? profile.cflBulbs.toString() : '0';
    _ledController.text = profile.ledBulbs > 0 ? profile.ledBulbs.toString() : '0';
    _propertyType = profile.propertyType;
    _boilerAge = profile.boilerAge;
    _showerType = profile.showerType;
    _wallType = profile.wallType;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/energyaction'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                    'Home Info',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  progressBar(0.25),
                  SizedBox(height: 24),

                  Text(
                    'Tell us about your property',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  Text('Property type',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _propertyType,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'detached', child: Text('Detached')),
                      DropdownMenuItem(value: 'semi_detached', child: Text('Semi-Detached')),
                      DropdownMenuItem(value: 'terraced', child: Text('Terraced')),
                      DropdownMenuItem(value: 'bungalow', child: Text('Bungalow')),
                      DropdownMenuItem(value: 'flat', child: Text('Flat')),
                    ],
                    onChanged: (value) => setState(() => _propertyType = value!),
                  ),
                  SizedBox(height: 24),

                  Text('What type of walls does your property have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 4),
                  Text(
                    'Not sure? Cavity walls have a small gap inside; solid walls are typically found in older properties (pre-1930s).',
                    style: TextStyle(color: kTextSubtle, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _wallType,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'cavity', child: Text('Cavity wall')),
                      DropdownMenuItem(value: 'solid_wall', child: Text('Solid wall')),
                    ],
                    onChanged: (value) => setState(() => _wallType = value!),
                  ),
                  SizedBox(height: 24),

                  Text('How old is your boiler?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _boilerAge,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'unsure', child: Text('I\'m not sure')),
                      DropdownMenuItem(value: '< 10', child: Text('Less than 10 years')),
                      DropdownMenuItem(value: '10-15', child: Text('10-15 years')),
                      DropdownMenuItem(value: '15-20', child: Text('15-20 years')),
                      DropdownMenuItem(value: '20-25', child: Text('20-25 years')),
                      DropdownMenuItem(value: '> 25', child: Text('More than 25 years')),
                    ],
                    onChanged: (value) => setState(() => _boilerAge = value!),
                  ),
                  SizedBox(height: 24),

                  Text('How many incandescent (old-style) bulbs do you have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  TextField(
                    controller: _incandescentController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: 'e.g. 4'),
                  ),
                  SizedBox(height: 24),

                  Text('How many CFL (energy-saving spiral) bulbs do you have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  TextField(
                    controller: _cflController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: 'e.g. 2'),
                  ),
                  SizedBox(height: 24),

                  Text('How many LED bulbs do you have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  TextField(
                    controller: _ledController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: 'e.g. 6'),
                  ),
                  SizedBox(height: 24),

                  Text('What type of shower do you have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _showerType,
                    selectedItemBuilder: (context) => [
                      Text('Power / Mixer Shower'),
                      Text('Electric Shower'),
                    ],
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(
                        value: 'power_mixer',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Power / Mixer Shower'),
                            Text('Uses hot water from your boiler or hot water tank. Attached directly to the wall', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'electric_shower',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Electric Shower'),
                            Text('Has its own heating unit - usually a box on the wall above the shower', style: TextStyle(fontSize: 12, color: kTextSubtle)),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _showerType = value!),
                  ),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.incandescentBulbs = int.tryParse(_incandescentController.text) ?? 0;
                        profile.cflBulbs = int.tryParse(_cflController.text) ?? 0;
                        profile.ledBulbs = int.tryParse(_ledController.text) ?? 0;
                        profile.propertyType = _propertyType;
                        profile.boilerAge = _boilerAge;
                        profile.showerType = _showerType;
                        profile.wallType = _wallType;
                        profile.update();
                        context.go('/insulation');
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

// ── Insulation Screen ───────────────────────────────────────────────────
class InsulationScreen extends StatefulWidget {
  @override
  _InsulationScreenState createState() => _InsulationScreenState();
}

class _InsulationScreenState extends State<InsulationScreen> {
  String _insulationThickness = '0mm';
  bool _windowDP = false;
  bool _doorDP = false;
  bool _cylinderJacket = false;
  bool _radiatorPanels = false;
  bool _wallInsulation = false;
  bool _floorInsulation = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _insulationThickness = profile.insulationThickness;
    _windowDP = profile.windowDP;
    _doorDP = profile.doorDP;
    _cylinderJacket = profile.cylinderJacket;
    _radiatorPanels = profile.radiatorPanels;
    _wallInsulation = profile.wallInsulation;
    _floorInsulation = profile.floorInsulation;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/homeinfo'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                    'Insulation',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  progressBar(0.5),
                  SizedBox(height: 24),

                  Text(
                    'Your insulation situation',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  // Loft insulation thickness
                  Text('Loft insulation thickness',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _insulationThickness,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: '0mm', child: Text('None / no insulation')),
                      DropdownMenuItem(value: '100mm', child: Text('Some insulation (around 100mm)')),
                      DropdownMenuItem(value: '270mm', child: Text('Well insulated (270mm, current standard)')),
                    ],
                    onChanged: (value) => setState(() => _insulationThickness = value!),
                  ),
                  SizedBox(height: 24),

                  Text('Which of these do you already have?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),

                  CheckboxListTile(
                    value: _windowDP,
                    onChanged: (value) => setState(() => _windowDP = value!),
                    title: Text('Window draught-proofing', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _doorDP,
                    onChanged: (value) => setState(() => _doorDP = value!),
                    title: Text('Door draught-proofing', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _cylinderJacket,
                    onChanged: (value) => setState(() => _cylinderJacket = value!),
                    title: Text('Water cylinder jacket', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _radiatorPanels,
                    onChanged: (value) => setState(() => _radiatorPanels = value!),
                    title: Text('Reflective radiator panels', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _wallInsulation,
                    onChanged: (value) => setState(() => _wallInsulation = value!),
                    title: Text('Wall insulation', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    value: _floorInsulation,
                    onChanged: (value) => setState(() => _floorInsulation = value!),
                    title: Text('Floor insulation', style: TextStyle(color: kText)),
                    activeColor: kPrimary,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.insulationThickness = _insulationThickness;
                        profile.windowDP = _windowDP;
                        profile.doorDP = _doorDP;
                        profile.cylinderJacket = _cylinderJacket;
                        profile.radiatorPanels = _radiatorPanels;
                        profile.wallInsulation = _wallInsulation;
                        profile.floorInsulation = _floorInsulation;
                        profile.update();
                        context.go('/habit');
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

// ── Habit Screen ────────────────────────────────────────────────────────
class HabitScreen extends StatefulWidget {
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final _showerTimeController = TextEditingController(text: '5');
  String _radiatorBleeding = 'this_year';
  final _washingController = TextEditingController(text: '1');
  String _washingTemp = '40';

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _showerTimeController.text = profile.showerTime > 0 ? profile.showerTime.toString() : '5';
    _radiatorBleeding = profile.radiatorBleeding;
    _washingController.text = profile.washingFrequency > 0 ? profile.washingFrequency.toString() : '1';
    _washingTemp = profile.washingTemperature;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/insulation'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                    'Habits',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),
                  progressBar(0.75),
                  SizedBox(height: 24),

                  Text(
                    'A few quick habits',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32),

                  Text('Average total minutes spent in the shower per person, per day',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  TextField(
                    controller: _showerTimeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'e.g. 7',
                      suffixText: 'minutes',
                    ),
                  ),
                  SizedBox(height: 24),

                  Text('When did you last bleed your radiators?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _radiatorBleeding,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'never', child: Text('Never')),
                      DropdownMenuItem(value: 'over_a_year_ago', child: Text('More than a year ago')),
                      DropdownMenuItem(value: 'this_year', child: Text('Within the last year')),
                    ],
                    onChanged: (value) => setState(() => _radiatorBleeding = value!),
                  ),
                  SizedBox(height: 24),

                  Text('How many times a week do you use your washing machine?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  TextField(
                    controller: _washingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(hintText: 'e.g. 2'),
                  ),

                  SizedBox(height: 24),

                  Text('What temperature do you do your washing at?',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText),
                      textAlign: TextAlign.center),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _washingTemp,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: '30', child: Text('30°')),
                      DropdownMenuItem(value: '40', child: Text('40°')),
                      DropdownMenuItem(value: '60', child: Text('60°')),
                    ],
                    onChanged: (value) => setState(() => _washingTemp = value!),
                  ),
                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.showerTime = int.tryParse(_showerTimeController.text) ?? 0;
                        profile.radiatorBleeding = _radiatorBleeding;
                        profile.washingFrequency = int.tryParse(_washingController.text) ?? 0;
                        profile.washingTemperature = _washingTemp;
                        profile.update();
                        context.go('/homeowner');
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

// ── Homeowner Screen ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

class HomeownerScreen extends StatefulWidget {
  @override
  _HomeownerScreenState createState() => _HomeownerScreenState();
}

class _HomeownerScreenState extends State<HomeownerScreen> {
  String _homeowner = 'homeowner';

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileStore>(context, listen: false);
    _homeowner = profile.homeowner;
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileStore>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/habit'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
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
                    'Final Question',
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: kText),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 12),

                  progressBar(1.0),
                  SizedBox(height: 24),

                  // Fuel type dropdown
                  Text('Are you a...',
                      style: TextStyle(fontWeight: FontWeight.w600, color: kText)),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _homeowner,
                    decoration: InputDecoration(),
                    items: [
                      DropdownMenuItem(value: 'homeowner', child: Text('Home Owner?')),
                      DropdownMenuItem(value: 'renter', child: Text('Renter?')),
                    ],
                    onChanged: (value) => setState(() => _homeowner = value!),
                  ),

                  SizedBox(height: 32),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        profile.homeowner = _homeowner;
                        context.go('/phase3');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        shape: StadiumBorder(),
                      ),
                      child: Text(
                        'See My Recommendations →',
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

// ── Phase 3 Screen ─────────────────────────────────────────────────────────
class Phase3Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/homeowner'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // Logo/icon
                Image.asset(
                  'assets/images/leaf_icon.png',
                  height: 64,
                ),
                SizedBox(height: 32),

                // Title
                Text(
                  'Phase 3',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 16),

                // Subtitle
                Text(
                  'Reduction Actions',
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
                    onPressed: () => context.go('/actions'),
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
              ],
            ),
          ),
        ),   
      ),     
    );       
  }
}

// ── Actions / Recommendations Screen ───────────────────────────────────────────
class ActionScreen extends StatefulWidget { //create a state where this screen can always live
  @override
  _ActionScreenState createState() => _ActionScreenState();
}

//create a state which is changing. The changing thing is attached to the stationary thing, but the changing on is a placeholder
class _ActionScreenState extends State<ActionScreen> { 

  bool _loading = true; // when the screen is set up it is loading. Once it is working this goes to false
  String? _error; //either there is no error so this value is null (?) or there is an error. At the start there is no error so this is null, but if something happens i could give the error a value
  Map<String, dynamic>? _actions; //at the beginning I haven't called anything from the backend so actions is null. Later, I will call something so it won't be null anymore. Also there is no map so the map fuction is null.
  List<Map<String, dynamic>> _queue = [];
  List<String> _skippedNames = [];

  @override
  void initState() { //initState() is darts standard screen builder. I am saying void this and have my code there in place
    super.initState(); // flutters setup
    _getActions();  
  }

  Future<void> _getActions() async { // a specific value won't come back but stuff will happen and will get stored in actions (async means there will be pauses as stuff happens and thats okay)
    final profile = Provider.of<ProfileStore>(context, listen: false); //dart profile stores all of the user inputs, listen: false tells the program to not keep watching for changes
    try {
      final response = await http.post( // await the response
        Uri.parse('https://netzero-production.up.railway.app/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({ //so the dart and python can be translated
          'profile': profile.toProfile(), // converts every field recieved from profile into something that python can read (the quiz answers)
          'completed_actions': profile.completedActions, //what they have already done
          'dismissed_actions': profile.dismissedActions.map((a) => a['name']).toList(),
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          _actions = jsonDecode(response.body); // if it works, change actions to match the response
          _loading = false;
          _queue = List<Map<String, dynamic>>.from(_actions!['recommendations']);
          for (final name in _skippedNames) {
            _moveToBackOfTier(name);
          }
        });
      } 
      else {
        setState(() {
          _error = 'Server error: ${response.statusCode}'; //if it fails give an error message
          _loading = false;
        });
      }
    }
    catch (e) { //if there is an unexpected error, show this message
      setState(() {
        _error = 'Could not connect to server. Is the backend running?';
        _loading = false;
      });
    }
  }


  @override
  // creating a specific widget on this screen
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kText),
          onPressed: () => context.go('/phase3'),
        ),
        actions: [
          _authBarButton(context),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: screenWrapper(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: _loading
                ? Center(child: CircularProgressIndicator(color: kPrimary))
                : _error != null
                    ? _buildError()
                    : _queue.isEmpty
                        ? _buildAllDone()
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
          Text(_error!, //! means its not null at this point
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextSubtle)),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _loading = true;
                _error = null;
              });
              _getActions();
            },
            child: Text('Try again'),
          ),
        ],
      ),
    );
  }

  void _skip() {
    if (_queue.length <= 1) return;
    final name = _queue.first['name'] as String;
    setState(() {
      if (!_skippedNames.contains(name)) {
        _skippedNames.add(name);
      }
      _moveToBackOfTier(name);
    });
  }

  void _dismiss() {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    final dismissedCard = _queue.first;
    setState(() {
      _queue.removeAt(0);
    });
    profile.dismissedActions = [...profile.dismissedActions, dismissedCard];
    profile.update();
  }

  Future<void> _restore(Map<String, dynamic> card) async {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    profile.dismissedActions = profile.dismissedActions
        .where((a) => a['name'] != card['name'])
        .toList();
    profile.update();
    Navigator.of(context).pop(); // close the dialog
    await _getActions(); // re-fetch so the restored action reappears
  }

  Widget _buildResults() {
    final currentTotal = (_actions!['current_total_kg_co2e'] as num).toDouble();
    final totalSaved = (_actions!['total_saved_kg_co2e'] as num).toDouble();
    final card = _queue.first;
    final label = card['label'] as String;
    final cost = card['cost'] as String;
    final savings = (card['savings'] as num).toDouble();
    final savingsNote = card['savings_note'] as String?;
    final difficulty = card['difficulty'] as String;
    final reduction = (card['reduction_kg_co2e'] as num).toDouble();

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _showDismissed,
            child: Text('View dismissed (${Provider.of<ProfileStore>(context, listen: false).dismissedActions.length})'),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('Saved so far', style: TextStyle(color: kTextSubtle, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('${(totalSaved / 1000).toStringAsFixed(2)}t',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
                ],
              ),
              Column(
                children: [
                  Text('Remaining footprint', style: TextStyle(color: kTextSubtle, fontSize: 12)),
                  SizedBox(height: 4),
                  Text('${(currentTotal / 1000).toStringAsFixed(2)}t',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                '${reduction.toStringAsFixed(0)} kg CO₂e saved per year',
                style: TextStyle(fontSize: 16, color: kTextSubtle),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
                Text(
                  savingsNote ?? 'Saves you £${savings.toStringAsFixed(2)}/year  •   Difficulty: $difficulty',
                  style: TextStyle(fontSize: 13, color: kTextSubtle),
                ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _skip,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: kBorder),
                        shape: StadiumBorder(),
                      ),
                      child: Text(
                        'Skip →',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kTextSubtle),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _markDone,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: StadiumBorder(),
                      ),
                      child: Text(
                        'Done ✓',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _dismiss,
                  child: Text(
                    'Not interested — don\'t show this again',
                    style: TextStyle(color: kTextSubtle, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllDone() {
    final totalSaved = (_actions!['total_saved_kg_co2e'] as num).toDouble();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, color: kPrimary, size: 64),
          SizedBox(height: 16),
          Text(
            'You\'ve worked through every recommendation!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Total saved: ${(totalSaved / 1000).toStringAsFixed(2)}t CO₂e',
            style: TextStyle(fontSize: 16, color: kTextSubtle),
          ),
        ],
      ),
    );
  }
  
  void _showDismissed() {
    final profile = Provider.of<ProfileStore>(context, listen: false);
    showDialog( 
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Not interested'),
          content: profile.dismissedActions.isEmpty
              ? Text('Nothing dismissed yet.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView(
                    shrinkWrap: true,
                    children: profile.dismissedActions.map((card) {
                      return ListTile(
                        title: Text(card['label'] as String),
                        trailing: TextButton(
                          onPressed: () => _restore(card),
                          child: Text('Restore'),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _moveToBackOfTier(String name) {
    final index = _queue.indexWhere((a) => a['name'] == name); // finding the number of each specific item in the queue
    if (index == -1) return; // not in the current queue (e.g. already completed/dismissed) - nothing to do
    final item = _queue.removeAt(index);
    final cost = item['cost'];
    int insertIndex = _queue.length;
    for (int i = 0; i < _queue.length; i++) {
      if (_queue[i]['cost'] != cost) { // if the items cost is different from the one that got removed
        insertIndex = i; //remember the position
        break; // stop looping
      }
    }
    _queue.insert(insertIndex, item); // insert the removed item in that position
  }


  Future<void> _markDone() async { // no question mark as it always produces a future
    final profile = Provider.of<ProfileStore>(context, listen: false);
    final currentName = _queue.first['name'] as String;
    profile.completedActions = [...profile.completedActions, currentName]; // ... unpacks the list from profile.completedActions
    profile.update();
    await _getActions();
  }
}

// ---- Practice Screen -----------------------------
