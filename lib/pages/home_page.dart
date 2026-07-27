import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/suzhi_bus_api.dart';
import '../models/station.dart';
import '../models/route.dart' as models;
import '../utils/location_service.dart';
import '../theme/glass_theme.dart';
import '../utils/zh_converter.dart';
import 'route_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Station> _nearbyStations = [];
  final Map<String, List<models.BusRoute>> _stationRoutes = {};
  final Map<String, String> _stationErrors = {};
  bool _isLoading = false;
  final bool _isLoadingRoutes = false;
  String _errorMessage = '';
  String? _expandedStationId;
  static const int _defaultExpandedCount = 4;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _queryNearbyStations();
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
        // Silent refresh: no fullscreen loading, no scroll position disruption
        _queryNearbyStations(silent: true);
      }
    });
  }

  Future<void> _queryNearbyStations({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final position = await LocationService.getCurrentPosition();
      
      if (position == null) {
        if (silent) return; // Silent refresh failed, keep old data
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.failedToGetLocation;
          _isLoading = false;
        });
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;

      // Debug: print actual coordinates
      debugPrint('GPS Coordinates: lat=$latitude, lng=$longitude');
      
      // More precise Suzhou geographical boundaries with some buffer
      // Suzhou is roughly: 30.47°N to 32.02°N, 119.55°E to 121.20°E
      const double suzhouMinLat = 30.47;
      const double suzhouMaxLat = 32.02;
      const double suzhouMinLng = 119.55;
      const double suzhouMaxLng = 121.20;

      debugPrint('Suzhou boundaries: lat[$suzhouMinLat-$suzhouMaxLat], lng[$suzhouMinLng-$suzhouMaxLng]');
      debugPrint('Check: lat < min? ${latitude < suzhouMinLat}, lat > max? ${latitude > suzhouMaxLat}');
      debugPrint('Check: lng < min? ${longitude < suzhouMinLng}, lng > max? ${longitude > suzhouMaxLng}');

      if (latitude < suzhouMinLat || latitude > suzhouMaxLat || longitude < suzhouMinLng || longitude > suzhouMaxLng) {
        if (silent) return;
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.locationNotInSuzhou;
          _isLoading = false;
        });
        return;
      }

      final result = await SuZhiBusAPI.queryNearbyStations(
        longitude,
        latitude,
        range: 800,
      );

      if (result['status'] == true && result['items'] != null) {
        setState(() {
          _nearbyStations = (result['items'] as List)
              .map((e) => Station.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          _errorMessage = '';
        });
        await _queryAllStationRoutes(forceRefresh: silent);
      } else {
        if (silent) return;
        setState(() {
          _errorMessage = result['msg']?.toString() ?? AppLocalizations.of(context)!.unknownError;
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      if (silent) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _queryAllStationRoutes({bool forceRefresh = false}) async {
    for (final station in _nearbyStations) {
      if (forceRefresh || _stationRoutes[station.stationId] == null) {
        await _queryStationRoutes(station);
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  Future<void> _queryStationRoutes(Station station) async {
    try {
      final position = await LocationService.getCurrentPosition();
      
      if (!mounted) return;
      if (position == null) {
        setState(() {
          _stationRoutes[station.stationId] = [];
          _stationErrors[station.stationId] = AppLocalizations.of(context)!.failedToGetLocation;
        });
        return;
      }

      final latitude = position.latitude;
      final longitude = position.longitude;

      final result = await SuZhiBusAPI.queryStationVehicles(
        station.stationId,
        SuZhiBusAPI.generateRequestId(),
        longitude: longitude,
        latitude: latitude,
      );

      if (!mounted) return;
      if (result['status'] == true && result['items'] != null) {
        final items = result['items'] as List;
        if (items.isNotEmpty) {
          setState(() {
            _stationRoutes[station.stationId] = items
                .map((e) => models.BusRoute.fromJson(e as Map<String, dynamic>))
                .toList();
            _stationErrors.remove(station.stationId);
          });
        } else {
          setState(() {
            _stationRoutes[station.stationId] = [];
            _stationErrors[station.stationId] = result['msg']?.toString() ?? AppLocalizations.of(context)!.noData;
          });
        }
      } else {
        setState(() {
          _stationRoutes[station.stationId] = [];
          _stationErrors[station.stationId] = result['msg']?.toString() ?? AppLocalizations.of(context)!.unknownError;
        });
      }
    } catch (e) {
      setState(() {
        _stationRoutes[station.stationId] = [];
        _stationErrors[station.stationId] = e.toString();
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
              routeId: route.routeId,
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
              _buildHeader(context, localizations),
              Expanded(
                child: _buildContent(context, localizations, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.nearbyStations,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                _nearbyStations.isEmpty
                    ? localizations.noData
                    : '${_nearbyStations.length}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations, bool isDark) {
    // Show fullscreen loading only on initial load (when no data), keep list and scroll position on refresh
    if (_isLoading && _nearbyStations.isEmpty) {
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

    if (_errorMessage.isNotEmpty && _nearbyStations.isEmpty) {
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

    if (_nearbyStations.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
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
      );
    }

    return RefreshIndicator(
      // Pull-to-refresh with silent mode, avoid full-page loading causing scroll position loss
      onRefresh: () => _queryNearbyStations(silent: true),
      child: ListView.builder(
        // Bottom padding to avoid being covered by floating navigation bar
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
        itemCount: _nearbyStations.length,
        itemBuilder: (context, index) {
        final station = _nearbyStations[index];
        final routes = _stationRoutes[station.stationId] ?? [];
        final isExpanded = _expandedStationId == station.stationId;
        final initiallyExpanded = index < _defaultExpandedCount;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: initiallyExpanded,
                tilePadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.directions_bus,
                    color: Colors.blue,
                  ),
                ),
                title: ConvertedText(
                  _buildStationTitle(station),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _buildWalkingTime(station.distance),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.straighten,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${localizations.distance}: ${station.distance?.toStringAsFixed(0) ?? 0} ${localizations.meters}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                      ),
                    ],
                  ),
                ),
                trailing: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.expand_more,
                    color: Colors.blue,
                  ),
                ),
                onExpansionChanged: (expanded) {
                  setState(() {
                    if (expanded) {
                      _expandedStationId = station.stationId;
                    } else {
                      _expandedStationId = null;
                    }
                  });
                },
                children: [
                  if (_isLoadingRoutes && isExpanded)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (routes.isNotEmpty)
                    ...routes.map((route) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: InkWell(
                            onTap: () {
                              _openRouteDetail(route);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: _buildRouteContent(context, localizations, route),
                            ),
                          ),
                        ))
                  else if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            localizations.noData,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          if (_stationErrors[station.stationId] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _stationErrors[station.stationId]!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.withValues(alpha: 0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
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

  Widget _buildRouteContent(BuildContext context, AppLocalizations localizations, models.BusRoute route) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.directions_bus,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ConvertedText(
                route.routeName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              localizations.to,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: ConvertedText(
                route.endStation ?? localizations.notAvailable,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
        if (route.hasTimeTable == true) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${localizations.firstBus}${route.startTime ?? ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${localizations.lastBus}${route.endTime ?? ''}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
              ),
          ),
      ],
    );
  }

  String _buildStationTitle(Station station) {
    final title = station.stationName;
    final parts = <String>[];
    if (station.stationRoad != null) parts.add(station.stationRoad!);
    if (station.stationDirect != null) parts.add(station.stationDirect!);
    if (parts.isNotEmpty) {
      return '$title (${parts.join(' ')})';
    }
    return title;
  }

  String _buildWalkingTime(double? distance) {
    if (distance == null || distance <= 0) {
      return '${AppLocalizations.of(context)!.walking} 0 ${AppLocalizations.of(context)!.minutes}';
    }
    final walkingSpeed = 80;
    final walkingMinutes = (distance / walkingSpeed).ceil();
    return '${AppLocalizations.of(context)!.walking} $walkingMinutes ${AppLocalizations.of(context)!.minutes}';
  }

  Widget _buildBusInfo(BuildContext context, AppLocalizations localizations, models.BusRoute route, int busIndex) {
    final nearbyForecastStation = busIndex == 1 ? route.nearbyForecastStation : route.nearbyForecastStation2;
    final nearbyForecastDistance = busIndex == 1 ? route.nearbyForecastDistance : route.nearbyForecastDistance2;
    final predictArriveTime = busIndex == 1 ? route.predictArriveTime : route.predictArriveTime2;

    if (nearbyForecastStation == null) {
      return const SizedBox.shrink();
    }

    if (nearbyForecastStation == -1) {
      final currentTime = DateTime.now();
      final startTime = route.startTime;
      final endTime = route.endTime;
      
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
      
      if (isBeforeStartTime) {
        return Text(
          localizations.notStarted,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        );
      }
      
      if (isAfterEndTime) {
        return Text(
          localizations.hasPassedLastDeparture,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
        );
      }
      
      return Text(
        localizations.waitingForDeparture,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
      );
    }

    if (nearbyForecastStation == 0 && nearbyForecastDistance == 0 && predictArriveTime == 0) {
      return Text(
        localizations.busAtStation,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    if (nearbyForecastStation == 0) {
      return Text(
        localizations.arrivingSoon,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
      );
    }

    final timeText = predictArriveTime != null && predictArriveTime > 0
        ? '$predictArriveTime${localizations.minutes}'
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
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: busIndex == 1 ? Colors.green : Colors.purple,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Text(
          '$nearbyForecastStation${localizations.stations}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: busIndex == 1 ? Colors.green : Colors.purple,
              ),
        ),
        const SizedBox(width: 4),
        Text(
          '/',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        ),
        const SizedBox(width: 4),
        Text(
          distanceText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: busIndex == 1 ? Colors.green : Colors.purple,
              ),
        ),
      ],
    );
  }
}
