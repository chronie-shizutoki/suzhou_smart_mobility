import 'bus_predict.dart';

class BusRoute {
  final String routeId;
  final String routeName;
  final String? startStation;
  final String? endStation;
  final String? segmentId;
  final List<BusPredict>? busPredictList;
  final String? startTime;
  final String? endTime;
  final bool? hasTimeTable;
  final int? nearbyForecastStation;
  final int? nearbyForecastDistance;
  final int? predictArriveTime;
  final int? nearbyForecastStation2;
  final int? nearbyForecastDistance2;
  final int? predictArriveTime2;
  final String? leaveTime;
  final String? multiplyLineSign;

  BusRoute({
    required this.routeId,
    required this.routeName,
    this.startStation,
    this.endStation,
    this.segmentId,
    this.busPredictList,
    this.startTime,
    this.endTime,
    this.hasTimeTable,
    this.nearbyForecastStation,
    this.nearbyForecastDistance,
    this.predictArriveTime,
    this.nearbyForecastStation2,
    this.nearbyForecastDistance2,
    this.predictArriveTime2,
    this.leaveTime,
    this.multiplyLineSign,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    List<BusPredict>? predictList;
    if (json['busPredictList'] != null) {
      predictList = (json['busPredictList'] as List)
          .map((e) => BusPredict.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    bool? parseHasTimeTable(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
      }
      return null;
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      return null;
    }

    return BusRoute(
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName']?.toString() ?? '',
      startStation: json['startStation']?.toString(),
      endStation: json['endStation']?.toString(),
      segmentId: json['segmentId']?.toString(),
      busPredictList: predictList,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      hasTimeTable: parseHasTimeTable(json['hasTimeTable']),
      nearbyForecastStation: parseInt(json['nearbyForecastStation']),
      nearbyForecastDistance: parseInt(json['nearbyForecastDistance']),
      predictArriveTime: parseInt(json['predictArriveTime']),
      nearbyForecastStation2: parseInt(json['nearbyForecastStation2']),
      nearbyForecastDistance2: parseInt(json['nearbyForecastDistance2']),
      predictArriveTime2: parseInt(json['predictArriveTime2']),
      leaveTime: json['leaveTime']?.toString(),
      multiplyLineSign: json['multiplyLineSign']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'startStation': startStation,
      'endStation': endStation,
      'segmentId': segmentId,
      'busPredictList': busPredictList?.map((e) => e.toJson()).toList(),
      'startTime': startTime,
      'endTime': endTime,
      'hasTimeTable': hasTimeTable,
      'nearbyForecastStation': nearbyForecastStation,
      'nearbyForecastDistance': nearbyForecastDistance,
      'predictArriveTime': predictArriveTime,
      'nearbyForecastStation2': nearbyForecastStation2,
      'nearbyForecastDistance2': nearbyForecastDistance2,
      'predictArriveTime2': predictArriveTime2,
      'leaveTime': leaveTime,
      'multiplyLineSign': multiplyLineSign,
    };
  }
}
