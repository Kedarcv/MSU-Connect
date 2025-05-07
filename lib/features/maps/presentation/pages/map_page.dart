import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../data/services/map_service.dart';
import '../../data/services/google_maps_api_client.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = true;
  bool _showStreetView = false;
  String? _selectedLocationId;
  WebViewController? _webViewController;
  bool _isSearching = false;
  List<Map<String, dynamic>> _filteredLocations = [];
  MapType _currentMapType = MapType.normal;
  final Set<Polyline> _polylines = {};
  Marker? _destinationMarker;
  late GoogleMapsApiClient _mapsApiClient;

  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(-19.5157, 29.8383), // Midlands State University, Gweru, Zimbabwe
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    _mapsApiClient = GoogleMapsApiClient(apiKey: MapService.apiKey);
    _initializeMap();
    _setupSearchListener();
  }

  @override
  void dispose() {
    _mapsApiClient.dispose();
    super.dispose();
  }

  void _toggleStreetView(String locationId) {
    setState(() {
      if (_showStreetView && _selectedLocationId == locationId) {
        // If already showing street view for this location, close it
        _showStreetView = false;
        _selectedLocationId = null;
      } else {
        // Show street view for the selected location
        _showStreetView = true;
        _selectedLocationId = locationId;
      }
    });
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    _addMSUMarkers();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await MapService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position!.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position!.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () async {
              await Geolocator.openLocationSettings();
            },
          ),
        ),
      );
    }
  }

  Future<void> _addMSUMarkers() async {
    try {
      final locations = MapService.campusLocations;
      if (!mounted) return;
      
      setState(() {
        _markers.clear();
        for (final location in locations) {
          _markers.add(
            Marker(
              markerId: MarkerId(location['id']),
              position: location['position'],
              infoWindow: InfoWindow(
                title: location['title'],
                snippet: location['snippet'],
              ),
              onTap: () => _toggleStreetView(location['id']),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                location['type'] == 'academic' ? BitmapDescriptor.hueRed :
                location['type'] == 'service' ? BitmapDescriptor.hueBlue :
                BitmapDescriptor.hueGreen
              ),
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load campus locations: $e')),
      );
    }
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _isSearching = query.isNotEmpty;
        _filteredLocations = MapService.campusLocations
            .where((location) =>
                location['title'].toLowerCase().contains(query) ||
                location['snippet'].toLowerCase().contains(query))
            .toList();
      });
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) return;

    // First try to find campus locations
    final campusLocation = MapService.campusLocations.firstWhere(
      (loc) => loc['title'].toString().toLowerCase().contains(query.toLowerCase()) ||
              loc['snippet'].toString().toLowerCase().contains(query.toLowerCase()),
      orElse: () => <String, dynamic>{},
    );

    if (campusLocation.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          campusLocation['position'] as LatLng,
          18,
        ),
      );
      return;
    }

    // If no campus location found, search external places
    try {
      final response = await _mapsApiClient.searchPlaces(
        query,
        location: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : null,
      );

      if (response['status'] == 'OK' && response['results'].isNotEmpty) {
        final place = response['results'][0];
        final location = place['geometry']['location'];
        final lat = location['lat'] as double;
        final lng = location['lng'] as double;
        
        setState(() {
          if (_destinationMarker != null) {
            _markers.remove(_destinationMarker);
          }
          
          _destinationMarker = Marker(
            markerId: const MarkerId('destination'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: place['name']),
          );
          
          _markers.add(_destinationMarker!);
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(lat, lng),
            15,
          ),
        );

        if (_currentPosition != null) {
          _getDirections(
            origin: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            destination: LatLng(lat, lng),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching places: $e')),
      );
    }
  }

  Future<void> _getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final response = await _mapsApiClient.getDirections(
        origin: origin,
        destination: destination,
      );

      if (response['status'] == 'OK' && response['routes'].isNotEmpty) {
        final route = response['routes'][0];
        final leg = route['legs'][0];
        final points = route['overview_polyline']['points'];
        final decodedPoints = decodePolyline(points);

        setState(() {
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: decodedPoints
                  .map((point) => LatLng(point[0], point[1]))
                  .toList(),
              color: Colors.blue,
              width: 5,
            ),
          );
        });
      }
    } catch (e) {
      print('Error getting directions: $e');
    }
  }

  void _changeMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.terrain
              : MapType.normal;
    });
  }

  List<List<double>> decodePolyline(String encoded) {
    List<List<double>> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add([lat / 1E5, lng / 1E5]);
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          if (_showStreetView)
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => _toggleStreetView(''),
            ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _showStreetView && _selectedLocationId != null
                  ? _buildStreetView()
                  : _buildGoogleMap(),
          _buildSearchField(),
          if (_isSearching && _filteredLocations.isNotEmpty)
            _buildSearchResults(),
          if (!_showStreetView)
            Positioned(
              bottom: 16,
              right: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    heroTag: 'locate',
                    onPressed: _getCurrentLocation,
                    backgroundColor: AppTheme.msuMaroon,
                    child: const Icon(Icons.my_location),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton(
                    heroTag: 'layers',
                    onPressed: _changeMapType,
                    backgroundColor: AppTheme.msuMaroon,
                    child: const Icon(Icons.layers),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStreetView() {
    final location = MapService.getLocationById(_selectedLocationId!);
    final url = 'https://www.google.com/maps/embed/v1/streetview?key=${MapService.apiKey}&location=${location!['position'].latitude},${location['position'].longitude}&heading=${location['streetViewParams']['heading']}&pitch=${location['streetViewParams']['pitch']}&fov=${location['streetViewParams']['zoom']}';
    
    return WebViewWidget(
      controller: WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url)),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      initialCameraPosition: _defaultLocation,
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapType: _currentMapType,
      polylines: _polylines,
    );
  }

  Widget _buildSearchField() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search campus locations...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  onChanged: _searchPlaces,
                ),
              ),
              if (_isSearching)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                      _filteredLocations.clear();
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Positioned(
      top: 80,
      left: 16,
      right: 16,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.3,
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _filteredLocations.length,
            itemBuilder: (context, index) {
              final location = _filteredLocations[index];
              return ListTile(
                title: Text(location['title']),
                subtitle: Text(location['snippet']),
                onTap: () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      location['position'] as LatLng,
                      18,
                    ),
                  );
                  setState(() {
                    _isSearching = false;
                    _searchController.clear();
                    _filteredLocations.clear();
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
