import 'package:meta/meta.dart';

import 'models/spatial_point.dart';

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
/// The tree is built by recursively partitioning points along alternating
/// dimensions. For example, in 2D space:
///
///   - The root node splits points by x-coordinate.
///   - The next level splits points by y-coordinate.
///   - The next level splits by x-coordinate again, and so on.
///
/// This structure allows for efficient pruning of the search space during
/// queries.
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

    final Node? root = _recursivelyBuild(List<SpatialPoint>.from(points), 0, k);
    return KDTree(root: root, k: k);
  }

  /// The root node of the tree.
  final Node? root;

  /// The number of dimensions in the space.
  final int k;

  /// Recursively builds a k-d tree from a list of points.
  static Node? _recursivelyBuild(
    final List<SpatialPoint> points,
    final int depth,
    final int k,
  ) {
    if (points.isEmpty) {
      return null;
    }

    final int axis = depth % k;

    // Sort points by the current axis
    points.sort((final SpatialPoint a, final SpatialPoint b) {
      return a.atDimension(axis).compareTo(b.atDimension(axis));
    });

    // Get median point
    final int medianIdx = points.length ~/ 2;
    final SpatialPoint medianPoint = points[medianIdx];

    // Create node and recursively build subtrees
    return Node(
      point: medianPoint,
      left: _recursivelyBuild(points.sublist(0, medianIdx), depth + 1, k),
      right: _recursivelyBuild(points.sublist(medianIdx + 1), depth + 1, k),
    );
  }

  /// Performs a range search around a query point.
  ///
  /// This method finds all points in the tree that are within the specified
  /// radius of the query point.
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

    return _recursiveRangeSearch(root, queryPoint, radius, 0);
  }

  /// Recursively searches for points within the specified radius.
  ///
  /// This is a helper method for [rangeSearch] that traverses the tree
  /// recursively.
  ///
  /// Parameters:
  ///
  ///   - [node]: The current node being examined.
  ///   - [queryPoint]: The center point of the search.
  ///   - [radius]: The search radius.
  ///   - [depth]: The current depth in the tree, used to determine the
  ///     splitting dimension.
  List<SpatialPoint> _recursiveRangeSearch(
    final Node? node,
    final SpatialPoint queryPoint,
    final double radius,
    final int depth,
  ) {
    final List<SpatialPoint> results = <SpatialPoint>[];
    if (node == null) {
      return results;
    }

    final int axis = depth % k;

    // Check if current node's point is within radius
    if (node.point.distanceTo(queryPoint) <= radius) {
      results.add(node.point);
    }

    // Determine which subtree(s) to search
    final double axisDistance =
        queryPoint.atDimension(axis) - node.point.atDimension(axis);

    if (axisDistance <= 0) {
      // Query point is on the left side, so we must search left subtree
      results.addAll(
        _recursiveRangeSearch(node.left, queryPoint, radius, depth + 1),
      );

      // Only search right subtree if it could contain points within radius
      if (axisDistance.abs() <= radius) {
        results.addAll(
          _recursiveRangeSearch(node.right, queryPoint, radius, depth + 1),
        );
      }
    } else {
      // Query point is on the right side, so we must search right subtree
      results.addAll(
        _recursiveRangeSearch(node.right, queryPoint, radius, depth + 1),
      );

      // Only search left subtree if it could contain points within radius
      if (axisDistance <= radius) {
        results.addAll(
          _recursiveRangeSearch(node.left, queryPoint, radius, depth + 1),
        );
      }
    }

    return results;
  }
}
