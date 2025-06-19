class DailyEntry {
  final String photoPath;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  DailyEntry({
    required this.photoPath,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'photoPath': photoPath,
      'location_name': locationName,
      'lat': latitude,
      'lng': longitude,
    };
  }

  factory DailyEntry.fromMap(Map<String, dynamic> map) {
    return DailyEntry(
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      photoPath: map['photoPath'] as String,
      locationName: map['location_name'] as String,
      latitude: (map['lat'] as num).toDouble(),
      longitude: (map['lng'] as num).toDouble(),
    );
  }
}
