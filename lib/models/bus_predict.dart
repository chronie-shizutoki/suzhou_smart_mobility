class BusPredict {
  final String busName;
  final String predictTime;
  final String distance;

  BusPredict({
    required this.busName,
    required this.predictTime,
    required this.distance,
  });

  factory BusPredict.fromJson(Map<String, dynamic> json) {
    return BusPredict(
      busName: json['busName']?.toString() ?? '',
      predictTime: json['predictTime']?.toString() ?? '',
      distance: json['distance']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busName': busName,
      'predictTime': predictTime,
      'distance': distance,
    };
  }
}
