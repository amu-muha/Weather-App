class LocationModel {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1;

  const LocationModel({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  /// Default fallback location: Addis Ababa, Ethiopia
  static const LocationModel defaultLocation = LocationModel(
    name: 'Addis Ababa',
    country: 'Ethiopia',
    latitude: 8.9806,
    longitude: 38.7578,
    admin1: 'Addis Ababa',
  );

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return country.isNotEmpty ? '$name, $country' : name;
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: json['name'] as String? ?? 'Unknown Location',
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'admin1': admin1,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => name.hashCode ^ latitude.hashCode ^ longitude.hashCode;
}
