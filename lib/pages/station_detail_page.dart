import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/suzhi_bus_api.dart';
import '../models/route.dart' as models;
import '../utils/location_service.dart';
import '../theme/glass_theme.dart';
import 'route_detail_page.dart';

class StationDetailPage extends StatefulWidget {
  final String stationId;
  final String stationName;
  final String? stationRoad;
  final double latitude;
  final double longitude;

  const StationDetailPage({
    super.key,
    required this.stationId,
    required this.stationName,
    this.stationRoad,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<StationDetailPage> createState() => _StationDetailPageState();
}

class _StationDetailPageState extends State<StationDetailPage> {
  List<models.BusRoute> _routes = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStationRoutes();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (mounted) {
        _loadStationRoutes();
      }
    });
  }

  Future<void> _loadStationRoutes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final position = await LocationService.getCurrentPosition();
      
      if (position == null) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.failedToGetLocation;
          _isLoading = false;
        });
        return;
      }

      final result = await SuZhiBusAPI.queryStationVehicles(
        widget.stationId,
        SuZhiBusAPI.generateRequestId(),
        longitude: position.longitude,
        latitude: position.latitude,
      );

      if (result['status'] == true && result['items'] != null) {
        setState(() {
          _routes = (result['items'] as List)
              .map((e) => models.BusRoute.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['msg']?.toString() ?? AppLocalizations.of(context)!.unknownError;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openRouteDetail(models.BusRoute route) async {
    try {
      String? segmentId = route.segmentId;
      
      if (segmentId == null) {
        final result = await SuZhiBusAPI.getRouteStationData(route.routeId);
        
        if (result['status'] == true && result['items'] != null) {
          final items = result['items'] as List;
          if (items.isNotEmpty) {
            segmentId = items[0]['segmentId'] as String?;
          }
        }
        
        if (segmentId == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.unknownError),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailPage(
              segmentId: segmentId!,
              routeName: route.routeName,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBusInfo(BuildContext context, AppLocalizations localizations, models.BusRoute route, int busIndex) {
    final nearbyForecastStation = busIndex == 1 ? route.nearbyForecastStation : route.nearbyForecastStation2;
    final nearbyForecastDistance = busIndex == 1 ? route.nearbyForecastDistance : route.nearbyForecastDistance2;
    final predictArriveTime = busIndex == 1 ? route.predictArriveTime : route.predictArriveTime2;

    if (nearbyForecastStation == null) {
      return const SizedBox.shrink();
    }

    if (nearbyForecastStation == -1) {
      return Text(
        localizations.waitingForDeparture,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }

    if (nearbyForecastStation == 0 && nearbyForecastDistance == 0 && predictArriveTime == 0) {
      return Text(
        localizations.busAtStation,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (nearbyForecastStation == 0) {
      return Text(
        localizations.arrivingSoon,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final timeText = predictArriveTime != null && predictArriveTime > 0
        ? '${predictArriveTime}${localizations.minutes}'
        : '1${localizations.withinMinutes}';
    final distanceText = nearbyForecastDistance != null && nearbyForecastDistance > 0
        ? '${(nearbyForecastDistance / 1000).toStringAsFixed(1)}km'
        : '100m内';

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: busIndex == 1 ? Colors.green : Colors.purple,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$busIndex',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 12,
            color: busIndex == 1 ? Colors.green : Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$nearbyForecastStation${localizations.stations}',
          style: TextStyle(
            fontSize: 12,
            color: busIndex == 1 ? Colors.green : Colors.purple,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '/',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          distanceText,
          style: TextStyle(
            fontSize: 12,
            color: busIndex == 1 ? Colors.green : Colors.purple,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
              _buildHeader(context, localizations, isDark),
              Expanded(
                child: _buildContent(context, localizations, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
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
                  widget.stationName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.stationRoad != null)
                  Text(
                    widget.stationRoad!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations, bool isDark) {
    if (_isLoading) {
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

    if (_errorMessage.isNotEmpty) {
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

    if (_routes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              localizations.noData,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStationRoutes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _routes.length,
        itemBuilder: (context, index) {
        final route = _routes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _openRouteDetail(route);
            },
            child: Container(
              decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.directions_bus,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.routeName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.trip_origin,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text('${localizations.from}: ${route.startStation ?? localizations.notAvailable}'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.place,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                                const SizedBox(width: 4),
                                Text('${localizations.to}: ${route.endStation ?? localizations.notAvailable}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (route.hasTimeTable == true) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${localizations.firstBus}${route.startTime ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${localizations.lastBus}${route.endTime ?? ''}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildBusInfo(context, localizations, route, 1),
                    const SizedBox(height: 4),
                    _buildBusInfo(context, localizations, route, 2),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        localizations.notOperatingToday,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }
}
