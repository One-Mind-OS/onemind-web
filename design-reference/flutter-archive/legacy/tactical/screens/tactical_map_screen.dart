import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../shared/theme/tactical.dart';
import '../../platform/providers/device_hub_providers.dart';
import '../../platform/services/device_hub/models.dart';
import '../../platform/config/environment.dart';

/// Tactical Map Screen - Real-time location tracking with Google Maps
///
/// Features:
/// - Live GPS tracking with activity recognition
/// - Multiple map types (normal, satellite, terrain, hybrid)
/// - Geofence zone visualization
/// - Place search with autocomplete
/// - Directions/routing between points
class TacticalMapScreen extends ConsumerStatefulWidget {
  const TacticalMapScreen({super.key});

  @override
  ConsumerState<TacticalMapScreen> createState() => _TacticalMapScreenState();
}

class _TacticalMapScreenState extends ConsumerState<TacticalMapScreen> {
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _followUser = true;
  bool _showGeofences = true;
  DevicePosition? _lastPosition;

  // Search & Directions state
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  LatLng? _selectedDestination;
  String? _selectedDestinationName;
  List<LatLng> _routePoints = [];
  String? _routeInfo;

  // Default to NYC if no location available
  static const LatLng _defaultLocation = LatLng(40.7128, -74.0060);

