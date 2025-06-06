import 'point_id.dart';

/// A spatial point interface for clustering algorithms.
///
/// This interface defines the essential properties and behaviors required for
/// points to be used in spatial clustering algorithms like DBSCAN.
/// Implementations must provide:
///
///   1. A unique identifier ([id]).
///   2. A way to calculate distance between points ([distanceTo]).
///   3. Information about the point's dimensionality ([dimension] and
///      [atDimension]).
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
}
