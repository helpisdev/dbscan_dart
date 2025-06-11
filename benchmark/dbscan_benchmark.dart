import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:dbscan_dart/dbscan_dart.dart';

class DBScanBenchmark extends BenchmarkBase {
  /// Creates a new DBScanBenchmark instance.
  DBScanBenchmark(this.points, this.eps, this.minPoints)
      : super(
          'DBScan(points=${points.length}, eps=$eps, minPoints=$minPoints)',
        );

  /// The points to cluster.
  final List<SpatialPoint> points;

  /// The epsilon value for DBSCAN.
  final double eps;

  /// The minimum points value for DBSCAN.
  final int minPoints;

  @override
  void run() => DBScan(eps: eps, minPoints: minPoints).run(points: points);

  @override
  void setup() {}

  @override
  void teardown() {}
}

List<LatLngPoint> generateRandomPoints(final int count, final double maxCoord) {
  final Random random = Random(42); // Fixed seed for reproducibility
  return List<LatLngPoint>.generate(
    count,
    (final int i) => LatLngPoint(
      pointId: PointId(i),
      lat: random.nextDouble() * maxCoord,
      lng: random.nextDouble() * maxCoord,
    ),
  );
}

void main() {
  // Small dataset
  final List<LatLngPoint> smallDataset = generateRandomPoints(100, 100);
  DBScanBenchmark(smallDataset, 5, 4).report();

  // Medium dataset
  final List<LatLngPoint> mediumDataset = generateRandomPoints(1000, 1000);
  DBScanBenchmark(mediumDataset, 10, 4).report();

  // Large dataset
  final List<LatLngPoint> largeDataset = generateRandomPoints(10000, 10000);
  DBScanBenchmark(largeDataset, 20, 4).report();

  // Test different epsilon values
  final List<LatLngPoint> testDataset = generateRandomPoints(5000, 5000);
  DBScanBenchmark(testDataset, 5, 4).report();
  DBScanBenchmark(testDataset, 50, 4).report();
  DBScanBenchmark(testDataset, 500, 4).report();

  // Benchmark KDTree construction
  KDTreeBenchmark(testDataset).report();

  // Benchmark range search
  RangeSearchBenchmark(testDataset, 50).report();
}

class KDTreeBenchmark extends BenchmarkBase {
  /// Creates a new KDTreeBenchmark instance.
  KDTreeBenchmark(this.points) : super('KDTree.from(${points.length} points)');

  /// The points to build the KD-tree from.
  final List<SpatialPoint> points;

  @override
  void run() => KDTree.from(points);
}

class RangeSearchBenchmark extends BenchmarkBase {
  /// Creates a new RangeSearchBenchmark instance.
  RangeSearchBenchmark(this.points, this.radius)
      : super('rangeSearch(radius=$radius, ${points.length} points)');

  /// The points to search.
  final List<SpatialPoint> points;

  /// The search radius.
  final double radius;

  /// The KD-tree to search.
  late KDTree kdTree;

  /// The query point for the search.
  late SpatialPoint queryPoint;

  @override
  void setup() {
    kdTree = KDTree.from(points);
    // Use a point near the middle of the dataset for consistent benchmarking
    queryPoint = points[points.length ~/ 2];
  }

  @override
  void run() => kdTree.rangeSearch(queryPoint, radius);
}
