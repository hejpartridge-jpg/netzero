python3 -c "
#importing all the functions from travel
from calculators.travel import (
    calculate_bus_emissions,
    calculate_train_emissions,
    calculate_car_emissions,
    calculate_flight_emissions,
    calculate_abroad_accomodation_emissions,
    calculate_uk_accomodation_emissions,
)

# ── BUS ──────────────────────────────────────────────────
bus = calculate_bus_emissions(5)
print(f'Bus: {bus:.1f} kg CO2e/year')


# ── TRAIN ──────────────────────────────────────────────────
train = calculate_train_emissions(20)
print(f'Train: {train:.1f} kg CO2e/year')


# ── CAR ──────────────────────────────────────────────────
car = calculate_car_emissions(150, 'petrol', 'supermini')
print(f'Car: {car:.1f} kg CO2e/year')


# ── ABROAD HOLIDAY ──────────────────────────────────────────────────
#list has everything the user will input about each trip
flights = [
    {'country': 'Romania', 'seat': 'economy', 'passengers': 2, 
     'nights': 5, 'accommodation': 'hotel'},
    {'country': 'Thailand', 'seat': 'business', 'passengers': 1, 
     'nights': 10, 'accommodation': 'airbnb'},
]

#finding the flight emissions from that trip
result = calculate_flight_emissions(flights)
print(f'Flights: {result:.1f} kg CO2e/year')

#finding the hotel emissions
accom_result = calculate_abroad_accomodation_emissions(flights)
print(f'Abroad Stays: {accom_result:.1f} kg CO2e/year')

# ── UK HOLIDAY ──────────────────────────────────────────────────
trip = [
    {'people': 2, 'nights': 5, 'type': 'hotel'},
    {'people': 7, 'nights': 2, 'type': 'airbnb'},
]

accomodation = calculate_uk_accomodation_emissions(trip)
print(f'UK Stays: {accomodation:.1f} kg CO2e/year')
"



python3 -c "
#importing all the functions from consumption
from calculators.consumption import (
    calculate_pet_food_emissions,
    calculate_red_meat_emissions,
    calculate_white_meat_emissions,
    calculate_food_emissions,
    calculate_food_waste_emissions,
    calculate_household_waste_emissions,
    calculate_takeaway_emissions,
    calculate_drink_emissions,
    calculate_alcohol_emissions,
    calculate_tobacco_emissions,
    calculate_clothes_emissions,
    calculate_soap_emissions,
    calculate_medicine_emissions,
    calculate_electronics_emissions,
    calculate_machinery_emissions,
    calculate_education_emissions,
    calculate_healthcare_emissions,
    calculate_care_home_emissions,
    calculate_furniture_emissions,
    calculate_services_emissions,

)

# ── PETS ───────────────────────────────────────────────────────────
#list has everything the user will input about each pet
pets = [
    {'type': 'dog', 'food': 'wet', 'brand': 'premium', 
     'diet': 'vegan', 'weight': 500},
    {'type': 'cat', 'food': 'dry', 'brand': 'standard', 
     'diet': 'meaty', 'weight': 100},
]

result = calculate_pet_food_emissions(pets)
print(f'Pets: {result:.1f} kg CO2e/year')

# ── RED MEAT ───────────────────────────────────────────────────────────
red_meat = calculate_red_meat_emissions(1, 4)
print(f'Red Meat: {red_meat:.1f} kg CO2e/year')

# ── WHITE MEAT ───────────────────────────────────────────────────────────
white_meat = calculate_white_meat_emissions(3, 4)
print(f'White Meat: {white_meat:.1f} kg CO2e/year')

# ── OTHER FOOD ───────────────────────────────────────────────────────────
food_emissions = calculate_food_emissions(60)
print(f'Food: {food_emissions:.1f} kg CO2e/year')

# ── FOOD WASTE ───────────────────────────────────────────────────────────
food_waste_emissions = calculate_food_waste_emissions('compost', 4)
print(f'Food Waste: {food_waste_emissions:.1f} kg CO2e/year')

# ── HOUSEHOLD WASTE ───────────────────────────────────────────────────────────
household_waste_emissions = calculate_household_waste_emissions('recycle', 4)
print(f'Household Waste: {household_waste_emissions:.1f} kg CO2e/year')

# ── SPENDING ───────────────────────────────────────────────────────────
takeaway_emissions = calculate_takeaway_emissions(25)
print(f'Takeaway: {takeaway_emissions:.1f} kg CO2e/year')

drink_emissions = calculate_drink_emissions(30)
print(f'Soft drinks: {drink_emissions:.1f} kg CO2e/year')

alcohol_emissions = calculate_alcohol_emissions(15)
print(f'Alcohol: {alcohol_emissions:.1f} kg CO2e/year')

tobacco_emissions = calculate_tobacco_emissions(0)
print(f'Tobacco: {tobacco_emissions:.1f} kg CO2e/year')

clothes_emissions = calculate_clothes_emissions(50)
print(f'Clothes: {clothes_emissions:.1f} kg CO2e/year')

soap_emissions = calculate_soap_emissions(10)
print(f'Soaps and detergents: {soap_emissions:.1f} kg CO2e/year')

medicine_emissions = calculate_medicine_emissions(20)
print(f'Medicine: {medicine_emissions:.1f} kg CO2e/year')

electronics_emissions = calculate_electronics_emissions(150)
print(f'Electronics: {electronics_emissions:.1f} kg CO2e/year')

machinery_emissions = calculate_machinery_emissions(90)
print(f'Machinery: {machinery_emissions:.1f} kg CO2e/year')

education_emissions = calculate_education_emissions(1250)
print(f'Education: {education_emissions:.1f} kg CO2e/year')

healthcare_emissions = calculate_healthcare_emissions(75)
print(f'Healthcare: {healthcare_emissions:.1f} kg CO2e/year')

care_home_emissions = calculate_care_home_emissions(625)
print(f'Care homes: {care_home_emissions:.1f} kg CO2e/year')

furniture_emissions = calculate_furniture_emissions(100)
print(f'Furniture: {furniture_emissions:.1f} kg CO2e/year')

services_emissions = calculate_services_emissions(25)
print(f'Other services: {services_emissions:.1f} kg CO2e/year')
"


class _TransportScreenState extends State<TransportScreen> {
  final _mileageController = TextEditingController();
  final _busController = TextEditingController();
  final _trainController = TextEditingController();
  String _fuelType = 'petrol';
  String _carSize = 'supermini';