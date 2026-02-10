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
  final double latitude;
  final double longitude;

  const StationDetailPage({
    super.key,
    required this.stationId,
    required this.stationName,
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

  @override
  void initState() {
    super.initState();
    _loadStationRoutes();
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
                Text(
                  localizations.stationDetail,
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

    return ListView.builder(
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
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
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
                title: Text(
                  route.routeName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route.routeId,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
