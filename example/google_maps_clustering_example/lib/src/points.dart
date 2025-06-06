import 'dart:math';

import 'package:dbscan_dart/dbscan_dart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'extensions.dart';

const LatLng donwtownSanFransisco = LatLng(37.7749, -122.4194);
const LatLng northBeach = LatLng(37.8025, -122.4382);
const LatLng goldenGatePark = LatLng(37.7694, -122.4862);
const LatLng missionDistrict = LatLng(37.7583, -122.3786);
const LatLng chinatown = LatLng(37.7879, -122.4074);

List<LatLngPoint> _generatePoints() {
  final List<LatLngPoint> points = <LatLngPoint>[];
  // Generate points around San Francisco with some clusters
  final Random random = Random();

  // Create several dense clusters
  points
    ..addAll(
      _createCluster(
        donwtownSanFransisco,
        50,
        0.002,
        points.length,
      ),
    )
    ..addAll(
      _createCluster(
        northBeach,
        40,
        0.001,
        points.length,
      ),
    )
    ..addAll(
      _createCluster(
        goldenGatePark,
        30,
        0.0015,
        points.length,
      ),
    )
    ..addAll(
      _createCluster(
        missionDistrict,
        35,
        0.0018,
        points.length,
      ),
    )
    ..addAll(
      _createCluster(
        chinatown,
        25,
        0.001,
        points.length,
      ),
    );

  // Add some scattered points
  for (int i = 0; i < 100; i++) {
    final double randLat = (random.nextDouble() - 0.5) * 0.1;
    final double randLng = (random.nextDouble() - 0.5) * 0.1;
    final double lat = donwtownSanFransisco.latitude + randLat;
    final double lng = donwtownSanFransisco.longitude + randLng;
    points.add(
      LatLngPoint(
        pointId: PointId(100 + i),
        lat: lat,
        lng: lng,
        info: 'Random Point ${100 + i}',
      ),
    );
  }

  return points;
}

List<LatLngPoint> _createCluster(
  final LatLng center,
  final int numPoints,
  final double spread,
  final int startId,
) {
  final Random random = Random();
  final List<LatLngPoint> points = <LatLngPoint>[];

  for (int i = 0; i < numPoints; i++) {
    // Create points with Gaussian distribution around center
    final double lat = center.latitude + (random.nextGaussian() * spread);
    final double lng = center.longitude + (random.nextGaussian() * spread);

    points.add(
      LatLngPoint(
        pointId: PointId(startId + i),
        lat: lat,
        lng: lng,
        info: 'Cluster Point ${startId + i}',
      ),
    );
  }

  return points;
}

final List<LatLngPoint> points = _generatePoints();
