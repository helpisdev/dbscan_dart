import 'package:meta/meta.dart';

import 'cluster_id.dart';
import 'cluster_label.dart';
import 'point_id.dart';
import 'spatial_point.dart';

/// Result of the DBSCAN clustering algorithm.
@immutable
class ClusteringResult {
  /// Creates a new ClusteringResult instance.
  const ClusteringResult({required this.clusters, required this.labels});

  /// Map of cluster IDs to lists of points in each cluster.
  final Map<ClusterId, List<SpatialPoint>> clusters;

  /// Map of point IDs to their assigned cluster labels.
  final Map<PointId, ClusterLabel> labels;
}

/// Type alias for a map entry in the clustering result.
typedef ClusteringResultEntry = MapEntry<ClusterId, List<SpatialPoint>>;
