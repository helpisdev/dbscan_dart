import 'dart:async';
import 'dart:math';

import 'package:dbscan_dart/dbscan_dart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'extensions.dart';
import 'points.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

class MapsScreenState extends State<MapsScreen> {
  late final GoogleMapController _controller;

  static const CameraPosition _initialPosition = CameraPosition(
    target: donwtownSanFransisco,
    zoom: 12,
  );

  // Markers and clusters
  final Set<Marker> _markers = <Marker>{};
  final List<LatLngPoint> _points = points;

  // Minimum points required for a cluster
  static const int _minPoints = 3;
  // Clustering radius, in meters
  static const double _clusteringRadius = 500;
  // Clustering radius minimum, in meters
  static const double _minRadius = 5;
  // Clustering radius maximum, in meters
  static const double _maxRadius = 15000;
  // Aggressive scaling factor - each zoom level change multiplies/divides
  // by this factor
  static const double _aggressiveScaling = 2.5;
  // Reference zoom level (around city level view)
  static const double _referenceZoom = 12;
  double _currentZoom = _referenceZoom;

  Timer? _clusteringDebouncer;
  bool _isClusteringInProgress = false;
  Timer? _zoomAdjustmentDebouncer;

  /// Calculates an adjusted radius for clustering based on the current zoom
  /// level.
  ///
  /// Returns an adjusted radius that grows exponentially when zooming out
  /// and shrinks exponentially when zooming in.
  double _calculateAdjustedRadius() {
    // Calculate the zoom difference from reference
    final double zoomDifference = _referenceZoom - _currentZoom;
    // Apply exponential scaling based on zoom difference
    // Positive zoomDifference (zoomed out) = larger radius
    // Negative zoomDifference (zoomed in) = smaller radius
    final num scaleFactor = pow(_aggressiveScaling, zoomDifference);
    final double adjustedRadius = _clusteringRadius * scaleFactor;
    return adjustedRadius.clamp(_minRadius, _maxRadius);
  }

  Future<void> _performClustering() async {
    // Skip if already in progress
    if (_isClusteringInProgress) {
      return;
    }

    // Cancel any pending debounced operations
    _clusteringDebouncer?.cancel();

    // Debounce clustering operations
    _clusteringDebouncer = Timer(
      const Duration(milliseconds: 300),
      () async {
        try {
          _isClusteringInProgress = true;
          _markers.clear();

          final double eps = _calculateAdjustedRadius();
          final DBScan dbscan = DBScan(eps: eps, minPoints: _minPoints);
          final ClusteringResult result = dbscan.run(points: _points);

          if (mounted) {
            setState(() => _addMarkers(result));
          }
        } finally {
          _isClusteringInProgress = false;
        }
      },
    );
  }

  void _addMarkers(final ClusteringResult result) {
    for (final ClusteringResultEntry entry in result.clusters.entries) {
      final int id = entry.key.value;
      final List<LatLngPoint> points = entry.value.cast<LatLngPoint>();

      // Calculate the centroid of all points in the cluster
      double avgLat = 0;
      double avgLng = 0;

      for (final LatLngPoint point in points) {
        avgLat += point.lat;
        avgLng += point.lng;
      }

      avgLat /= points.length;
      avgLng /= points.length;

      // Choose marker color based on cluster size
      double hue;
      if (points.length > 20) {
        hue = BitmapDescriptor.hueAzure; // Large clusters
      } else if (points.length > 10) {
        hue = BitmapDescriptor.hueOrange; // Medium clusters
      } else if (points.length > 5) {
        hue = BitmapDescriptor.hueYellow; // Small clusters
      } else if (points.length > 1) {
        hue = BitmapDescriptor.hueGreen; // Very small clusters
      } else {
        hue = BitmapDescriptor.hueRed; // Single points
      }

      _markers.add(
        Marker(
          markerId: MarkerId('cluster_$id'),
          position: LatLng(avgLat, avgLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: 'Cluster $id',
            snippet: 'Points: ${points.length}',
          ),
        ),
      );
    }

    // Process noise points
    for (final ClusterLabelEntry entry in result.labels.entries) {
      final PointId id = entry.key;
      final ClusterLabel label = entry.value;

      if (label == ClusterLabel.noise) {
        final LatLngPoint point = _points.firstWhere(
          (final LatLngPoint p) => p.id() == id,
        );
        _markers.add(
          Marker(
            markerId: MarkerId('noise_${id.value}'),
            position: LatLng(point.lat, point.lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRose,
            ),
            infoWindow: InfoWindow(
              title: 'Noise Point ${id.value}',
              snippet: point.info,
            ),
          ),
        );
      }
    }
  }

  Future<void> _onMapCreated(final GoogleMapController controller) async {
    _controller = controller;
    await _performClustering();
  }

  Future<void> _onCameraMove(final CameraPosition position) async {
    // Clamp zoom level to multiples of 0.5 using the extension
    final double clampedZoom = position.zoom.roundWithStep(0.5);

    if (clampedZoom != _currentZoom) {
      _currentZoom = clampedZoom;
      WidgetsBinding.instance.addPostFrameCallback(
        (final _) async => _performClustering(),
      );

      // Cancel any pending zoom adjustment
      _zoomAdjustmentDebouncer?.cancel();

      // Set up a new debounced zoom adjustment
      _zoomAdjustmentDebouncer = Timer(
        const Duration(milliseconds: 500),
        () async {
          await _controller.animateCamera(
            CameraUpdate.zoomTo(clampedZoom),
          );
        },
      );
    }
  }

  Future<void> _zoomIn() async {
    await _controller.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    await _controller.animateCamera(CameraUpdate.zoomOut());
  }

  @override
  void dispose() {
    _clusteringDebouncer?.cancel();
    _zoomAdjustmentDebouncer?.cancel();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DBSCAN Maps Clustering'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            onCameraMove: _onCameraMove,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: _zoomIn,
            heroTag: 'zoom_in',
            mini: true,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            onPressed: _zoomOut,
            heroTag: 'zoom_out',
            mini: true,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }
}
