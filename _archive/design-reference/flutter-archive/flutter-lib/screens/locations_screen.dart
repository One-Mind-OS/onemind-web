import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_service.dart';

/// Locations Screen - Zones, Buildings, Areas - REAL DATA
class LocationsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const LocationsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  final AssetService _assetService = AssetService();
  List<Asset> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _loading = true);
    final locations = await _assetService.fetchAssets(assetType: 'location');
    if (mounted) {
      setState(() {
        _locations = locations;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentGreen = const Color(0xFF4ADE80);

    final content = _loading
        ? Center(child: CircularProgressIndicator(color: accentGreen))
        : _locations.isEmpty
            ? Center(child: Text('No locations registered'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _locations.length,
                itemBuilder: (ctx, i) => Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on, color: accentGreen),
                    title: Text(_locations[i].name),
                    subtitle: Text(_locations[i].status),
                    trailing: _locations[i].location != null
                        ? Text('${_locations[i].location!.latitude.toStringAsFixed(2)}, ${_locations[i].location!.longitude.toStringAsFixed(2)}')
                        : null,
                  ),
                ),
              );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: _loadLocations,
          backgroundColor: accentGreen,
          mini: true,
          child: Icon(Icons.refresh, color: Colors.black),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: accentGreen), onPressed: _loadLocations),
        ],
      ),
      body: content,
    );
  }
}
