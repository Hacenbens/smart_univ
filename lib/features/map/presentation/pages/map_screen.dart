import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_univ/core/di/injection_container.dart';
import 'package:smart_univ/core/error/app_exception.dart';
import 'package:smart_univ/core/services/location_service.dart';
import 'package:smart_univ/core/services/permission_lifecycle_mixin.dart';
import 'package:smart_univ/core/services/permission_service.dart';
import 'package:smart_univ/core/widgets/rationale_dialog.dart';

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

class _MapScreenState extends State<MapScreen>
    with WidgetsBindingObserver, PermissionLifecycleMixin<MapScreen> {
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

  // ── PermissionLifecycleMixin contract ──────────────────────────────────────

  @override
  Permission get observedPermission => Permission.locationWhenInUse;

  @override
  PermissionService get permissionService => sl<PermissionService>();

  @override
  void onPermissionStatusChanged(PermissionResult result) {
    if (result == PermissionResult.granted) {
      _fetchUserLocation();
    } else {
      setState(() => _locationDenied = true);
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState(); // mixin registers WidgetsBindingObserver
    _buildPoiMarkers();
    _fetchUserLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose(); // mixin removes WidgetsBindingObserver
  }

  // ── Location logic ─────────────────────────────────────────────────────────

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
      _showLocationRationale();
    } catch (_) {
      if (!mounted) return;
      setState(() => _locationDenied = true);
    }
  }

  void _showLocationRationale() {
    showDialog<void>(
      context: context,
      builder: (ctx) => RationaleDialog(
        title: 'Location Permission',
        body: 'SmartCampus needs your location to show where you are on the campus map.',
        allowLabel: 'Continue',
        onAllow: () {
          Navigator.of(ctx).pop();
          _fetchUserLocation();
        },
        onDeny: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  Future<void> _onEnableLocationTapped() async {
    final result = await sl<PermissionService>().checkPermission(
      Permission.locationWhenInUse,
    );
    if (!mounted) return;
    if (result == PermissionResult.permanentlyDenied ||
        result == PermissionResult.restricted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => RationaleDialog(
          title: 'Location Access Blocked',
          body: 'Location access was permanently denied. Enable it in Settings to see your position on the campus map.',
          allowLabel: 'Open Settings',
          denyLabel: 'Cancel',
          onAllow: () {
            Navigator.of(ctx).pop();
            sl<PermissionService>().openSettings();
          },
          onDeny: () => Navigator.of(ctx).pop(),
        ),
      );
    } else {
      await _fetchUserLocation();
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

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
