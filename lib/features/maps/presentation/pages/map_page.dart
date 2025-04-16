import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/maps/data/services/map_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addMSUMarkers();
  }

  Future<void> _getCurrentLocation() async {
    final position = await MapService.getCurrentLocation();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });
  }

  void _addMSUMarkers() {
    setState(() {
      _markers.addAll(MapService.getCampusMarkers());
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchLocation(String query) {
    final searchQuery = query.toLowerCase();
    final location = MapService.campusLocations.firstWhere(
      (loc) => loc['title'].toString().toLowerCase().contains(searchQuery) ||
          loc['snippet'].toString().toLowerCase().contains(searchQuery),
      orElse: () => {},
    );

    if (location.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          location['position'] as LatLng,
          18,
        ),
      );
    }
  }

  void _toggleStreetView(String locationId) {
    setState(() {
      _showStreetView = !_showStreetView;
      _selectedLocationId = locationId;
    });
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
              onPressed: () => setState(() => _showStreetView = false),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            if (_showStreetView && _selectedLocationId != null)
              WebView(
                initialUrl: 'https://www.google.com/maps/embed/v1/streetview?key=${MapService.apiKey}&location=${MapService.getLocationById(_selectedLocationId!)!['position'].latitude},${MapService.getLocationById(_selectedLocationId!)!['position'].longitude}&heading=${MapService.getLocationById(_selectedLocationId!)!['streetViewParams']['heading']}&pitch=${MapService.getLocationById(_selectedLocationId!)!['streetViewParams']['pitch']}&fov=${MapService.getLocationById(_selectedLocationId!)!['streetViewParams']['zoom']}',
                javascriptMode: JavascriptMode.unrestricted,
              )
            else
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _currentPosition != null
                      ? LatLng(
                          _currentPosition!.latitude,
                          _currentPosition!.longitude,
                        )
                      : MapService.msuLocation,
                  zoom: 15.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapToolbarEnabled: true,
                compassEnabled: true,
                onTap: (LatLng position) {
                  final nearestLocation = MapService.campusLocations.firstWhere(
                    (loc) => MapService.calculateDistance(
                          position,
                          loc['position'] as LatLng,
                        ) <=
                        50, // 50 meters radius
                    orElse: () => {},
                  );

                  if (nearestLocation.isNotEmpty) {
                    _toggleStreetView(nearestLocation['id'] as String);
                  }
                },
              ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search campus locations...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchLocation(_searchController.text),
                    ),
                    border: InputBorder.none,
                  ),
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}