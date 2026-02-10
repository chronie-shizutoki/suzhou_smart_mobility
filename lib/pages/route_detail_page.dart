import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/suzhi_bus_api.dart';
import '../models/bus_predict.dart';
import '../theme/glass_theme.dart';
import 'station_detail_page.dart';

class RouteDetailPage extends StatefulWidget {
  final String segmentId;
  final String routeId;
  final String routeName;

  const RouteDetailPage({
    super.key,
    required this.segmentId,
    required this.routeId,
    required this.routeName,
  });

  @override
  State<RouteDetailPage> createState() => _RouteDetailPageState();
}

class _RouteDetailPageState extends State<RouteDetailPage> {
  RouteDetail? _routeDetail;
  Timetable? _timetable;
  List<Station> _stations = [];
  List<BusInfo> _busInfoList = [];
  List<ForecastInfo> _forecastList = [];
  List<RouteDetail> _allRoutes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isShowReverse = true;
  String _currentStationId = '';
  String _departureTime = '';
  bool _closeOperate = false;
  Timer? _refreshTimer;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  bool _hasTimeTable = true;

  @override
  void initState() {
    super.initState();
    _loadRouteData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadRouteData(isAutoRefresh: true);
    });
  }

  Future<void> _loadRouteData({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final routeDataResult = await SuZhiBusAPI.getRouteStationData(widget.routeId);
      final busDataResult = await SuZhiBusAPI.getBusBySegmentId(widget.segmentId);

      if (routeDataResult['status'] == true) {
        final items = routeDataResult['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final routeItems = items.map((e) => RouteDetail.fromJson(e as Map<String, dynamic>)).toList();
          
          final currentRoute = routeItems.firstWhere(
            (r) => r.segmentId == widget.segmentId,
            orElse: () => routeItems.first,
          );

          setState(() {
            _allRoutes = routeItems;
            _routeDetail = currentRoute;
            _isShowReverse = routeItems.length > 1;
            _hasTimeTable = currentRoute.isShowTimetable ?? true;
            _stations = currentRoute.stations ?? [];
            
            final nearbyStation = _stations.firstWhere(
              (s) => s.isNearby == true,
              orElse: () => _stations.first,
            );
            _currentStationId = nearbyStation.stationId;
          });

          if (_currentStationId.isNotEmpty) {
            await _loadForecastData();
          }
        }
      }

      if (busDataResult['status'] == true) {
        final busItems = busDataResult['items'] as List?;
        if (busItems != null) {
          setState(() {
            _busInfoList = busItems.map((e) => BusInfo.fromJson(e as Map<String, dynamic>)).toList();
          });
          _updateStationsWithBusInfo();
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (!isAutoRefresh) {
        _scrollToCurrentStation();
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadForecastData() async {
    try {
      final requestId = SuZhiBusAPI.generateRequestId();
      final forecastResult = await SuZhiBusAPI.queryByStationId(
        _currentStationId,
        requestId,
        segmentId: widget.segmentId,
      );

      if (forecastResult['status'] == true) {
        final items = forecastResult['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final item = items.first as Map<String, dynamic>;
          setState(() {
            _forecastList = (item['busPredictList'] as List?)
                    ?.map((e) => ForecastInfo.fromJson(e as Map<String, dynamic>))
                    .toList() ??
                [];
            _departureTime = item['leaveTime']?.toString() ?? '';
            _closeOperate = item['closeOperate'] == true;
          });
        }
      }
    } catch (e) {
    }
  }

  Future<void> _loadTimetable() async {
    try {
      final timetableResult = await SuZhiBusAPI.getTimetable(widget.segmentId);
      if (timetableResult['status'] == true) {
        final items = timetableResult['items'] as Map<String, dynamic>?;
        if (items != null) {
          setState(() {
            _timetable = Timetable.fromJson(items);
          });
        }
      }
    } catch (e) {
    }
  }

  void _updateStationsWithBusInfo() {
    final updatedStations = _stations.map((station) {
      final busList = _busInfoList
          .where((bus) => bus.arriveStationId == station.stationId)
          .toList();
      
      return Station(
        stationId: station.stationId,
        stationName: station.stationName,
        stationSort: station.stationSort,
        latitude: station.latitude,
        longitude: station.longitude,
        isNearby: station.isNearby,
        buslist: busList.isNotEmpty ? busList : null,
        metroTransferList: station.metroTransferList,
        stationBool: busList.isNotEmpty,
        crowdInCar: busList.isNotEmpty ? busList.first.crowdInCar : null,
        arriveTime: busList.isNotEmpty ? busList.first.arriveTime : null,
        busName: busList.isNotEmpty ? busList.first.busName : null,
        busNo: busList.isNotEmpty ? busList.first.busNo : null,
        textbool: station.stationId == _currentStationId,
        localTrain: station.localTrain,
        commonIcon: station.commonIcon,
      );
    }).toList();

    setState(() {
      _stations = updatedStations;
    });
  }

  void _scrollToCurrentStation() {
    final index = _stations.indexWhere((s) => s.stationId == _currentStationId);
    if (index >= 0 && _scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          index * 80.0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadRouteData();
    setState(() {
      _isRefreshing = false;
    });
  }

  void _onStationTap(Station station) {
    setState(() {
      _currentStationId = station.stationId;
      _stations = _stations.map((s) {
        return Station(
          stationId: s.stationId,
          stationName: s.stationName,
          stationSort: s.stationSort,
          latitude: s.latitude,
          longitude: s.longitude,
          isNearby: s.isNearby,
          buslist: s.buslist,
          metroTransferList: s.metroTransferList,
          stationBool: s.stationBool,
          crowdInCar: s.crowdInCar,
          arriveTime: s.arriveTime,
          busName: s.busName,
          busNo: s.busNo,
          textbool: s.stationId == station.stationId,
          localTrain: s.localTrain,
          commonIcon: s.commonIcon,
        );
      }).toList();
    });
    _loadForecastData();
  }

  void _onStationLongPress(Station station) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailPage(
          stationId: station.stationId,
          stationName: station.stationName,
          latitude: station.latitude,
          longitude: station.longitude,
        ),
      ),
    );
  }

  void _onReverseRoute() {
    if (_allRoutes.length < 2) return;
    
    final currentIndex = _allRoutes.indexWhere((r) => r.segmentId == widget.segmentId);
    final nextIndex = (currentIndex + 1) % _allRoutes.length;
    final nextRoute = _allRoutes[nextIndex];
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RouteDetailPage(
          segmentId: nextRoute.segmentId,
          routeId: nextRoute.routeId,
          routeName: nextRoute.routeName,
        ),
      ),
    );
  }

  void _showTimetableBottomSheet() async {
    await _loadTimetable();
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTimetableBottomSheet(context),
    );
  }

  Widget _buildTimetableBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                  const Color(0xFF0F0F1A).withValues(alpha: 0.95),
                ]
              : [
                  const Color(0xFFE8EEF5).withValues(alpha: 0.95),
                  const Color(0xFFF0F4F8).withValues(alpha: 0.95),
                ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_routeDetail?.routeName} ${localizations.timetable}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_timetable != null) ...[
            if (_timetable!.highInterval != null ||
                _timetable!.plainInterval != null ||
                _timetable!.lowInterval != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (_timetable!.highInterval != null)
                      _buildIntervalChip(
                        context,
                        '${localizations.highPeak}: ${_timetable!.highInterval}${localizations.minutes}',
                        Colors.red,
                      ),
                    if (_timetable!.plainInterval != null)
                      _buildIntervalChip(
                        context,
                        '${localizations.plainPeak}: ${_timetable!.plainInterval}${localizations.minutes}',
                        Colors.orange,
                      ),
                    if (_timetable!.lowInterval != null)
                      _buildIntervalChip(
                        context,
                        '${localizations.lowPeak}: ${_timetable!.lowInterval}${localizations.minutes}',
                        Colors.green,
                      ),
                  ],
                ),
              ),
            if (_timetable!.timeExtendInfo != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  _timetable!.timeExtendInfo!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            Container(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shrinkWrap: true,
                itemCount: _timetable!.timetable?.length ?? 0,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _timetable!.timetable![index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ] else
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    localizations.noData,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getForecastStatus(ForecastInfo forecast) {
    if (forecast.nearbyForecastStation == -1 && _departureTime == '0') {
      return localizations.waitingForDeparture;
    } else if (forecast.nearbyForecastStation == -1 && _departureTime != '0') {
      return '$_departureTime ${localizations.nextDeparture}';
    } else if (forecast.nearbyForecastStation == 0 &&
        forecast.nearbyForecastDistance == 0 &&
        forecast.predictArriveTime == 0) {
      return localizations.busAtStation;
    } else if (forecast.nearbyForecastStation == 0) {
      return localizations.arrivingSoon;
    } else {
      final time = forecast.predictArriveTime <= 0 ? 1 : forecast.predictArriveTime;
      final timeText = forecast.predictArriveTime <= 0 ? localizations.withinMinutes : localizations.minutes;
      return '$time $timeText';
    }
  }

  AppLocalizations get localizations => AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0F0F1A),
                        const Color(0xFF1A1A2E),
                        const Color(0xFF16213E),
                      ]
                    : [
                        const Color(0xFFF0F4F8),
                        const Color(0xFFE8EEF5),
                        const Color(0xFFD9E2EC),
                      ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  Expanded(
                    child: _isLoading
                        ? _buildLoading(context)
                        : _errorMessage.isNotEmpty
                            ? _buildError(context)
                            : _buildContent(context, isDark),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.routeName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  localizations.routeDetail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.loading),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    if (_routeDetail == null) {
      return Center(
        child: Text(localizations.noData),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                _buildRouteInfo(context, isDark),
                _buildStationsList(context, isDark),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildForecastSection(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(BuildContext context, bool isDark) {
    final route = _routeDetail!;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          route.routeName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton.icon(
                            onPressed: _showTimetableBottomSheet,
                            icon: const Icon(Icons.schedule, size: 20),
                            label: Text(localizations.timetable),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${localizations.runDirection}: ${route.endStation}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (_isShowReverse)
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _onReverseRoute,
                  tooltip: localizations.reverse,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(
                context,
                '${localizations.firstBus} ${route.startTime ?? localizations.notAvailable}',
                Icons.access_time,
              ),
              const SizedBox(width: 8),
              _buildInfoChip(
                context,
                '${localizations.lastBus} ${route.endTime ?? localizations.notAvailable}',
                Icons.nights_stay,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (route.ticketRule == '1' && route.ticketPrice != null)
                _buildInfoChip(
                  context,
                  '${localizations.ticketPrice}: ${route.ticketPrice}${localizations.yuan}',
                  Icons.confirmation_number,
                )
              else
                _buildInfoChip(
                  context,
                  localizations.flipPrice,
                  Icons.confirmation_number,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection(BuildContext context, bool isDark) {
    final currentTime = DateTime.now();
    final startTime = _routeDetail?.startTime;
    final endTime = _routeDetail?.endTime;
    
    bool isBeforeStartTime = false;
    bool isAfterEndTime = false;
    
    if (startTime != null && startTime.isNotEmpty) {
      try {
        final startParts = startTime.split(':');
        if (startParts.length == 2) {
          final startHour = int.tryParse(startParts[0]) ?? 0;
          final startMinute = int.tryParse(startParts[1]) ?? 0;
          final startDateTime = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            startHour,
            startMinute,
          );
          isBeforeStartTime = currentTime.isBefore(startDateTime);
        }
      } catch (e) {
      }
    }
    
    if (endTime != null && endTime.isNotEmpty) {
      try {
        final endParts = endTime.split(':');
        if (endParts.length == 2) {
          final endHour = int.tryParse(endParts[0]) ?? 0;
          final endMinute = int.tryParse(endParts[1]) ?? 0;
          final endDateTime = DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            endHour,
            endMinute,
          );
          isAfterEndTime = currentTime.isAfter(endDateTime);
        }
      } catch (e) {
      }
    }

    if (!_hasTimeTable) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
        child: Center(
          child: Text(
            localizations.notOperatingToday,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    if (isBeforeStartTime) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
        child: Center(
          child: Text(
            localizations.notStarted,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    if (isAfterEndTime) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
        child: Center(
          child: Text(
            localizations.hasPassedLastDeparture,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    if (_forecastList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
        child: Center(
          child: Text(
            localizations.waitingForDeparture,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.nextDeparture,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._forecastList.take(3).map((forecast) => _buildForecastItem(context, forecast)),
          if (_forecastList.length > 3)
            TextButton(
              onPressed: _showTimetableBottomSheet,
              child: Text(localizations.more),
            ),
        ],
      ),
    );
  }

  Widget _buildForecastItem(BuildContext context, ForecastInfo forecast) {
    final status = _getForecastStatus(forecast);
    final distance = forecast.nearbyForecastDistance > 0
        ? '${(forecast.nearbyForecastDistance / 1000).toStringAsFixed(1)}${localizations.km}'
        : localizations.within100m;
    final stations = forecast.nearbyForecastStation >= 0
        ? '${forecast.nearbyForecastStation}${localizations.stationsAway}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_bus, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forecast.busName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$status $stations $distance',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsList(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.stations,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          ..._stations.asMap().entries.map((entry) {
            final index = entry.key;
            final station = entry.value;
            return _buildStationItem(context, station, index, isDark);
          }),
        ],
      ),
    );
  }

  Widget _buildStationItem(BuildContext context, Station station, int index, bool isDark) {
    final isLast = index == _stations.length - 1;
    final isSelected = station.textbool ?? false;
    final hasBus = station.stationBool ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${station.stationSort}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => _onStationTap(station),
              onLongPress: () => _onStationLongPress(station),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            station.stationName,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.blue : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () => _onStationLongPress(station),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        if (hasBus)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bus, size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  station.busName ?? localizations.notAvailable,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (station.metroTransferList != null && station.metroTransferList!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: station.metroTransferList!.map((metro) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: metro.metroColor != null
                                    ? Color(int.parse(metro.metroColor!.replaceFirst('#', '0xFF')))
                                    : Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                metro.metroName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    if (station.arriveTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${localizations.arrivingSoon}: ${station.arriveTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
