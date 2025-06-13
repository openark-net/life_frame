class Settings {
  final bool notificationsEnabled;

  const Settings({this.notificationsEnabled = true});

  Settings copyWith({bool? notificationsEnabled}) {
    return Settings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {'notificationsEnabled': notificationsEnabled};
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(notificationsEnabled: json['notificationsEnabled'] ?? true);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settings &&
        other.notificationsEnabled == notificationsEnabled;
  }

  @override
  int get hashCode => notificationsEnabled.hashCode;
}
