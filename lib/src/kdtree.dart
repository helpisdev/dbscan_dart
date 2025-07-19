import 'package:meta/meta.dart';

import 'models/spatial_point.dart';
import 'quickselect.dart';

/// A node in a KD-Tree.
///
/// Each node contains a point and divides the space into two half-spaces.
/// Points with a smaller value in the splitting dimension go to the left child,
/// and points with a larger value go to the right child.
@immutable
class Node {
  /// Creates a new node with the specified point and children.
  const Node({required this.point, this.left, this.right});

  /// The point stored at this node.
  final SpatialPoint point;

  /// The left child of this node (points with smaller values in the splitting
  /// dimension).
  final Node? left;

  /// The right child of this node (points with larger values in the splitting
  /// dimension).
  final Node? right;
}

/// A KD-Tree (k-dimensional tree) for efficient spatial queries.
///
/// KD-Trees partition space into nested hyperrectangles, allowing for
/// efficient range searches and nearest neighbor queries. This implementation
/// is specifically optimized for the DBSCAN algorithm's range queries.
///
/// **Performance Optimizations:**
///
/// - **Construction:** Uses Floyd-Rivest quickselect for O(n log n) tree building
/// - **Memory Efficiency:** In-place partitioning eliminates list copying
/// - **Range Search:** Iterative implementation with squared distance comparisons
/// - **Pruning:** Dimension-specific radius conversion for optimal space pruning
///
/// The tree is built by recursively partitioning points along alternating
/// dimensions using the median as the split point. For example, in 2D space:
///
///   - The root node splits points by x-coordinate.
///   - The next level splits points by y-coordinate.
///   - The next level splits by x-coordinate again, and so on.
///
/// This structure allows for efficient pruning of the search space during
/// queries, achieving O(log n + k) range search complexity where k is the
/// number of points found.
@immutable
class KDTree {
  /// Creates a new KD-Tree with the specified root node and dimensionality.
  const KDTree({required this.root, required this.k});

  /// Creates a new k-d tree from a list of points.
  ///
  /// This factory method builds a balanced k-d tree from the provided points.
  /// The dimensionality of the tree is determined from the first point in the
  /// list.
  ///
  /// Parameters:
  ///
  ///   - [points]: The list of spatial points to include in the tree.
  ///
  /// Throws an [ArgumentError] if the points list is empty or if any point has
  /// a non-positive dimension value.
  factory KDTree.from(final List<SpatialPoint> points) {
    if (points.isEmpty) {
      return const KDTree(root: null, k: 0);
    }

    final int k = points[0].dimension();
    if (k <= 0) {
      throw ArgumentError('Dimension must be positive');
    }

    final List<SpatialPoint> mutablePoints = List<SpatialPoint>.from(points);
    final Node? root = _recursivelyBuild(
      mutablePoints,
      k,
      0,
      mutablePoints.length - 1,
      0,
    );
    return KDTree(root: root, k: k);
  }

  /// The root node of the tree.
  final Node? root;

  /// The number of dimensions in the space.
  final int k;

  /// Recursively builds a k-d tree from a list of points using quickSelect for
  /// partitioning.
  ///
  ///
  /// This version operates entirely in-place on the provided list segment,
  /// avoiding list copying for maximum performance.
  static Node? _recursivelyBuild(
    final List<SpatialPoint> points,
    final int k,
    final int start,
    final int end,
    final int depth,
  ) {
    if (start > end) {
      return null;
    }
    if (start == end) {
      return Node(point: points[start]);
    }

    final int axis = depth % k;
    final int medianIdx = start + (end - start) ~/ 2;

    quickSelect(
      points,
      medianIdx,
      start,
      end,
      (final SpatialPoint a, final SpatialPoint b) {
        return a.atDimension(axis).compareTo(b.atDimension(axis));
      },
    );

    final SpatialPoint medianPoint = points[medianIdx];

    final int d = depth + 1;
    final Node? l = _recursivelyBuild(points, k, start, medianIdx - 1, d);
    final Node? r = _recursivelyBuild(points, k, medianIdx + 1, end, d);

    return Node(point: medianPoint, left: l, right: r);
  }

  /// Performs an optimized range search around a query point.
  ///
  /// This method finds all points in the tree that are within the specified
  /// radius of the query point using an iterative approach with squared distance
  /// comparisons for maximum performance.
  ///
  /// **Performance:** O(log n + k) where k is the number of points found.
  ///
  /// Parameters:
  ///
  ///   - [queryPoint]: The center point of the search.
  ///   - [radius]: The maximum distance from the query point to include in
  ///     results.
  ///
  /// Returns a list of points within the specified radius of the query point.
  ///
  /// Throws an [ArgumentError] if the query point's dimension doesn't match
  /// the tree's.
  List<SpatialPoint> rangeSearch(
    final SpatialPoint queryPoint,
    final double radius,
  ) {
    if (root == null) {
      return <SpatialPoint>[];
    }

    if (queryPoint.dimension() != k) {
      throw ArgumentError(
        'Query point dimension (${queryPoint.dimension()}) '
        'does not match tree dimension ($k)',
      );
    }

    final List<SpatialPoint> results = _iterativeRS(
      queryPoint,
      radius,
    );

    return results;
  }

  List<SpatialPoint> _iterativeRS(final SpatialPoint p, final double r) {
    final List<SpatialPoint> results = <SpatialPoint>[];
    final List<(Node, int)> stack = <(Node, int)>[(root!, 0)];

    final double squaredRadiusThreshold = p.getSquaredRadiusThreshold(r);

    while (stack.isNotEmpty) {
      final (Node node, int depth) = stack.removeLast();
      final int axis = depth % k;

      final double pointAxisDimension = p.atDimension(axis);
      final double nodeAxisDimension = node.point.atDimension(axis);
      final double distSq = node.point.squaredDistanceComparisonValue(p);
      final double radius = p.convertRadiusToDimensionUnits(r, axis);

      if (distSq <= squaredRadiusThreshold) {
        results.add(node.point);
      }

      final int d = depth + 1;
      if (node.left != null) {
        if (pointAxisDimension <= nodeAxisDimension) {
          stack.add((node.left!, d));
        } else if (pointAxisDimension - radius <= nodeAxisDimension) {
          stack.add((node.left!, d));
        }
      }

      if (node.right != null) {
        if (pointAxisDimension >= nodeAxisDimension) {
          stack.add((node.right!, d));
        } else if (pointAxisDimension + radius >= nodeAxisDimension) {
          stack.add((node.right!, d));
        }
      }
    }

    return results;
  }
}
