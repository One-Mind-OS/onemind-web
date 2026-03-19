import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/asset_service.dart';

/// Sensors Screen - Real-time Sensor Data - LIVE DATA
class SensorsScreen extends ConsumerStatefulWidget {
  final bool embedded;
  const SensorsScreen({super.key, this.embedded = false});

  @override
  ConsumerState<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends ConsumerState<SensorsScreen> {
  final AssetService _assetService = AssetService();
  List<Asset> _sensors = [];
  bool _loading = true;
  StreamSubscription<AssetTelemetry>? _telemetrySub;

  @override
  void initState() {
    super.initState();
    _loadSensors();
    _subscribeTelemetry();
  }

  @override
  void dispose() {
    _telemetrySub?.cancel();
    super.dispose();
  }

  Future<void> _loadSensors() async {
    setState(() => _loading = true);
    final sensors = await _assetService.fetchAssets(assetType: 'device');
    if (mounted) {
      setState(() {
        _sensors = sensors;
        _loading = false;
      });
    }
  }

  void _subscribeTelemetry() {
    _assetService.connectTelemetry(clientId: 'sensors-screen');
    _telemetrySub = _assetService.telemetryStream.listen((telemetry) {
      // Update sensor in list
      final index = _sensors.indexWhere((s) => s.id == telemetry.assetId);
      if (index != -1 && mounted) {
        setState(() {
          // Update telemetry data
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final accentGreen = const Color(0xFF4ADE80);

    final content = _loading
        ? Center(child: CircularProgressIndicator(color: accentGreen))
        : _sensors.isEmpty
            ? Center(child: Text('No sensors registered'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _sensors.length,
                itemBuilder: (ctx, i) {
                  final sensor = _sensors[i];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sensors, color: accentGreen, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  sensor.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text('Status: ${sensor.status}', style: const TextStyle(fontSize: 12)),
                          if (sensor.telemetry?.batteryLevel != null)
                            Text('Battery: ${sensor.telemetry!.batteryLevel!.toInt()}%', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              );

    if (widget.embedded) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: content,
        floatingActionButton: FloatingActionButton(
          onPressed: _loadSensors,
          backgroundColor: accentGreen,
          mini: true,
          child: Icon(Icons.refresh, color: Colors.black),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors'),
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: accentGreen), onPressed: _loadSensors),
        ],
      ),
      body: content,
    );
  }
}
