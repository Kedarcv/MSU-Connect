import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapService {
  static const String apiKey = 'AIzaSyB1IiwBut2vPRatOTrZ8jDbYogAxTKXT5Q';
  static const LatLng msuLocation = LatLng(-19.516667, 29.833333);

  // Campus locations with their coordinates
  static final List<Map<String, dynamic>> campusLocations = [
    {
      'id': 'library',
      'position': const LatLng(-19.516000, 29.833500),
      'title': 'MSU Library',
      'snippet': 'Main Library Building',
      'streetViewParams': {
        'heading': 90.0,
        'pitch': 20.0,
        'zoom': 1.0
      }
    },
    {
      'id': 'admin',
      'position': const LatLng(-19.517000, 29.833200),
      'title': 'Administration Block',
      'snippet': 'Administrative Offices',
      'streetViewParams': {
        'heading': 180.0,
        'pitch': 20.0,
        'zoom': 1.0
      }
    },
    {
      'id': 'student_center',
      'position': const LatLng(-19.516500, 29.833100),
      'title': 'Student Center',
      'snippet': 'Student Services and Activities',
      'streetViewParams': {
        'heading': 270.0,
        'pitch': 20.0,
        'zoom': 1.0
      }
    },
  ];

  // Get current location with permission handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position with high accuracy
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  // Get all campus markers
  static Set<Marker> getCampusMarkers() {
    Set<Marker> markers = {};
    
    // Add main campus marker
    markers.add(
      const Marker(
        markerId: MarkerId('msu_main'),
        position: msuLocation,
        infoWindow: InfoWindow(
          title: 'Midlands State University',
          snippet: 'Main Campus',
        ),
      ),
    );

    // Add other campus location markers
    for (var location in campusLocations) {
      markers.add(
        Marker(
          markerId: MarkerId(location['id'] as String),
          position: location['position'] as LatLng,
          infoWindow: InfoWindow(
            title: location['title'] as String,
            snippet: location['snippet'] as String,
          ),
        ),
      );
    }

    return markers;
  }

  // Get location details by ID
  static Map<String, dynamic>? getLocationById(String id) {
    try {
      return campusLocations.firstWhere((location) => location['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate distance between two points
  static double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }
}