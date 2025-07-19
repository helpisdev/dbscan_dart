import 'package:meta/meta.dart';

/// Unique identifier for spatial points in clustering algorithms.
///
/// This class wraps an integer ID value to provide type safety and prevent
/// confusion with other integer values in the application.
@immutable
class PointId {
  /// Creates a new point ID with the specified value.
  const PointId(this.value);

  /// The integer value of this ID.
  final int value;

  @override
  bool operator ==(final Object other) {
    return other is PointId && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PointId($value)';
}
