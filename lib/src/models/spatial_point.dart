import 'package:meta/meta.dart';

import 'point_id.dart';

/// A spatial point interface for high-performance clustering algorithms.
///
/// This interface defines the essential properties and behaviors required for
/// points to be used in spatial clustering algorithms like DBSCAN.
/// Implementations must provide:
///
///   1. A unique identifier ([id]).
///   2. Distance calculation methods ([distanceTo], [squaredDistanceComparisonValue]).
///   3. Radius conversion methods for spatial indexing optimization.
///   4. Information about the point's dimensionality ([dimension] and [atDimension]).
///
/// **Performance Optimizations:**
///
/// The interface includes specialized methods for spatial indexing performance:
/// - [squaredDistanceComparisonValue] avoids expensive sqrt operations
/// - [getSquaredRadiusThreshold] converts radius to squared comparison values
/// - [convertRadiusToDimensionUnits] enables efficient KD-Tree pruning
///
/// The dimensionality methods are particularly important for spatial indexing
/// structures like KD-Trees, which need to partition space along different
/// dimensions.
///
/// For example:
///
/// - A 2D point would return 2 from [dimension] and provide x,y coordinates via
///   [atDimension].
/// - A 3D point would return 3 from [dimension] and provide x,y,z coordinates
///   via [atDimension].
/// - A geographic point might still return 2 but use longitude/latitude as its
///   dimensions.
@immutable
abstract class SpatialPoint {
  /// Returns the point's unique identifier.
  ///
  /// This ID should be unique within the dataset being clustered to ensure
  /// correct tracking of cluster assignments.
  PointId id();

  /// Calculates the distance to another point.
  ///
  /// This method defines the distance metric used by the clustering algorithm.
  /// Different implementations can use different distance metrics:
  ///
  ///   - Euclidean distance for standard spatial points.
  ///   - Manhattan distance for grid-based applications.
  ///   - Haversine formula for geographic coordinates.
  ///   - Custom domain-specific distance metrics.
  ///
  /// The choice of distance metric significantly affects clustering results.
  double distanceTo(final SpatialPoint other);

  /// Calculates a value proportional to the squared distance to another point.
  ///
  /// This method is used for efficient distance comparisons, especially in
  /// spatial indexing structures like KD-Trees, where avoiding the final
  /// square root operation can provide significant performance benefits.
  /// The returned value should be monotonically increasing with the actual
  /// distance.
  ///
  /// For Euclidean distance, this would be the squared Euclidean distance.
  /// For Haversine, this would be the squared 'c' factor (before multiplying by
  /// earthRadius).
  double squaredDistanceComparisonValue(final SpatialPoint other);

  /// Converts a given radius (e.g., in meters) into a squared threshold value
  /// suitable for comparison with [squaredDistanceComparisonValue].
  ///
  /// This allows the KD-Tree to perform distance checks without needing
  /// to know the specific distance metric or its scaling factors.
  double getSquaredRadiusThreshold(final double radius);

  /// Converts a given radius (e.g., in meters) into units appropriate for
  /// a specific dimension.
  ///
  /// This is crucial for the pruning logic within KD-Trees, where comparisons
  /// are made along individual axes. For geographic coordinates, this might
  /// involve converting meters to degrees of latitude or longitude.
  double convertRadiusToDimensionUnits(
    final double radius,
    final int dimensionIndex,
  );

  /// Returns the number of dimensions of this point.
  ///
  /// This value is used by spatial indexing structures to determine how to
  /// partition the space. For example:
  ///
  ///   - 2 for 2D points (x,y).
  ///   - 3 for 3D points (x,y,z).
  ///   - Higher values for higher-dimensional data.
  ///
  /// The dimensionality must be consistent across all points in a dataset.
  int dimension();

  /// Returns the value at the specified dimension.
  ///
  /// This method provides access to the point's coordinate in a specific
  /// dimension. For a 2D point:
  ///
  ///   - dimension 0 might return the x-coordinate.
  ///   - dimension 1 might return the y-coordinate.
  ///
  /// For geographic points:
  ///
  ///   - dimension 0 might return longitude.
  ///   - dimension 1 might return latitude.
  ///
  /// The dimension parameter must be between 0 and [dimension]-1, inclusive.
  double atDimension(final int d);

  @override
  bool operator ==(final Object other);

  @override
  int get hashCode;
}
