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

class BusInfo {
  final String busName;
  final String busNo;
  final int? crowdInCar;
  final String arriveTime;
  final String arriveStationId;
  final int? arriveStationNo;
  final double? latitude;
  final double? longitude;

  BusInfo({
    required this.busName,
    required this.busNo,
    this.crowdInCar,
    required this.arriveTime,
    required this.arriveStationId,
    this.arriveStationNo,
    this.latitude,
    this.longitude,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      busName: json['busName']?.toString() ?? '',
      busNo: json['busNo']?.toString() ?? '',
      crowdInCar: json['crowdInCar'] is int ? json['crowdInCar'] : int.tryParse(json['crowdInCar']?.toString() ?? ''),
      arriveTime: json['arriveTime']?.toString() ?? '',
      arriveStationId: json['arriveStationId']?.toString() ?? '',
      arriveStationNo: json['arriveStationNo'] is int ? json['arriveStationNo'] : int.tryParse(json['arriveStationNo']?.toString() ?? ''),
      latitude: json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busName': busName,
      'busNo': busNo,
      'crowdInCar': crowdInCar,
      'arriveTime': arriveTime,
      'arriveStationId': arriveStationId,
      'arriveStationNo': arriveStationNo,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class MetroTransfer {
  final String metroName;
  final String? metroColor;

  MetroTransfer({
    required this.metroName,
    this.metroColor,
  });

  factory MetroTransfer.fromJson(Map<String, dynamic> json) {
    return MetroTransfer(
      metroName: json['metroName']?.toString() ?? '',
      metroColor: json['metroColor']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metroName': metroName,
      'metroColor': metroColor,
    };
  }
}

class Station {
  final String stationId;
  final String stationName;
  final int stationSort;
  final double latitude;
  final double longitude;
  final bool? isNearby;
  final List<BusInfo>? buslist;
  final List<MetroTransfer>? metroTransferList;
  final bool? stationBool;
  final int? crowdInCar;
  final String? arriveTime;
  final String? busName;
  final String? busNo;
  final bool? textbool;
  final bool? localTrain;
  final bool? commonIcon;
  final String? stationRoad;

  Station({
    required this.stationId,
    required this.stationName,
    required this.stationSort,
    required this.latitude,
    required this.longitude,
    this.isNearby,
    this.buslist,
    this.metroTransferList,
    this.stationBool,
    this.crowdInCar,
    this.arriveTime,
    this.busName,
    this.busNo,
    this.textbool,
    this.localTrain,
    this.commonIcon,
    this.stationRoad,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    List<BusInfo>? busList;
    if (json['buslist'] != null) {
      busList = (json['buslist'] as List)
          .map((e) => BusInfo.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<MetroTransfer>? metroList;
    if (json['metroTransferList'] != null) {
      metroList = (json['metroTransferList'] as List)
          .map((e) => MetroTransfer.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Station(
      stationId: json['stationId']?.toString() ?? '',
      stationName: json['stationName']?.toString() ?? '',
      stationSort: json['stationSort'] is int ? json['stationSort'] : int.tryParse(json['stationSort']?.toString() ?? '0') ?? 0,
      latitude: json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      isNearby: json['isNearby'] is bool ? json['isNearby'] : (json['isNearby'] == 1),
      buslist: busList,
      metroTransferList: metroList,
      stationBool: json['bool'] is bool ? json['bool'] : (json['bool'] == 1),
      crowdInCar: json['crowdInCar'] is int ? json['crowdInCar'] : int.tryParse(json['crowdInCar']?.toString() ?? ''),
      arriveTime: json['arriveTime']?.toString(),
      busName: json['busName']?.toString(),
      busNo: json['busNo']?.toString(),
      textbool: json['textbool'] is bool ? json['textbool'] : (json['textbool'] == 1),
      localTrain: json['localTrain'] is bool ? json['localTrain'] : (json['localTrain'] == 1),
      commonIcon: json['commonIcon'] is bool ? json['commonIcon'] : (json['commonIcon'] == 1),
      stationRoad: json['stationRoad']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationId': stationId,
      'stationName': stationName,
      'stationSort': stationSort,
      'latitude': latitude,
      'longitude': longitude,
      'isNearby': isNearby,
      'buslist': buslist?.map((e) => e.toJson()).toList(),
      'metroTransferList': metroTransferList?.map((e) => e.toJson()).toList(),
      'bool': stationBool,
      'crowdInCar': crowdInCar,
      'arriveTime': arriveTime,
      'busName': busName,
      'busNo': busNo,
      'textbool': textbool,
      'localTrain': localTrain,
      'commonIcon': commonIcon,
      'stationRoad': stationRoad,
    };
  }
}

class RouteDetail {
  final String routeId;
  final String routeName;
  final String segmentId;
  final String startStation;
  final String endStation;
  final String? startTime;
  final String? endTime;
  final String? ticketPrice;
  final String? ticketRule;
  final List<Station>? stations;
  final bool? isShowTimetable;
  final int? highInterval;
  final int? plainInterval;
  final int? lowInterval;
  final String? timeExtendInfo;
  final bool? flog;
  final String? featureLineSign;
  final String? multiplyLineSign;
  final List<dynamic>? linepath;

  RouteDetail({
    required this.routeId,
    required this.routeName,
    required this.segmentId,
    required this.startStation,
    required this.endStation,
    this.startTime,
    this.endTime,
    this.ticketPrice,
    this.ticketRule,
    this.stations,
    this.isShowTimetable,
    this.highInterval,
    this.plainInterval,
    this.lowInterval,
    this.timeExtendInfo,
    this.flog,
    this.featureLineSign,
    this.multiplyLineSign,
    this.linepath,
  });

  factory RouteDetail.fromJson(Map<String, dynamic> json) {
    List<Station>? stationList;
    if (json['stations'] != null) {
      stationList = (json['stations'] as List)
          .map((e) => Station.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RouteDetail(
      routeId: json['routeId']?.toString() ?? '',
      routeName: json['routeName']?.toString() ?? '',
      segmentId: json['segmentId']?.toString() ?? '',
      startStation: json['startStation']?.toString() ?? '',
      endStation: json['endStation']?.toString() ?? '',
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      ticketPrice: json['ticketPrice']?.toString(),
      ticketRule: json['ticketRule']?.toString(),
      stations: stationList,
      isShowTimetable: json['isShowTimetable'] is bool ? json['isShowTimetable'] : (json['isShowTimetable'] == 1),
      highInterval: json['highInterval'] is int ? json['highInterval'] : int.tryParse(json['highInterval']?.toString() ?? ''),
      plainInterval: json['plainInterval'] is int ? json['plainInterval'] : int.tryParse(json['plainInterval']?.toString() ?? ''),
      lowInterval: json['lowInterval'] is int ? json['lowInterval'] : int.tryParse(json['lowInterval']?.toString() ?? ''),
      timeExtendInfo: json['timeExtendInfo']?.toString(),
      flog: json['flog'] is bool ? json['flog'] : (json['flog'] == 1),
      featureLineSign: json['featureLineSign']?.toString(),
      multiplyLineSign: json['multiplyLineSign']?.toString(),
      linepath: json['linepath'] as List?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'routeId': routeId,
      'routeName': routeName,
      'segmentId': segmentId,
      'startStation': startStation,
      'endStation': endStation,
      'startTime': startTime,
      'endTime': endTime,
      'ticketPrice': ticketPrice,
      'ticketRule': ticketRule,
      'stations': stations?.map((e) => e.toJson()).toList(),
      'isShowTimetable': isShowTimetable,
      'highInterval': highInterval,
      'plainInterval': plainInterval,
      'lowInterval': lowInterval,
      'timeExtendInfo': timeExtendInfo,
      'flog': flog,
      'featureLineSign': featureLineSign,
      'multiplyLineSign': multiplyLineSign,
      'linepath': linepath,
    };
  }
}

class Timetable {
  final List<String>? timetable;
  final String? startStation;
  final String? endStation;
  final bool? isShowTimetable;
  final int? highInterval;
  final int? plainInterval;
  final int? lowInterval;
  final String? timeExtendInfo;

  Timetable({
    this.timetable,
    this.startStation,
    this.endStation,
    this.isShowTimetable,
    this.highInterval,
    this.plainInterval,
    this.lowInterval,
    this.timeExtendInfo,
  });

  factory Timetable.fromJson(Map<String, dynamic> json) {
    List<String>? timeList;
    if (json['timetable'] != null) {
      timeList = (json['timetable'] as List).map((e) => e.toString()).toList();
    }

    return Timetable(
      timetable: timeList,
      startStation: json['startStation']?.toString(),
      endStation: json['endStation']?.toString(),
      isShowTimetable: json['isShowTimetable'] is bool ? json['isShowTimetable'] : (json['isShowTimetable'] == 1),
      highInterval: json['highInterval'] is int ? json['highInterval'] : int.tryParse(json['highInterval']?.toString() ?? ''),
      plainInterval: json['plainInterval'] is int ? json['plainInterval'] : int.tryParse(json['plainInterval']?.toString() ?? ''),
      lowInterval: json['lowInterval'] is int ? json['lowInterval'] : int.tryParse(json['lowInterval']?.toString() ?? ''),
      timeExtendInfo: json['timeExtendInfo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timetable': timetable,
      'startStation': startStation,
      'endStation': endStation,
      'isShowTimetable': isShowTimetable,
      'highInterval': highInterval,
      'plainInterval': plainInterval,
      'lowInterval': lowInterval,
      'timeExtendInfo': timeExtendInfo,
    };
  }
}

class ForecastInfo {
  final String busName;
  final int nearbyForecastStation;
  final int nearbyForecastDistance;
  final int predictArriveTime;
  final String? leaveTime;

  ForecastInfo({
    required this.busName,
    required this.nearbyForecastStation,
    required this.nearbyForecastDistance,
    required this.predictArriveTime,
    this.leaveTime,
  });

  factory ForecastInfo.fromJson(Map<String, dynamic> json) {
    return ForecastInfo(
      busName: json['busName']?.toString() ?? '',
      nearbyForecastStation: json['nearbyForecastStation'] is int ? json['nearbyForecastStation'] : int.tryParse(json['nearbyForecastStation']?.toString() ?? '0') ?? 0,
      nearbyForecastDistance: json['nearbyForecastDistance'] is int ? json['nearbyForecastDistance'] : int.tryParse(json['nearbyForecastDistance']?.toString() ?? '0') ?? 0,
      predictArriveTime: json['predictArriveTime'] is int ? json['predictArriveTime'] : int.tryParse(json['predictArriveTime']?.toString() ?? '0') ?? 0,
      leaveTime: json['leaveTime']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'busName': busName,
      'nearbyForecastStation': nearbyForecastStation,
      'nearbyForecastDistance': nearbyForecastDistance,
      'predictArriveTime': predictArriveTime,
      'leaveTime': leaveTime,
    };
  }
}
