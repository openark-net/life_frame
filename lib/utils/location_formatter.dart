import 'package:geocoding/geocoding.dart';

/// Converts latitude and longitude coordinates to a formatted location string.
/// Returns a string in the format "City, Province/State" using short province codes.
///
/// Example: getFormattedLocation(49.2827, -123.1207) returns "Vancouver, BC"
///
/// Parameters:
/// - [latitude]: The latitude coordinate (required)
/// - [longitude]: The longitude coordinate (required)
///
/// Returns:
/// - A formatted string like "City, Province" on success
/// - "Unknown Location" if geocoding fails
/// - "City, Unknown" if only city is available
/// - "Unknown, Province" if only province is available
Future<String> getFormattedLocation(double latitude, double longitude) async {
  try {
    // Perform reverse geocoding to get address information
    List<Placemark> placemarks = await placemarkFromCoordinates(
      latitude,
      longitude,
    );

    if (placemarks.isEmpty) {
      return 'Unknown Location';
    }

    final placemark = placemarks.first;

    // Extract city (locality) and province/state (administrativeArea)
    final city = placemark.locality ?? '';
    final province = placemark.administrativeArea ?? '';

    // Convert province to short name
    final shortProvince = _getShortProvinceName(province);

    // Format the location string based on available data
    if (city.isNotEmpty && shortProvince.isNotEmpty) {
      return '$city, $shortProvince';
    } else if (city.isNotEmpty) {
      return '$city, Unknown';
    } else if (shortProvince.isNotEmpty) {
      return 'Unknown, $shortProvince';
    } else {
      return 'Unknown Location';
    }
  } catch (e) {
    print('Error getting formatted location: $e');
    return 'Unknown Location';
  }
}

/// Converts full province/state names to their short form abbreviations.
///
/// Parameters:
/// - [fullName]: The full province or state name
///
/// Returns:
/// - The short form abbreviation if found
/// - The original name if no mapping exists
/// - Empty string if input is null or empty
String _getShortProvinceName(String fullName) {
  if (fullName.isEmpty) return '';

  // Map of full province/state names to their abbreviations
  const provinceMap = <String, String>{
    // Canadian Provinces and Territories
    'Alberta': 'AB',
    'British Columbia': 'BC',
    'Manitoba': 'MB',
    'New Brunswick': 'NB',
    'Newfoundland and Labrador': 'NL',
    'Northwest Territories': 'NT',
    'Nova Scotia': 'NS',
    'Nunavut': 'NU',
    'Ontario': 'ON',
    'Prince Edward Island': 'PE',
    'Quebec': 'QC',
    'Saskatchewan': 'SK',
    'Yukon': 'YT',

    // US States (commonly encountered)
    'Alabama': 'AL',
    'Alaska': 'AK',
    'Arizona': 'AZ',
    'Arkansas': 'AR',
    'California': 'CA',
    'Colorado': 'CO',
    'Connecticut': 'CT',
    'Delaware': 'DE',
    'Florida': 'FL',
    'Georgia': 'GA',
    'Hawaii': 'HI',
    'Idaho': 'ID',
    'Illinois': 'IL',
    'Indiana': 'IN',
    'Iowa': 'IA',
    'Kansas': 'KS',
    'Kentucky': 'KY',
    'Louisiana': 'LA',
    'Maine': 'ME',
    'Maryland': 'MD',
    'Massachusetts': 'MA',
    'Michigan': 'MI',
    'Minnesota': 'MN',
    'Mississippi': 'MS',
    'Missouri': 'MO',
    'Montana': 'MT',
    'Nebraska': 'NE',
    'Nevada': 'NV',
    'New Hampshire': 'NH',
    'New Jersey': 'NJ',
    'New Mexico': 'NM',
    'New York': 'NY',
    'North Carolina': 'NC',
    'North Dakota': 'ND',
    'Ohio': 'OH',
    'Oklahoma': 'OK',
    'Oregon': 'OR',
    'Pennsylvania': 'PA',
    'Rhode Island': 'RI',
    'South Carolina': 'SC',
    'South Dakota': 'SD',
    'Tennessee': 'TN',
    'Texas': 'TX',
    'Utah': 'UT',
    'Vermont': 'VT',
    'Virginia': 'VA',
    'Washington': 'WA',
    'West Virginia': 'WV',
    'Wisconsin': 'WI',
    'Wyoming': 'WY',
    'District of Columbia': 'DC',
  };

  // Try exact match first
  if (provinceMap.containsKey(fullName)) {
    return provinceMap[fullName]!;
  }

  // Try case-insensitive match
  final lowerFullName = fullName.toLowerCase();
  for (final entry in provinceMap.entries) {
    if (entry.key.toLowerCase() == lowerFullName) {
      return entry.value;
    }
  }

  // If no mapping found, return the original name
  // This handles cases where the geocoding service already returns short names
  // or for regions not in our mapping
  return fullName;
}
