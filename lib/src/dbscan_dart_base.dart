import 'kdtree.dart';
import 'models/cluster_id.dart';
import 'models/cluster_label.dart';
import 'models/clustering_result.dart';
import 'models/point_id.dart';
import 'models/spatial_point.dart';

/// DBSCAN (Density-Based Spatial Clustering of Applications with Noise) is a
/// clustering algorithm designed to discover clusters of arbitrary shape in
/// spatial data.
///
/// Key concepts:
///
///   - Core points: Points with at least [minPoints] neighbors within [eps]
///     distance.
///   - Border points: Points within [eps] distance of a core point but with
///     fewer neighbors than [minPoints].
///   - Noise points: Points that are neither core nor border points
///
/// The algorithm works by:
///
///   1. Finding all core points and their neighborhoods.
///   2. Connecting core points that are within [eps] distance of each other.
///   3. Forming clusters from connected core points and their border points.
///   4. Labeling remaining points as noise.
///
/// DBSCAN is particularly useful for:
///
///   - Spatial data analysis (GIS, location clustering).
///   - Outlier detection.
///   - Clustering without specifying the number of clusters in advance.
///   - Datasets with clusters of varying shapes and densities.
///
/// Unlike k-means, DBSCAN:
///
///   - Doesn't require specifying the number of clusters.
///   - Can find arbitrarily shaped clusters.
///   - Can identify noise points.
///   - Is less sensitive to outliers.
class DBScan {
  /// Creates a new DBScan instance with the specified parameters.
  ///
  /// Parameters:
  ///
  /// - [eps]: The maximum distance (epsilon) between two points for them to be
  ///   considered neighbors.
  ///
  ///   This parameter defines the neighborhood radius around each point.
  ///     - Smaller values create more, smaller clusters and more noise points.
  ///     - Larger values create fewer, larger clusters with less noise.
  ///     - The appropriate value depends on the scale and density of your data.
  ///     - For geographic data, this is typically measured in meters.
  ///
  /// - [minPoints]: The minimum number of points required to form a dense
  ///   region (cluster).
  ///     - Higher values create more significant clusters and more noise
  ///       points.
  ///     - Lower values create more clusters with fewer points each.
  ///     - Typically set to at least dimension + 1 (e.g., 3 for 2D data).
  ///     - For large datasets, consider using higher values (5-10).
  const DBScan({required this.eps, required this.minPoints});

  /// The maximum distance between two points to be considered neighbors.
  final double eps;

  /// The minimum number of points required to form a dense region.
  final int minPoints;

  /// Performs DBSCAN clustering on a set of points.
  ///
  /// Parameters:
  ///
  /// - [points]: The collection of points to cluster. Each point must implement
  ///   the [SpatialPoint] interface.
  ///
  /// Returns a [ClusteringResult] containing:
  ///
  /// - Mapping of cluster IDs to lists of points in each cluster.
  /// - Mapping of point IDs to their assigned cluster labels.
  ///
  /// Points labeled as [ClusterLabel.noise] are considered noise (not part of
  /// any cluster).
  ClusteringResult run({required final List<SpatialPoint> points}) {
    if (points.isEmpty) {
      return const ClusteringResult(
        clusters: <ClusterId, List<SpatialPoint>>{},
        labels: <PointId, ClusterLabel>{},
      );
    }

    final Map<PointId, ClusterLabel> labels = <PointId, ClusterLabel>{};
    final Map<ClusterId, List<SpatialPoint>> clusters =
        <ClusterId, List<SpatialPoint>>{};

    // Initialize all points as undefined
    for (final SpatialPoint point in points) {
      labels[point.id()] = ClusterLabel.undefined;
    }

    // Build KD-tree for efficient range queries
    final KDTree kdTree = KDTree.from(points);
    ClusterId clusterID = const ClusterId(1);

    // Process each point
    for (final SpatialPoint point in points) {
      // Skip already processed points
      if (labels[point.id()] != ClusterLabel.undefined) {
        continue;
      }

      // Find neighbors
      final List<SpatialPoint> neighbors = kdTree.rangeSearch(point, eps);

      // Check if this is a core point
      if (neighbors.length < minPoints) {
        // Mark as noise for now (might become a border point later)
        labels[point.id()] = ClusterLabel.noise;
        continue;
      }

      final ClusterLabel currentClusterLabel = ClusterLabel.fromClusterId(
        clusterID,
      );
      clusters[clusterID] = <SpatialPoint>[];

      // Add current point to cluster
      labels[point.id()] = currentClusterLabel;
      clusters[clusterID]!.add(point);

      // Process neighbors (seed set expansion)
      final List<SpatialPoint> seedSet = <SpatialPoint>[...neighbors]
        ..remove(point);

      while (seedSet.isNotEmpty) {
        final SpatialPoint currentPoint = seedSet.removeAt(0);
        final PointId currentID = currentPoint.id();

        // Skip already processed points (except noise, which can be "rescued")
        if (labels[currentID] != ClusterLabel.undefined &&
            labels[currentID] != ClusterLabel.noise) {
          continue;
        }

        // Mark point as part of current cluster
        labels[currentID] = currentClusterLabel;
        clusters[clusterID]!.add(currentPoint);

        // Find neighbors of this point
        final List<SpatialPoint> pointNeighbors = kdTree.rangeSearch(
          currentPoint,
          eps,
        );

        // If this is a core point, add its neighbors to the seed set
        if (pointNeighbors.length >= minPoints) {
          for (final SpatialPoint neighbor in pointNeighbors) {
            if (labels[neighbor.id()] == ClusterLabel.undefined ||
                labels[neighbor.id()] == ClusterLabel.noise) {
              if (!seedSet.contains(neighbor)) {
                seedSet.add(neighbor);
              }
            }
          }
        }
      }

      clusterID = ClusterId(clusterID.value + 1);
    }

    return ClusteringResult(clusters: clusters, labels: labels);
  }
}
