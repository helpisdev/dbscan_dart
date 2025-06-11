import 'dart:math' as math;

import 'package:meta/meta.dart';

import 'point_id.dart';
import 'spatial_point.dart';

/// A geographical point implementation for DBSCAN.
@immutable
class LatLngPoint implements SpatialPoint {
  /// Creates a new LatLngPoint instance.
  const LatLngPoint({
    required this.pointId,
    required this.lat,
    required this.lng,
    this.info,
  });

  /// The point's unique identifier.
  final PointId pointId;

  /// Latitude coordinate.
  final double lat;

  /// Longitude coordinate.
  final double lng;

  /// Optional information about the point.
  final String? info;

  @override
  PointId id() => pointId;

  @override
  double distanceTo(final SpatialPoint other) {
    if (other is! LatLngPoint) {
      throw ArgumentError('Cannot calculate distance to non-LatLngPoint');
    }

    // Calculate Haversine distance (distance on a sphere)
    const double earthRadius = 6371000; // in meters
    final double lat1 = lat * math.pi / 180;
    final double lat2 = other.lat * math.pi / 180;
    final double dLat = (other.lat - lat) * math.pi / 180;
    final double dLng = (other.lng - lng) * math.pi / 180;

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c; // Distance in meters
  }

  @override
  int dimension() => 2;

  @override
  double atDimension(final int d) {
    return switch (d) {
      0 => lng,
      1 => lat,
      _ => throw ArgumentError('Invalid dimension: $d'),
    };
  }

  @override
  String toString() => 'LatLngPoint(id: $pointId, lat: $lat, lng: $lng)';
}
