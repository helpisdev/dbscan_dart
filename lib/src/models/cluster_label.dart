import 'package:meta/meta.dart';

import 'cluster_id.dart';
import 'point_id.dart';

/// Represents a cluster label in DBSCAN results.
///
/// This class wraps an integer label value and provides constants for
/// special label types (undefined and noise).
@immutable
class ClusterLabel {
  /// Creates a new cluster label with the specified value.
  const ClusterLabel(this.value);

  /// Creates a cluster label for a specific cluster ID.
  ClusterLabel.fromClusterId(final ClusterId id) : value = id.value;

  /// The integer value of this label.
  final int value;

  /// Undefined label for points not yet processed.
  static const ClusterLabel undefined = ClusterLabel(0);

  /// Noise label for points that don't belong to any cluster.
  static const ClusterLabel noise = ClusterLabel(-1);

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ClusterLabel &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ClusterLabel($value)';
}

/// Type alias for a map entry in the clustering result.
typedef ClusterLabelEntry = MapEntry<PointId, ClusterLabel>;
