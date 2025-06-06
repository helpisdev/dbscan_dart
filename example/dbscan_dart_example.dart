// Example usage of the DBSCAN algorithm in Dart
// ignore_for_file: avoid_print

import 'package:dbscan_dart/dbscan_dart.dart';

void main() {
  // Create some sample points
  final List<SpatialPoint> points = <SpatialPoint>[
    const LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
    const LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
    const LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
    const LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
    const LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
    const LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
    const LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
  ];

  // Set DBSCAN parameters
  const double eps = 5;
  const int minPoints = 2;

  // Create a DBScan instance with the specified parameters
  const DBScan dbscan = DBScan(eps: eps, minPoints: minPoints);

  // Run DBSCAN
  final ClusteringResult result = dbscan.run(points: points);

  // Print clusters
  print('### Clusters ###');
  result.clusters.forEach((
    final ClusterId clusterId,
    final List<SpatialPoint> cluster,
  ) {
    print('Cluster ${clusterId.value}: $cluster');
  });
  print('################');
  print('');

  // Print point labels
  print('### Point Labels ###');
  result.labels.forEach((final PointId pointId, final ClusterLabel label) {
    print('ID(${pointId.value}): ClusterID(${label.value})');
  });
  print('####################');

  // Example of checking if a point is noise
  const PointId pointToCheck = PointId(2000);
  if (result.labels[pointToCheck] == ClusterLabel.noise) {
    print('Point with ID ${pointToCheck.value} is noise');
  }

  // Example of getting all points in a specific cluster
  const ClusterId clusterIdToCheck = ClusterId(1);
  if (result.clusters.containsKey(clusterIdToCheck)) {
    print('Points in cluster ${clusterIdToCheck.value}:');
    for (final SpatialPoint point in result.clusters[clusterIdToCheck]!) {
      if (point is LatLngPoint) {
        print(
          '  - Point ID: ${point.pointId}, '
          'Lat: ${point.lat}, '
          'Lng: ${point.lng}',
        );
      } else {
        print('  - $point');
      }
    }
  }
}
