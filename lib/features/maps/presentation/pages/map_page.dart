import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/maps/data/services/map_service.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeMap();
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
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Show error message to user
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
      final locations = await MapService.getCampusLocations();
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
              onTap: () => _onMarkerTapped(location['id']),
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

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _searchLocation(String query) {
    final searchQuery = query.toLowerCase();
    
    // Find matching location
    Map<String, dynamic>? location;
    try {
      location = MapService.campusLocations.firstWhere(
        (loc) => loc['title'].toString().toLowerCase().contains(searchQuery) ||
                loc['snippet'].toString().toLowerCase().contains(searchQuery),
      );
    } catch (e) {
      // No location found
      location = null;
    }
    
    if (location != null) {
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
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : MapService.msuLocation,
        zoom: 15.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: true,
      compassEnabled: true,
      onTap: _onMapTap,
    );
  }

  void _onMapTap(LatLng position) {
    Map<String, dynamic>? nearestLocation;
    try {
      nearestLocation = MapService.campusLocations.firstWhere(
        (loc) => MapService.calculateDistance(position, loc['position'] as LatLng) <= 50,
      );
    } catch (e) {
      // No location found within the distance threshold
      nearestLocation = null;
    }
    
    if (nearestLocation != null) {
      _toggleStreetView(nearestLocation['id'] as String);
    }
  }

  Widget _buildSearchField() {
    return Positioned(
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
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
