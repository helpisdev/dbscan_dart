import 'package:meta/meta.dart';

/// Unique identifier for clusters in clustering algorithms.
///
/// This class wraps an integer ID value to provide type safety and prevent
/// confusion with other integer values in the application.
@immutable
class ClusterId {
  /// Creates a new cluster ID with the specified value.
  const ClusterId(this.value);

  /// The integer value of this ID.
  final int value;

  @override
  bool operator ==(final Object other) =>
      identical(this, other) ||
      other is ClusterId &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ClusterId($value)';
}
