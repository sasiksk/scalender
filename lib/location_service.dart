import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocationService {
  static Future<void> initializeTimeZone() async {
    // Initialize time zone data
    tz.initializeTimeZones();

    // Get the shared preferences instance
    final prefs = await SharedPreferences.getInstance();

    // Check if the time zone is already saved
    final savedTimeZone = prefs.getString('timezone');
    if (savedTimeZone != null) {
      // Set the saved time zone
      tz.setLocalLocation(tz.getLocation(savedTimeZone));
      return;
    }

    // Request location permission
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, don't continue
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, don't continue
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Get the current time zone based on the position
    final double latitude = position.latitude;

    final double longitude = position.longitude;
    final String timeZoneId = tz.TZDateTime.now(tz.local).timeZoneName;
    final tz.Location location = tz.getLocation(timeZoneId);

    // Save the time zone to shared preferences
    await prefs.setString('timezone', timeZoneId);

    // Set the local time zone
    tz.setLocalLocation(location);
  }
}
