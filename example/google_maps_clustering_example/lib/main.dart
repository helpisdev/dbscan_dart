import 'package:flutter/material.dart';
import 'src/maps_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _shouldLoadMaps = false;

  void _loadMaps() => setState(() => _shouldLoadMaps = true);

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'DBSCAN Maps Clustering',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Visibility(
        visible: _shouldLoadMaps,
        replacement: Center(
          child: ElevatedButton(
            onPressed: _loadMaps,
            child: const Text('Open Maps Screen'),
          ),
        ),
        child: const MapsScreen(),
      ),
    );
  }
}
