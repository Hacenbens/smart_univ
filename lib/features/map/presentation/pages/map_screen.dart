import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/location_service.dart';
import 'package:smart_univ/core/services/permission_service.dart';

class _CampusPOI {
  final String name;
  final LatLng position;
  const _CampusPOI(this.name, this.position);
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centred on USTHB campus, Algiers
  static const _campusCenter = LatLng(36.7122, 3.1581);

  static const _pois = [
    _CampusPOI('Main Building', LatLng(36.7130, 3.1590)),
    _CampusPOI('Library', LatLng(36.7115, 3.1560)),
    _CampusPOI('Cafeteria', LatLng(36.7140, 3.1605)),
    _CampusPOI('Gymnasium', LatLng(36.7105, 3.1615)),
    _CampusPOI('Admin Office', LatLng(36.7125, 3.1545)),
  ];

  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _locationDenied = false;

  @override
  void initState() {
    super.initState();
    _buildPoiMarkers();
    _fetchUserLocation();
  }

  void _buildPoiMarkers() {
    for (final poi in _pois) {
      _markers.add(
        Marker(
          markerId: MarkerId(poi.name),
          position: poi.position,
          infoWindow: InfoWindow(title: poi.name),
        ),
      );
    }
  }

  Future<void> _fetchUserLocation() async {
    try {
      final position = await sl<LocationService>().getCurrentPosition();
      if (!mounted) return;
      final userLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _locationDenied = false;
        _markers
          ..removeWhere((m) => m.markerId.value == 'user_location')
          ..add(
            Marker(
              markerId: const MarkerId('user_location'),
              position: userLatLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
          );
      });
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 16),
      );
    } on PermissionException {
      if (!mounted) return;
      setState(() => _locationDenied = true);
      await _showLocationRationale();
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationDenied = true);
    }
  }

  Future<void> _showLocationRationale() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'SmartCampus needs your location to show where you are on the campus map.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await _fetchUserLocation();
  }

  Future<void> _onEnableLocationTapped() async {
    final result = await sl<PermissionService>().checkPermission(
      Permission.locationWhenInUse,
    );
    if (result == PermissionResult.permanentlyDenied) {
      if (!mounted) return;
      await sl<PermissionService>().showPermanentlyDeniedDialog(
        context,
        'Location',
      );
    } else {
      await _fetchUserLocation();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _campusCenter,
              zoom: 15,
            ),
            markers: Set.unmodifiable(_markers),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onMapCreated: (controller) => _mapController = controller,
          ),
          if (_locationDenied)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.extended(
                  onPressed: _onEnableLocationTapped,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Enable Location'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
