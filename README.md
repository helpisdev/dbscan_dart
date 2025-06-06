# 🚀 DBSCAN Dart Implementation

A high-performance, pure-Dart implementation of the DBSCAN clustering algorithm with spatial optimization. This library works with any data type that implements the `SpatialPoint` interface, requiring only `id()`, `distanceTo(SpatialPoint)`, `dimension()`, and `atDimension(int)` methods-making it versatile for n-D, geospatial, or custom distance metrics.

## ✨ Features

- **🔍 KD-Tree & Grid Optimization** - Dramatically improves performance on large datasets through spatial indexing
- **🧩 Flexible Point Interface** - Cluster any data type by implementing a simple interface
- **🔄 Efficient Expansion Algorithm** - Uses optimized seed-set expansion with duplicate tracking
- **🛡️ Border Point Handling** - Smart border point detection prevents misclassification as noise
- **📊 Comprehensive Results** - Returns both per-cluster point collections and per-point cluster assignments

## Credits and Attribution

This package is heavily based on the work done in [mojixcoder/dbscan](https://github.com/mojixcoder/dbscan), with optimizations and adaptations for Dart.

For those interested in understanding the DBSCAN algorithm in depth:

- [Visual explanation of DBSCAN by Computerphile](https://www.youtube.com/watch?v=RDZUdRSDOok)
- [DataCamp's DBSCAN Clustering Algorithm Tutorial](https://www.datacamp.com/tutorial/dbscan-clustering-algorithm?dc_referrer=https%3A%2F%2Fduckduckgo.com%2F)

## Getting started

Add the package to your `pubspec.yaml`:

```console
dart pub add dbscan_dart
```

## Usage

```dart
import 'package:dbscan_dart/dbscan_dart.dart';

void main() {
  // Create some sample points
  final points = <SpatialPoint>[
    LatLngPoint(pointId: PointId(1), lat: 1, lng: 1),
    LatLngPoint(pointId: PointId(2), lat: 2, lng: 2),
    LatLngPoint(pointId: PointId(3), lat: 3, lng: 3),
    LatLngPoint(pointId: PointId(5), lat: 5, lng: 5),
    LatLngPoint(pointId: PointId(1000), lat: 1000, lng: 1000),
    LatLngPoint(pointId: PointId(1001), lat: 1001, lng: 1001),
    LatLngPoint(pointId: PointId(2000), lat: 2000, lng: 2000),
  ];

  // Set DBSCAN parameters
  const eps = 5;
  const minPoints = 2;

  // Create a DBScan instance
  final dbscan = DBScan(eps: eps, minPoints: minPoints);

  // Run DBSCAN
  final result = dbscan.run(points: points);

  // Print clusters
  print('### Clusters ###');
  result.clusters.forEach((clusterId, cluster) {
    print('Cluster $clusterId: $cluster');
  });

  // Print point labels
  print('### Point Labels ###');
  result.labels.forEach((pointId, label) {
    print('ID(${pointId.value}): ClusterID(${label.value})');
  });

  // Check if a point is noise
  final pointToCheck = PointId(2000);
  if (result.labels[pointToCheck] == ClusterLabel.noise) {
    print('Point with ID ${pointToCheck.value} is noise');
  }
}
```

Example output:

```console
### Clusters ###
Cluster 1: [LatLngPoint(id: 1, lat: 1, lng: 1), LatLngPoint(id: 2, lat: 2, lng: 2), LatLngPoint(id: 3, lat: 3, lng: 3), LatLngPoint(id: 5, lat: 5, lng: 5)]
Cluster 2: [LatLngPoint(id: 1000, lat: 1000, lng: 1000), LatLngPoint(id: 1001, lat: 1001, lng: 1001)]
################

### Point Labels ###
ID(1): ClusterID(1)
ID(2): ClusterID(1)
ID(3): ClusterID(1)
ID(5): ClusterID(1)
ID(1000): ClusterID(2)
ID(1001): ClusterID(2)
ID(2000): ClusterID(-1) // Noise
####################
Point with ID 2000 is noise
```

## API Overview

### SpatialPoint Interface

Your data type must implement:

```dart
abstract class SpatialPoint {
  PointId id();
  double distanceTo(SpatialPoint other);
  int dimension();
  double atDimension(int d);
}
```

### LatLngPoint Implementation

The library includes a `LatLngPoint` implementation for geographical points:

```dart
final point = LatLngPoint(pointId: 1, lat: 37.7749, lng: -122.4194);
```

### DBScan Algorithm

The main clustering algorithm:

```dart
final dbscan = DBScan(eps: 5, minPoints: 4);
final result = dbscan.run(points: points);
```

Parameters:

- `eps`: Neighborhood radius (maximum distance between two points to be considered neighbors)
- `minPoints`: Minimum number of points required to form a dense region

### Result Structure

The result contains:

- `clusters`: Map of cluster IDs to lists of points in each cluster
- `labels`: Map of point IDs to their assigned cluster labels

## Additional information

### How DBSCAN Works

DBSCAN (Density-Based Spatial Clustering of Applications with Noise) is a clustering algorithm that groups together points that are closely packed together, marking as outliers points that lie alone in low-density regions.

The algorithm works by:

1. For each point, finding all points within distance `eps`
2. If a point has at least `minPoints` neighbors, it's a "core point"
3. All points within `eps` distance of a core point are in the same cluster
4. Points that are not core points but are within `eps` of a core point are "border points"
5. Points that are neither core nor border points are "noise points"

### Choosing Parameters

- **eps**: The maximum distance between two points for them to be considered neighbors
  - Too small: Many small clusters or noise points
  - Too large: Clusters merge together
  - Tip: Try visualizing your data and estimating typical cluster sizes

- **minPoints**: The minimum number of points required to form a dense region
  - Rule of thumb: At least dimension + 1 (e.g., 3 for 2D data)
  - Higher values create more significant clusters
  - Lower values create more clusters with fewer points each

### Performance Considerations

- The implementation uses a KD-Tree for efficient range queries
- For very large datasets, consider sampling or chunking your data
- The algorithm's time complexity is approximately O(n log n) in the average case
