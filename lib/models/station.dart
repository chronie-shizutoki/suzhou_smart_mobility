class Station {
  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final double? distance;
  final String? roadName;
  final String? direction;
  final String? stationRoad;
  final String? stationDirect;

  Station({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    this.distance,
    this.roadName,
    this.direction,
    this.stationRoad,
    this.stationDirect,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
      return 0.0;
    }

    return Station(
      stationId: json['stationId']?.toString() ?? '',
      stationName: json['stationName']?.toString() ?? '',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      distance: json['distance'] != null ? parseDouble(json['distance']) : null,
      roadName: json['roadName']?.toString(),
      direction: json['direction']?.toString(),
      stationRoad: json['stationRoad']?.toString(),
      stationDirect: json['stationDirect']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationId': stationId,
      'stationName': stationName,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'roadName': roadName,
      'direction': direction,
      'stationRoad': stationRoad,
      'stationDirect': stationDirect,
    };
  }
}
