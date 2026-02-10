import 'station.dart';

class Segment {
  final String segmentId;
  final String startStation;
  final String endStation;
  final List<Station>? stations;

  Segment({
    required this.segmentId,
    required this.startStation,
    required this.endStation,
    this.stations,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    List<Station>? stationList;
    if (json['stations'] != null) {
      stationList = (json['stations'] as List)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Segment(
      segmentId: json['segmentId'] as String,
      startStation: json['startStation'] as String,
      endStation: json['endStation'] as String,
      stations: stationList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'segmentId': segmentId,
      'startStation': startStation,
      'endStation': endStation,
      'stations': stations?.map((e) => e.toJson()).toList(),
    };
  }
}
