import 'dart:async';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/suzhi_bus_api.dart';
import '../models/route.dart' as models;
import '../models/station.dart';
import '../utils/location_service.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_container.dart';
import '../utils/zh_converter.dart';
import '../pages/route_detail_page.dart';

/// A reusable, scaffold-free view that loads and renders the real-time
/// vehicle / route information for a single [Station].
///
/// It is used in two places:
///  * inside [StationDetailPage] (mobile: pushed as a full screen), and
///  * as the right-hand pane of the wide-screen two-column layout.
class StationDetailView extends StatefulWidget {
  final Station station;

  /// When provided, tapping a route reports it here (used as the right-hand
  /// slave pane of the wide-screen layout) instead of pushing a full-screen
  /// route detail page.
  final ValueChanged<RouteRef>? onOpenRoute;

  /// When provided (i.e. this view is a drilled-in slave pane on a large
  /// screen), shows a back button in the header that pops the pane stack.
  final VoidCallback? onBack;

  const StationDetailView({
    super.key,
    required this.station,
    this.onOpenRoute,
    this.onBack,
  });

  @override
  State<StationDetailView> createState() => _StationDetailViewState();
}

class _StationDetailViewState extends State<StationDetailView> {
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
  void didUpdateWidget(covariant StationDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the selected station changes (e.g. user taps a different item in
    // the left pane), reload the detail for the new station.
    if (oldWidget.station.stationId != widget.station.stationId) {
      _loadStationRoutes();
    }
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
        _loadStationRoutes(silent: true);
      }
    });
  }

  Future<void> _loadStationRoutes({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
    }

    try {
      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;
      if (position == null) {
        if (silent) return; // Silent refresh failed, keep old data
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.failedToGetLocation;
          _isLoading = false;
        });
        return;
      }

      final result = await SuZhiBusAPI.queryStationVehicles(
        widget.station.stationId,
        SuZhiBusAPI.generateRequestId(),
        longitude: position.longitude,
        latitude: position.latitude,
      );

      if (!mounted) return;
      if (result['status'] == true && result['items'] != null) {
        setState(() {
          _routes = (result['items'] as List)
              .map((e) => models.BusRoute.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
          _errorMessage = '';
        });
      } else {
        if (silent) return;
        setState(() {
          _errorMessage = result['msg']?.toString() ?? AppLocalizations.of(context)!.unknownError;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (silent) return;
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
        if (widget.onOpenRoute != null) {
          widget.onOpenRoute!(RouteRef(
            segmentId: segmentId,
            routeId: route.routeId,
            routeName: route.routeName,
          ));
          return;
        }
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
          // ignore parse errors
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
          // ignore parse errors
        }
      }

      if (isBeforeStartTime) {
        return Text(
          localizations.notStarted,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }

      if (isAfterEndTime) {
        return Text(
          localizations.hasPassedLastDeparture,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        );
      }

      return Text(
        localizations.waitingForDeparture,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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

    return Column(
      children: [
        _buildHeader(context, localizations),
        Expanded(
          child: _buildContent(context, localizations, isDark),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          if (widget.onBack != null)
            GlassIconButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onPressed: widget.onBack!,
              iconColor: Colors.blue,
              tooltip: '返回',
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConvertedText(
                  widget.station.stationName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (widget.station.stationRoad != null)
                  ConvertedText(
                    widget.station.stationRoad!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations.refresh,
            onPressed: () => _loadStationRoutes(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations, bool isDark) {
    // Show fullscreen loading only when first loading (no data available)
    if (_isLoading && _routes.isEmpty) {
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

    if (_errorMessage.isNotEmpty && _routes.isEmpty) {
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

    if (_routes.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_bus,
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
      // Pull-to-refresh with silent mode, avoid scroll position loss
      onRefresh: () => _loadStationRoutes(silent: true),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                            color: Colors.blue.withValues(alpha: 0.2),
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
                              ConvertedText(
                                route.routeName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.trip_origin,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${localizations.from}: ${_displayName(route.startStation, localizations.notAvailable)}'),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text('${localizations.to}: ${_displayName(route.endStation, localizations.notAvailable)}'),
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
                              color: Colors.orange.withValues(alpha: 0.2),
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
                              color: Colors.purple.withValues(alpha: 0.2),
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
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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

  /// Convert a place name to Traditional Chinese when the active locale
  /// requires it; fall back to [fallback] for null/empty values.
  String _displayName(String? name, String fallback) {
    if (name == null || name.isEmpty) return fallback;
    return ZhConverter.convertSync(name);
  }
}
