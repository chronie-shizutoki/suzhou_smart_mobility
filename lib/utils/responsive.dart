import 'package:flutter/material.dart';

/// Width (in logical pixels) at or above which we switch from the
/// phone layout (floating bottom navigation, single column) to the
/// large-screen layout (top navigation bar with text + two-pane
/// master/detail).
const double kWideBreakpoint = 600;

/// Returns true when the current viewport should use the wide / adaptive
/// layout. We use [MediaQuery] width so it reacts to window resizing and
/// orientation changes on tablets / desktops / foldables.
bool isWideLayout(BuildContext context) {
  return MediaQuery.of(context).size.width >= kWideBreakpoint;
}
