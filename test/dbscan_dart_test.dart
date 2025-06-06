import 'package:dbscan_dart/dbscan_dart.dart';
import 'package:test/test.dart';

void main() {
  group('LatLngPoint tests', () {
    test('id() returns correct ID', () {
      const LatLngPoint p = LatLngPoint(pointId: PointId(1), lat: 0, lng: 0);
      expect(p.id(), equals(const PointId(1)));
    });

    test('distanceTo() calculates correct Haversine distance', () {
      // Two points 1 degree apart along the equator (approx. 111.2 km)
      const LatLngPoint p1 = LatLngPoint(pointId: PointId(1), lat: 0, lng: 0);
      const LatLngPoint p2 = LatLngPoint(pointId: PointId(2), lat: 0, lng: 1);

      final double distance = p1.distanceTo(p2);
      // Haversine distance between (0,0) and (0,1) is approximately 111.2 km
      expect(distance, closeTo(111200, 100));
    });

    test('dimension() returns 2 for LatLngPoint', () {
      const LatLngPoint p = LatLngPoint(pointId: PointId(1), lat: 0, lng: 0);
      expect(p.dimension(), equals(2));
    });

    test('atDimension() returns correct values', () {
      const LatLngPoint p = LatLngPoint(pointId: PointId(1), lng: 1, lat: 2);

      expect(p.atDimension(0), equals(1)); // lng
      expect(p.atDimension(1), equals(2)); // lat

      expect(() => p.atDimension(3), throwsArgumentError);
    });
  });

  group('KDTree tests', () {
    test('KDTree.from() creates tree correctly', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 0, lng: 0),
      ];

      final KDTree tree = KDTree.from(points);
      expect(tree.root, isNotNull);
      expect(tree.root?.point.id(), equals(const PointId(1)));
    });

    test('KDTree.from() throws on invalid dimension', () {
      final List<_TestPoint> points = <_TestPoint>[_TestPoint()];

      expect(() => KDTree.from(points), throwsArgumentError);
    });

    test('rangeSearch with neighbors', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 0, lng: 0),
        const LatLngPoint(pointId: PointId(2), lat: 0, lng: 0),
        const LatLngPoint(pointId: PointId(3), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(4), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(5), lat: 3, lng: 3),
        const LatLngPoint(pointId: PointId(6), lat: 4, lng: 4),
      ];

      final KDTree tree = KDTree.from(points);
      const LatLngPoint query = LatLngPoint(
        pointId: PointId(0),
        lat: 1,
        lng: 1,
      );
      const double radius = 200000; // 200km, enough to include points 1-4

      final List<SpatialPoint> result = tree.rangeSearch(query, radius)
        ..sort((final SpatialPoint a, final SpatialPoint b) {
          return a.id().value.compareTo(b.id().value);
        });

      expect(result.length, equals(4));
      expect(
        result.map((final SpatialPoint p) => p.id().value).toList(),
        equals(<int>[1, 2, 3, 4]),
      );
    });

    test('rangeSearch with no neighbors', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 0, lng: 0),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
      ];

      final KDTree tree = KDTree.from(points);
      const LatLngPoint query = LatLngPoint(
        pointId: PointId(0),
        lat: 1,
        lng: 1,
      );
      const double radius = 0.5;

      final List<SpatialPoint> result = tree.rangeSearch(query, radius);
      expect(result, isEmpty);
    });

    test('rangeSearch with all points', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 0, lng: 0),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 4, lng: 4),
      ];

      final KDTree tree = KDTree.from(points);
      const LatLngPoint query = LatLngPoint(
        pointId: PointId(0),
        lat: 2,
        lng: 2,
      );
      const double radius = 500000; // 500km, enough to include all points

      final List<SpatialPoint> result = tree.rangeSearch(query, radius);
      expect(result.length, equals(3));
    });

    test('rangeSearch with empty tree', () {
      const KDTree tree = KDTree(root: null, k: 2);
      const LatLngPoint query = LatLngPoint(
        pointId: PointId(0),
        lat: 1,
        lng: 1,
      );

      final List<SpatialPoint> result = tree.rangeSearch(query, 5);
      expect(result, isEmpty);
    });

    test('rangeSearch throws on dimension mismatch', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 0, lng: 0),
      ];

      final KDTree tree = KDTree.from(points);
      final _TestPointWithDimension query = _TestPointWithDimension(3);

      expect(() => tree.rangeSearch(query, 5), throwsArgumentError);
    });
  });

  group('DBScan tests', () {
    test('DBScan with empty points returns empty result', () {
      final ClusteringResult result = const DBScan(
        eps: 10,
        minPoints: 0,
      ).run(points: <SpatialPoint>[]);

      expect(result.clusters, isEmpty);
      expect(result.labels, isEmpty);
    });

    test('DBScan with one cluster', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
        const LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
        const LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
        const LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
        const LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
      ];

      final ClusteringResult result = const DBScan(
        eps: 500000, // 500km, enough to connect points 1-5
        minPoints: 3,
      ).run(points: points);

      expect(result.clusters.length, equals(1));
      expect(result.clusters[const ClusterId(1)]?.length, equals(4));

      expect(
        result.labels[const PointId(1)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(2)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(3)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(5)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(result.labels[const PointId(1000)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(1001)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(2000)], equals(ClusterLabel.noise));
    });

    test('DBScan with two clusters', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
        const LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
        const LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
        const LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
        const LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
      ];

      final ClusteringResult result = const DBScan(
        eps: 500000, // 500km, enough to connect nearby points
        minPoints: 2,
      ).run(points: points);

      expect(result.clusters.length, equals(2));
      expect(result.clusters[const ClusterId(1)]?.length, equals(4));
      expect(result.clusters[const ClusterId(2)]?.length, equals(2));

      expect(
        result.labels[const PointId(1)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(2)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(3)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(5)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(1000)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(
        result.labels[const PointId(1001)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(result.labels[const PointId(2000)], equals(ClusterLabel.noise));
    });

    test('DBScan with three clusters', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
        const LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
        const LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
        const LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
        const LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
      ];

      final ClusteringResult result = const DBScan(
        eps: 500000, // 500km, enough to connect nearby points
        minPoints: 1,
      ).run(points: points);

      expect(result.clusters.length, equals(3));
      expect(result.clusters[const ClusterId(1)]?.length, equals(4));
      expect(result.clusters[const ClusterId(2)]?.length, equals(2));
      expect(result.clusters[const ClusterId(3)]?.length, equals(1));

      expect(
        result.labels[const PointId(1)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(2)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(3)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(5)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(1000)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(
        result.labels[const PointId(1001)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(
        result.labels[const PointId(2000)],
        equals(ClusterLabel.fromClusterId(const ClusterId(3))),
      );
    });

    test('DBScan with all clusters', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
        const LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
        const LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
        const LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
        const LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
      ];

      final ClusteringResult result = const DBScan(
        eps: 500000, // 500km, enough to connect nearby points
        minPoints: 1,
      ).run(points: points);

      expect(result.clusters.length, equals(3));
      expect(result.clusters[const ClusterId(1)]?.length, equals(4));
      expect(result.clusters[const ClusterId(2)]?.length, equals(2));
      expect(result.clusters[const ClusterId(3)]?.length, equals(1));

      expect(
        result.labels[const PointId(1)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(2)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(3)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(5)],
        equals(ClusterLabel.fromClusterId(const ClusterId(1))),
      );
      expect(
        result.labels[const PointId(1000)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(
        result.labels[const PointId(1001)],
        equals(ClusterLabel.fromClusterId(const ClusterId(2))),
      );
      expect(
        result.labels[const PointId(2000)],
        equals(ClusterLabel.fromClusterId(const ClusterId(3))),
      );
    });

    test('DBScan with all noise due to minPoints', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
        const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
      ];

      final ClusteringResult result = const DBScan(
        eps: 500000, // 500km, enough to connect nearby points
        minPoints: 5,
      ).run(points: points);

      expect(result.clusters, isEmpty);
      expect(result.labels[const PointId(1)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(2)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(3)], equals(ClusterLabel.noise));
    });

    test('DBScan with all noise due to distance', () {
      final List<SpatialPoint> points = <SpatialPoint>[
        const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
        const LatLngPoint(pointId: PointId(2), lat: 20, lng: 20),
        const LatLngPoint(pointId: PointId(3), lat: 40, lng: 40),
      ];

      final ClusteringResult result = const DBScan(
        eps: 1, // Very small epsilon
        minPoints: 2,
      ).run(points: points);

      expect(result.clusters, isEmpty);
      expect(result.labels[const PointId(1)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(2)], equals(ClusterLabel.noise));
      expect(result.labels[const PointId(3)], equals(ClusterLabel.noise));
    });
  });
}

/// Test point with invalid dimension
class _TestPoint implements SpatialPoint {
  @override
  PointId id() => const PointId(0);

  @override
  double distanceTo(final SpatialPoint other) => 0;

  @override
  int dimension() => -1;

  @override
  double atDimension(final int d) => 0;
}

/// Test point with custom dimension
class _TestPointWithDimension implements SpatialPoint {
  /// Creates a new test point with the specified dimension.
  _TestPointWithDimension(this.dim);

  /// The dimension of this point.
  final int dim;

  @override
  PointId id() => const PointId(0);

  @override
  double distanceTo(final SpatialPoint other) => 0;

  @override
  int dimension() => dim;

  @override
  double atDimension(final int d) => 0;
}
