class DailyEntry {
  final String date; // YYYY-MM-DD format
  final String photoPath; // Local filesystem path
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  DailyEntry({
    required this.date,
    required this.photoPath,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'photoPath': photoPath,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DailyEntry.fromJson(Map<String, dynamic> json) {
    return DailyEntry(
      date: json['date'],
      photoPath: json['photoPath'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  static String formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  static String getTodayKey() {
    return formatDate(DateTime.now());
  }

  bool isValid() {
    return date.isNotEmpty &&
        photoPath.isNotEmpty &&
        latitude.abs() <= 90 &&
        longitude.abs() <= 180;
  }

  @override
  String toString() {
    return 'DailyEntry(date: $date, photoPath: $photoPath, lat: $latitude, lng: $longitude, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyEntry &&
        other.date == date &&
        other.photoPath == photoPath &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return date.hashCode ^
        photoPath.hashCode ^
        latitude.hashCode ^
        longitude.hashCode ^
        timestamp.hashCode;
  }
}
