import 'package:flutter/material.dart';
import '../models/station.dart';
import '../pages/route_detail_page.dart';
import 'station_detail_view.dart';

/// A single step in the right-hand pane's navigation stack.
/// Either a station detail (master) or a route detail (slave).
class _PaneEntry {
  final Station? station;
  final RouteRef? route;

  const _PaneEntry.station(this.station) : route = null;
  const _PaneEntry.route(this.route) : station = null;

  bool get isStation => station != null;
}

/// Right-hand pane of the wide-screen master/detail layout.
///
/// It keeps a small navigation stack so the user can drill down *within* the
/// right pane instead of leaving it:
///   station (master)  →  route (slave)  →  station (slave)  →  route ...
///
/// Tapping a route from a station pushes a route entry; opening a station
/// from a route pushes a station entry; the back button pops. Because every
/// step stays inside this pane, the station opened from a route detail never
/// takes over the whole screen.
///
/// The pane is keyed by the master station id from the parent, so selecting a
/// different station in the left list automatically resets the stack.
class StationDetailPane extends StatefulWidget {
  final Station station;

  const StationDetailPane({
    super.key,
    required this.station,
  });

  @override
  State<StationDetailPane> createState() => _StationDetailPaneState();
}

class _StationDetailPaneState extends State<StationDetailPane> {
  late List<_PaneEntry> _stack;

  @override
  void initState() {
    super.initState();
    _stack = [_PaneEntry.station(widget.station)];
  }

  void _pushStation(Station station) {
    setState(() => _stack.add(_PaneEntry.station(station)));
  }

  void _pushRoute(RouteRef ref) {
    setState(() => _stack.add(_PaneEntry.route(ref)));
  }

  void _replaceRoute(RouteRef ref) {
    setState(() {
      _stack[_stack.length - 1] = _PaneEntry.route(ref);
    });
  }

  void _pop() {
    setState(() {
      if (_stack.length > 1) _stack.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = _stack.last;
    final canGoBack = _stack.length > 1;

    Widget content;
    if (entry.isStation) {
      content = StationDetailView(
        key: ValueKey(entry.station!.stationId),
        station: entry.station!,
        onOpenRoute: _pushRoute,
        onBack: canGoBack ? _pop : null,
      );
    } else {
      content = RouteDetailView(
        key: ValueKey(entry.route!.segmentId),
        segmentId: entry.route!.segmentId,
        routeId: entry.route!.routeId,
        routeName: entry.route!.routeName,
        onBack: _pop,
        onNavigate: _replaceRoute,
        onOpenStation: _pushStation,
      );
    }

    // In-app swipe-right to go back within the right-hand pane (desktop / web,
    // where there is no OS edge-swipe). The platform / browser back gesture is
    // handled separately by the PopScope below.
    if (canGoBack) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          // primaryVelocity > 0 means the user swiped toward the right.
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            _pop();
          }
        },
        child: content,
      );
    }

    // Intercept the platform back gesture (Android back button, browser back /
    // swipe) and the OS edge-swipe: as long as there is a drill-down stack we
    // pop it instead of letting the whole app close. At the top level
    // (canPop == true) the back behaves normally and may leave the app.
    return PopScope(
      canPop: !canGoBack,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _pop();
        }
      },
      child: content,
    );
  }
}
