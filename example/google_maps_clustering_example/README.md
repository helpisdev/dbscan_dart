# Google Maps Clustering Example

This example demonstrates how to use the `dbscan_dart` package to implement real-time marker clustering in a Google Maps Flutter application. Instead of using pre-built clustering solutions, this example shows how to leverage the DBSCAN algorithm for dynamic, density-based clustering of map markers.

## What This Example Showcases

- Real-time clustering of map markers based on zoom level and viewport
- Automatic adjustment of clustering parameters as users zoom in/out
- Visual representation of clusters with color-based markers
- Interactive cluster information on tap

## How It Works

1. **Density-Based Clustering**: Uses DBSCAN to group nearby points based on their geographical proximity
2. **Dynamic Parameter Adjustment**: Automatically adjusts the clustering radius (`eps`) based on the current zoom level
3. **Efficient Re-clustering**: Implements debouncing to prevent excessive clustering operations during map interactions
4. **Visual Differentiation**: Displays different marker styles for clusters, individual points, and noise points

## Implementation Details

The example uses:

- `dbscan_dart` for the clustering algorithm
- `google_maps_flutter` for the map display
- Custom `LatLngPoint` implementation that conforms to the `SpatialPoint` interface
- Zoom-level based parameter adjustment for responsive clustering

## Getting Started

### Prerequisites

- Flutter SDK installed
- Google Maps API key

### Setup

1. Clone the repository:

   ```bash
   git clone https://github.com/helpisdev/dbscan_dart.git
   cd dbscan_dart/example/google_maps_clustering_example
   ```

2. Add your Google Maps API key:

   **For Android:**
   - Open `android/app/src/main/AndroidManifest.xml`
   - Add your API key to the `com.google.android.geo.API_KEY` meta-data tag

   **For iOS:**
   - Open `ios/Runner/AppDelegate.swift`
   - Add your API key to `GMSServices.provideAPIKey("YOUR-API-KEY-HERE")`

   **For Web:**
   - Open `web/index.html`
   - Replace the placeholder API key in the Google Maps script tag:

     ```html
     <script src="https://maps.googleapis.com/maps/api/js?key=YOUR-API-KEY-HERE"></script>
     ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the example:

   ```bash
   flutter run
   ```

## Usage

- **Zoom in/out**: The clustering automatically adjusts based on zoom level
- **Pan**: Move around the map to see clustering update for different regions
- **Tap on clusters**: View information about the cluster
- **Tap on individual markers**: View information about the specific point

## How DBSCAN Is Used

The example uses DBSCAN with the following approach:

```dart
Future<void> _performClustering() async {
  // Skip if already in progress
  if (_isClusteringInProgress) {
    return;
  }

  // Debounce clustering operations
  _clusteringDebouncer = Timer(
    const Duration(milliseconds: 300),
    () async {
      try {
        _isClusteringInProgress = true;
        _markers.clear();

        final double eps = _calculateAdjustedRadius();
        final DBScan dbscan = DBScan(eps: eps, minPoints: _minPoints);
        final ClusteringResult result = dbscan.run(points: _points);

        if (mounted) {
          setState(() => _addMarkers(result));
        }
      } finally {
        _isClusteringInProgress = false;
      }
    },
  );
}
```

The clustering parameters are dynamically adjusted based on the current zoom level, ensuring that the clustering makes sense visually at any scale.

## License

This example is part of the `dbscan_dart` package and is available under the same license.
