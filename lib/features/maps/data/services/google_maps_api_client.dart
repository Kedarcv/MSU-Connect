import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsApiClient {
  final String apiKey;
  final http.Client _httpClient;

  GoogleMapsApiClient({required this.apiKey}) : _httpClient = http.Client();

  Future<Map<String, dynamic>> searchPlaces(String query, {LatLng? location}) async {
    final params = {
      'key': apiKey,
      'query': query,
    };
    
    if (location != null) {
      params['location'] = '${location.latitude},${location.longitude}';
      params['radius'] = '10000'; // 10km radius
    }
    
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/textsearch/json',
      params,
    );
    
    final response = await _httpClient.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search places: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getDirections({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    final params = {
      'key': apiKey,
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'mode': mode,
    };
    
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      params,
    );
    
    final response = await _httpClient.get(uri);
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get directions: ${response.body}');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}