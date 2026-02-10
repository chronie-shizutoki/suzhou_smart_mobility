import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/suzhi_bus_api.dart';
import '../models/station.dart';
import '../models/route.dart' as models;
import '../utils/location_service.dart';
import '../theme/glass_theme.dart';
import 'route_detail_page.dart';
import 'station_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Station> _stations = [];
  List<models.BusRoute> _routes = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchStations() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _stations = [];
    });

    try {
      final result = await SuZhiBusAPI.searchStations(_searchController.text);

      if (result['status'] == true && result['items'] != null) {
        setState(() {
          _stations = (result['items'] as List)
              .map((e) => Station.fromJson(e as Map<String, dynamic>))
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

  Future<void> _searchRoutes() async {
    if (_searchController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _routes = [];
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

      final result = await SuZhiBusAPI.searchRoutes(
        position.longitude,
        position.latitude,
      );

      if (result['status'] == true && result['items'] != null) {
        final allRoutes = (result['items'] as List)
            .map((e) => models.BusRoute.fromJson(e as Map<String, dynamic>))
            .toList();
        
        final searchKey = _searchController.text.trim();
        final filteredRoutes = allRoutes.where((route) {
          return route.routeName.contains(searchKey);
        }).toList();

        setState(() {
          _routes = filteredRoutes;
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

  Future<void> _openStationDetail(Station station) async {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StationDetailPage(
            stationId: station.stationId,
            stationName: station.stationName,
            stationRoad: station.stationRoad,
            latitude: station.latitude,
            longitude: station.longitude,
          ),
        ),
      );
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
              _buildSearchBar(context, localizations, isDark),
              _buildTabBar(context, localizations),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStationsTab(context, localizations, isDark),
                    _buildRoutesTab(context, localizations, isDark),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: localizations.searchPlaceholder,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  setState(() {});
                },
                onSubmitted: (_) {
                  if (_tabController.index == 0) {
                    _searchStations();
                  } else {
                    _searchRoutes();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                if (_tabController.index == 0) {
                  _searchStations();
                } else {
                  _searchRoutes();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        tabs: [
          Tab(text: localizations.searchStations),
          Tab(text: localizations.routes),
        ],
      ),
    );
  }

  Widget _buildStationsTab(BuildContext context, AppLocalizations localizations, bool isDark) {
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

    if (_stations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _stations.length,
      itemBuilder: (context, index) {
        final station = _stations[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              _openStationDetail(station);
            },
            child: Container(
              decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          station.stationName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (station.stationRoad != null || station.stationDirect != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _buildStationTitle(station),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
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
    );
  }

  Widget _buildRoutesTab(BuildContext context, AppLocalizations localizations, bool isDark) {
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
              padding: const EdgeInsets.all(16),
              child: Row(
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
            ),
          ),
        );
      },
    );
  }

  String _buildStationTitle(Station station) {
    final parts = <String>[];
    if (station.stationRoad != null) parts.add(station.stationRoad!);
    if (station.stationDirect != null) parts.add(station.stationDirect!);
    return parts.join(' ');
  }
}
