import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Location Service for AlphaWave
///
/// Handles GPS location detection to determine user's country.
/// Following Lectures.md principles: simple, clean, and secure implementation.
class LocationService {
  /// Get user's country code using GPS location
  ///
  /// Returns ISO country code (e.g., 'US', 'CA', 'UK')
  /// Throws exception if location access is denied or fails
  Future<String> getCountry() async {
    try {
      print('LocationService: Starting location detection...');

      // Check if location services are enabled first
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('LocationService: Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Please enable GPS and try again.',
        );
      }

      // Step 1: Check for location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      print('LocationService: Initial permission status: $permission');

      // Step 2: Request permission if denied
      if (permission == LocationPermission.denied) {
        print('LocationService: Permission denied, requesting permission...');
        permission = await Geolocator.requestPermission();
        print('LocationService: Permission after request: $permission');

        // If user denies permission again, throw exception
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied by user');
        }
      }

      // Check for permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        print('LocationService: Permission permanently denied');
        throw Exception(
          'Location permission permanently denied. Please enable in settings.',
        );
      }

      print('LocationService: Permission granted: $permission');

      // Step 3: Get current position with timeout wrapper
      print('LocationService: Getting current position...');

      // Use Future.timeout instead of deprecated timeLimit parameter
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Location request timed out after 15 seconds');
            },
          );

      print(
        'LocationService: Position obtained - Lat: ${position.latitude}, Lng: ${position.longitude}',
      );

      // Step 4: Convert coordinates to placemark with timeout
      print('LocationService: Converting coordinates to address...');

      List<Placemark> placemarks =
          await placemarkFromCoordinates(
            position.latitude,
            position.longitude,
          ).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Geocoding request timed out');
            },
          );

      print('LocationService: Found ${placemarks.length} placemarks');

      // Step 5: Extract country code with better error handling
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final countryCode = placemark.isoCountryCode;
        final countryName = placemark.country;

        print(
          'LocationService: Placemark data - Country: $countryName, Code: $countryCode',
        );

        if (countryCode != null && countryCode.isNotEmpty) {
          print(
            'LocationService: Detected country - $countryCode ($countryName)',
          );
          return countryCode;
        } else {
          print('LocationService: Country code is null or empty');
          throw Exception('Unable to determine country from location data');
        }
      } else {
        print('LocationService: No placemarks found');
        throw Exception('No location data available for the current position');
      }
    } catch (e) {
      print('LocationService error: $e');

      // Provide user-friendly error messages
      if (e.toString().contains('timeout') ||
          e.toString().contains('timed out')) {
        throw Exception(
          'Location request timed out. Please ensure GPS is enabled and try again.',
        );
      } else if (e.toString().contains('denied')) {
        rethrow; // Pass through permission errors as-is
      } else if (e.toString().contains('service')) {
        throw Exception(
          'Location services are not available. Please enable GPS.',
        );
      } else if (e.toString().contains('network')) {
        throw Exception(
          'Network error while getting location. Please check your connection.',
        );
      } else {
        throw Exception(
          'Unable to get location. Please check GPS settings and try again.',
        );
      }
    }
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      print('Error checking location service: $e');
      return false;
    }
  }

  /// Get current permission status
  Future<LocationPermission> getPermissionStatus() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      print('Error checking permission status: $e');
      return LocationPermission.denied;
    }
  }
}