  // Google API key from environment
  String get _apiKey => const String.fromEnvironment(
        'GOOGLE_MAPS_API_KEY',
        defaultValue: '',
      );

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    final locationService = ref.read(locationServiceProvider);
    await locationService.startTracking(mode: LocationTrackingMode.balanced);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setMapStyle();
  }

  Future<void> _setMapStyle() async {
    // Dark tactical map style
    const darkStyle = '''
    [
      {"elementType": "geometry", "stylers": [{"color": "#1d1d1d"}]},
      {"elementType": "labels.text.fill", "stylers": [{"color": "#8ec3b9"}]},
      {"elementType": "labels.text.stroke", "stylers": [{"color": "#1a1a1a"}]},
      {"featureType": "administrative", "elementType": "geometry.stroke", "stylers": [{"color": "#4b6878"}]},
      {"featureType": "administrative.land_parcel", "stylers": [{"visibility": "off"}]},
      {"featureType": "administrative.neighborhood", "stylers": [{"visibility": "off"}]},
      {"featureType": "poi", "elementType": "labels.text", "stylers": [{"visibility": "off"}]},
      {"featureType": "poi.business", "stylers": [{"visibility": "off"}]},
      {"featureType": "road", "elementType": "geometry", "stylers": [{"color": "#304a7d"}]},
      {"featureType": "road", "elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
      {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#98a5be"}]},
      {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#2c3e50"}]},
      {"featureType": "road.highway", "elementType": "geometry.stroke", "stylers": [{"color": "#1f2d3d"}]},
      {"featureType": "transit", "stylers": [{"visibility": "off"}]},
      {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#17263c"}]},
      {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#515c6d"}]}
    ]
    ''';
    await _mapController?.setMapStyle(darkStyle);
  }

  void _centerOnUser() {
    if (_lastPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
          16,
        ),
      );
    }
    setState(() => _followUser = true);
  }

  void _toggleMapType() {
    setState(() {
      switch (_mapType) {
        case MapType.normal:
          _mapType = MapType.satellite;
          break;
        case MapType.satellite:
          _mapType = MapType.terrain;
          break;
        case MapType.terrain:
          _mapType = MapType.hybrid;
          break;
        case MapType.hybrid:
          _mapType = MapType.normal;
          break;
        default:
          _mapType = MapType.normal;
      }
    });
  }

  String _getMapTypeName() {
    switch (_mapType) {
      case MapType.normal:
        return 'Standard';
      case MapType.satellite:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      case MapType.hybrid:
        return 'Hybrid';
      default:
        return 'Standard';
    }
  }

  IconData _getActivityIcon(ActivityType activity) {
    switch (activity) {
      case ActivityType.stationary:
        return Icons.person_pin;
      case ActivityType.walking:
        return Icons.directions_walk;
      case ActivityType.running:
        return Icons.directions_run;
      case ActivityType.cycling:
        return Icons.directions_bike;
      case ActivityType.driving:
        return Icons.directions_car;
      default:
        return Icons.location_on;
    }
  }

  String _formatSpeed(double? speed) {
    if (speed == null || speed < 0) return '--';
    final mph = speed * 2.237;
    return '${mph.toStringAsFixed(1)} mph';
  }

  String _formatHeading(double? heading) {
    if (heading == null || heading < 0) return '--';
    final directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((heading + 22.5) / 45).floor() % 8;
    return '${heading.toStringAsFixed(0)}° ${directions[index]}';
  }

  // ==========================================================================
  // PLACE SEARCH
  // ==========================================================================

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty || _apiKey.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final location = _lastPosition != null
          ? '${_lastPosition!.latitude},${_lastPosition!.longitude}'
          : '40.7128,-74.0060';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&location=$location'
        '&radius=50000'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = (data['predictions'] as List)
              .map((p) => {
                    'place_id': p['place_id'],
                    'description': p['description'],
                    'main_text': p['structured_formatting']?['main_text'] ?? p['description'],
                  })
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _selectPlace(String placeId, String name) async {
    if (_apiKey.isEmpty) return;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final location = data['result']['geometry']['location'];
        final destination = LatLng(location['lat'], location['lng']);

        setState(() {
          _selectedDestination = destination;
          _selectedDestinationName = name;
          _searchResults = [];
          _searchController.clear();
        });

        // Animate to destination
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(destination, 15),
        );

        // Get directions if we have current position
        if (_lastPosition != null) {
          _getDirections(
            LatLng(_lastPosition!.latitude, _lastPosition!.longitude),
            destination,
          );
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  // ==========================================================================
  // DIRECTIONS
  // ==========================================================================

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    if (_apiKey.isEmpty) return;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&mode=driving'
        '&key=$_apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Decode polyline
          final points = _decodePolyline(route['overview_polyline']['points']);

          setState(() {
            _routePoints = points;
            _routeInfo = '${leg['distance']['text']} • ${leg['duration']['text']}';
          });

          // Fit map to show entire route
          _fitBounds(points);
        }
      }
    } catch (e) {
      debugPrint('Directions error: $e');
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _fitBounds(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  void _clearRoute() {
    setState(() {
      _selectedDestination = null;
      _selectedDestinationName = null;
      _routePoints = [];
      _routeInfo = null;
    });
  }

  // ==========================================================================
  // BUILD GEOFENCE CIRCLES
  // ==========================================================================

  Set<Circle> _buildGeofenceCircles(List<Geofence> geofences) {
    if (!_showGeofences) return {};

    return geofences.map((g) {
      // Color based on name or default
      Color fillColor;
      Color strokeColor;
      if (g.name.toLowerCase().contains('home')) {
        fillColor = Colors.green.withValues(alpha: 0.2);
        strokeColor = Colors.green;
      } else if (g.name.toLowerCase().contains('work')) {
        fillColor = Colors.blue.withValues(alpha: 0.2);
        strokeColor = Colors.blue;
      } else if (g.name.toLowerCase().contains('gym')) {
        fillColor = Colors.orange.withValues(alpha: 0.2);
        strokeColor = Colors.orange;
      } else {
        fillColor = TacticalColors.primary.withValues(alpha: 0.2);
        strokeColor = TacticalColors.primary;
      }

      return Circle(
        circleId: CircleId(g.id),
        center: LatLng(g.latitude, g.longitude),
        radius: g.radius,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: 2,
      );
    }).toSet();
  }

  // ==========================================================================
  // BUILD UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final positionAsync = ref.watch(currentPositionProvider);
    final locationState = ref.watch(locationStateProvider);
    final geofences = ref.watch(geofenceListNotifierProvider);

    return Scaffold(
      backgroundColor: TacticalColors.background,
      appBar: AppBar(
        backgroundColor: TacticalColors.background,
        elevation: 0,
        title: const Text(
          'TACTICAL MAP',
          style: TacticalText.screenTitle,
        ),
        actions: [
          // Toggle geofences
          IconButton(
            icon: Icon(
              _showGeofences ? Icons.layers : Icons.layers_outlined,
              color: _showGeofences ? TacticalColors.operational : TacticalColors.textDim,
            ),
            tooltip: 'Toggle Zones',
            onPressed: () => setState(() => _showGeofences = !_showGeofences),
          ),
          // Map type toggle
          IconButton(
            icon: const Icon(
              Icons.map_outlined,
              color: TacticalColors.primary,
            ),
            tooltip: 'Map Type: ${_getMapTypeName()}',
            onPressed: _toggleMapType,
          ),
          // Center on location
          IconButton(
            icon: Icon(
              _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
              color: _followUser ? TacticalColors.operational : TacticalColors.textDim,
            ),
            tooltip: 'Center on Location',
            onPressed: _centerOnUser,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          positionAsync.when(
            data: (position) {
              _lastPosition = position;

              if (_followUser && _mapController != null && _routePoints.isEmpty) {
                _mapController!.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(position.latitude, position.longitude),
                  ),
                );
              }

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 16,
                ),
                mapType: _mapType,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                // Geofence circles
                circles: _buildGeofenceCircles(geofences),
                // Route polyline
                polylines: _routePoints.isNotEmpty
                    ? {
                        Polyline(
                          polylineId: const PolylineId('route'),
                          points: _routePoints,
                          color: TacticalColors.primary,
                          width: 4,
                        ),
                      }
                    : {},
                // Markers
                markers: {
                  // User marker
                  Marker(
                    markerId: const MarkerId('user'),
                    position: LatLng(position.latitude, position.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueCyan,
                    ),
                    infoWindow: InfoWindow(
                      title: 'You',
                      snippet: position.zoneName ?? position.activity.name,
                    ),
                  ),
                  // Destination marker
                  if (_selectedDestination != null)
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _selectedDestination!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: _selectedDestinationName ?? 'Destination',
                        snippet: _routeInfo,
                      ),
                    ),
                  // Geofence center markers
                  ...geofences.map((g) => Marker(
                        markerId: MarkerId('zone_${g.id}'),
                        position: LatLng(g.latitude, g.longitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueViolet,
                        ),
                        infoWindow: InfoWindow(
                          title: g.name,
                          snippet: '${g.radius.toInt()}m radius',
                        ),
                        alpha: 0.7,
                      )),
                },
                onCameraMoveStarted: () {
                  setState(() => _followUser = false);
                },
              );
            },
            loading: () => GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: _defaultLocation,
                zoom: 12,
              ),
              mapType: _mapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              circles: _buildGeofenceCircles(geofences),
            ),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, color: TacticalColors.critical, size: 64),
                  const SizedBox(height: 16),
                  Text('Location Error', style: TacticalText.screenTitle.copyWith(color: TacticalColors.critical)),
                  const SizedBox(height: 8),
                  Text(e.toString(), style: TacticalText.cardSubtitle, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),

          // Search bar at top
          Positioned(
            top: 8,
            left: 16,
            right: 16,
            child: _buildSearchBar(),
          ),

          // Route info card
          if (_routeInfo != null)
            Positioned(
              top: 72,
              left: 16,
              right: 16,
              child: _buildRouteInfoCard(),
            ),

          // Status overlay at bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _buildStatusCard(positionAsync, locationState),
          ),
        ],
      ),
      // FAB to add geofence at current location
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGeofenceDialog,
        backgroundColor: TacticalColors.primary,
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: TacticalColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TacticalColors.border),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: TacticalColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search places...',
              hintStyle: TextStyle(color: TacticalColors.textDim),
              prefixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: TacticalColors.primary),
                      ),
                    )
                  : const Icon(Icons.search, color: TacticalColors.textDim),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: TacticalColors.textDim),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchResults = []);
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) {
              if (value.length > 2) {
                _searchPlaces(value);
              } else {
                setState(() => _searchResults = []);
              }
            },
          ),
        ),
        // Search results dropdown
        if (_searchResults.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: TacticalColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: TacticalColors.border),
            ),
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final result = _searchResults[index];
                return ListTile(
                  leading: const Icon(Icons.place, color: TacticalColors.primary),
                  title: Text(
                    result['main_text'],
                    style: const TextStyle(color: TacticalColors.textPrimary),
                  ),
                  subtitle: Text(
                    result['description'],
                    style: TextStyle(color: TacticalColors.textDim, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _selectPlace(result['place_id'], result['main_text']),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildRouteInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TacticalColors.primary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDestinationName ?? 'Destination',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  _routeInfo ?? '',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: _clearRoute,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(
    AsyncValue<DevicePosition> positionAsync,
    AsyncValue<LocationServiceState> stateAsync,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TacticalColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TacticalColors.border, width: 1),
      ),
      child: positionAsync.when(
        data: (position) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(_getActivityIcon(position.activity), color: TacticalColors.operational, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                        style: TacticalText.cardTitle.copyWith(fontFamily: 'monospace', color: TacticalColors.operational),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        position.zoneName ?? position.activity.name.toUpperCase(),
                        style: TacticalText.cardSubtitle.copyWith(color: TacticalColors.textDim),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getAccuracyColor(position.accuracy),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '±${position.accuracy?.toStringAsFixed(0) ?? '--'}m',
                    style: TacticalText.statusLabel(Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetricChip(icon: Icons.speed, value: _formatSpeed(position.speed)),
                const SizedBox(width: 8),
                _buildMetricChip(icon: Icons.explore, value: _formatHeading(position.heading)),
                const SizedBox(width: 8),
                _buildMetricChip(icon: Icons.height, value: position.altitude != null ? '${position.altitude!.toStringAsFixed(0)}m' : '--'),
              ],
            ),
          ],
        ),
        loading: () => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: TacticalColors.primary)),
            const SizedBox(width: 12),
            Text('Acquiring location...', style: TacticalText.cardSubtitle),
          ],
        ),
        error: (e, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: TacticalColors.critical, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text('Location unavailable', style: TacticalText.cardSubtitle.copyWith(color: TacticalColors.critical))),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({required IconData icon, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: TacticalColors.card, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: TacticalColors.textDim),
            const SizedBox(width: 4),
            Flexible(child: Text(value, style: TacticalText.statusLabel(TacticalColors.textPrimary), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  Color _getAccuracyColor(double? accuracy) {
    if (accuracy == null) return TacticalColors.textDim;
    if (accuracy <= 10) return TacticalColors.operational;
    if (accuracy <= 30) return TacticalColors.inProgress;
    if (accuracy <= 100) return TacticalColors.warning;
    return TacticalColors.critical;
  }

  // ==========================================================================
  // ADD GEOFENCE DIALOG
  // ==========================================================================

  void _showAddGeofenceDialog() {
    if (_lastPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for location...')),
      );
      return;
    }

    final nameController = TextEditingController();
    double radius = 100;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: TacticalColors.surface,
          title: const Text('Add Zone', style: TextStyle(color: TacticalColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: TacticalColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Zone Name',
                  labelStyle: TextStyle(color: TacticalColors.textDim),
                  hintText: 'Home, Work, Gym...',
                  hintStyle: TextStyle(color: TacticalColors.textDim.withValues(alpha: 0.5)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: TacticalColors.border)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: TacticalColors.primary)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Radius: ${radius.toInt()}m', style: TextStyle(color: TacticalColors.textDim)),
                ],
              ),
              Slider(
                value: radius,
                min: 50,
                max: 500,
                divisions: 9,
                activeColor: TacticalColors.primary,
                onChanged: (v) => setDialogState(() => radius = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: TacticalColors.textDim)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isEmpty) return;
                final geofence = Geofence(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text,
                  latitude: _lastPosition!.latitude,
                  longitude: _lastPosition!.longitude,
                  radius: radius,
                );
                ref.read(geofenceListNotifierProvider.notifier).addGeofence(geofence);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added zone: ${geofence.name}')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: TacticalColors.primary),
              child: const Text('Add Zone'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }
}
