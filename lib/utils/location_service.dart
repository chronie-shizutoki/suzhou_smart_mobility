import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> checkPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> checkServiceEnabled() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
    }
    return serviceEnabled;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      final serviceEnabled = await checkServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      return null;
    }
  }

  static Future<Position?> getLastKnownPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) {
        return null;
      }

      final position = await Geolocator.getLastKnownPosition();
      return position;
    } catch (e) {
      return null;
    }
  }
}
