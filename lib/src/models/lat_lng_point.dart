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

  static const double earthRadius = 6371000;
  static const double degToRad = math.pi / 180;
  static const double radToDeg = 180 / math.pi;

  @override
  PointId id() => pointId;

  /// Calculates the actual Haversine distance in meters.
  @override
  double distanceTo(final SpatialPoint other) {
    if (other is! LatLngPoint) {
      throw ArgumentError('Cannot calculate distance to non-LatLngPoint');
    }
    return _calculateHaversineDistance(other);
  }

  /// Calculates a value proportional to the squared Haversine distance.
  ///
  /// This method is used for efficient distance comparisons, especially in
  /// spatial indexing structures like KD-Trees, where avoiding the final
  /// square root operation can provide significant performance benefits.
  /// The returned value is the squared 'c' factor from the Haversine formula.
  @override
  double squaredDistanceComparisonValue(final SpatialPoint other) {
    if (other is! LatLngPoint) {
      throw ArgumentError(
        'Cannot calculate squared distance to non-LatLngPoint',
      );
    }
    return _calculateSquaredHaversineFactor(other);
  }

  /// Converts a given radius (in meters) into a squared threshold value
  /// suitable for comparison with [squaredDistanceComparisonValue].
  ///
  /// For Haversine, this is (radius / earthRadius)^2.
  @override
  double getSquaredRadiusThreshold(final double radius) {
    return (radius / earthRadius) * (radius / earthRadius);
  }

  /// Converts a given radius (in meters) into units appropriate for
  /// a specific dimension (degrees of latitude or longitude).
  ///
  /// This method calculates the maximum angular displacement (in degrees)
  /// along a specific dimension for a given radius from the current point.
  /// This is crucial for the pruning logic within KD-Trees.
  @override
  double convertRadiusToDimensionUnits(
    final double radius,
    final int dimensionIndex,
  ) {
    final double currentLatRad = lat * degToRad;

    switch (dimensionIndex) {
      // Longitude (dim 0)
      case 0:
        // Convert meters to degrees of longitude at this latitude.
        // This is a common approximation for KD-Tree pruning.
        // It's radius / (circumference_at_latitude / 360)
        // = radius / (2 * PI * R * cos(lat_rad) / 360)
        // = (radius * 180) / (PI * R * cos(lat_rad))
        // = (radius / (R * cos(lat_rad))) * radToDeg
        final double cosLat = math.cos(currentLatRad);
        // Handle poles: at poles, a small radius covers all longitudes.
        // cosLat can be very close to zero.
        if (cosLat.abs() < 1e-10) {
          // If near poles, longitude can be anything
          // Max possible longitude difference for pruning
          return 180;
        }
        return (radius / (earthRadius * cosLat)) * radToDeg;
      // Latitude (dim 1)
      case 1:
        // Convert meters to degrees of latitude (approx. constant)
        // Formula: delta_lat_rad = radius_meters / earth_radius_meters
        final double deltaLatRad = radius / earthRadius;
        return deltaLatRad * radToDeg;
      default:
        throw ArgumentError(
          'Invalid dimension index: $dimensionIndex for LatLngPoint',
        );
    }
  }

  double _calculateHaversineDistance(final LatLngPoint other) {
    return earthRadius * _haversine(other);
  }

  double _calculateSquaredHaversineFactor(final LatLngPoint other) {
    final double c = _haversine(other);
    return c * c;
  }

  double _haversine(final LatLngPoint other) {
    final double lat1Rad = lat * degToRad;
    final double lat2Rad = other.lat * degToRad;
    final double dLatRad = (other.lat - lat) * degToRad;
    final double dLngRad = (other.lng - lng) * degToRad;

    final double sinDLatDiv2 = math.sin(dLatRad / 2);
    final double sinDLngDiv2 = math.sin(dLngRad / 2);

    final double a = sinDLatDiv2 * sinDLatDiv2 +
        math.cos(lat1Rad) * math.cos(lat2Rad) * sinDLngDiv2 * sinDLngDiv2;

    final double clampedA = a.clamp(0, 1);

    final double c = 2 *
        math.atan2(
          math.sqrt(clampedA),
          math.sqrt(1 - clampedA),
        );
    return c;
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

  @override
  bool operator ==(final Object other) {
    if (other is SpatialPoint) {
      return id() == other.id();
    }
    return false;
  }

  @override
  int get hashCode => id().hashCode;
}
