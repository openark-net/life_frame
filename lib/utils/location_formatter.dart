import 'package:geocoding/geocoding.dart';

/// Converts latitude and longitude coordinates to a formatted location string.
/// Returns a string in the format "City, Province/State" or fallback values if unavailable.
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
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    
    if (placemarks.isEmpty) {
      return 'Unknown Location';
    }
    
    final placemark = placemarks.first;
    
    // Extract city (locality) and province/state (administrativeArea)
    final city = placemark.locality ?? '';
    final province = placemark.administrativeArea ?? '';
    
    // Format the location string based on available data
    if (city.isNotEmpty && province.isNotEmpty) {
      return '$city, $province';
    } else if (city.isNotEmpty) {
      return '$city, Unknown';
    } else if (province.isNotEmpty) {
      return 'Unknown, $province';
    } else {
      return 'Unknown Location';
    }
  } catch (e) {
    print('Error getting formatted location: $e');
    return 'Unknown Location';
  }
}