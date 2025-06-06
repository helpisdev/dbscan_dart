import 'dart:math';

/// Extension to generate Gaussian random numbers
extension RandomExtension on Random {
  double nextGaussian() {
    // Box-Muller transform
    final double u1 = 1 - nextDouble(); // Uniform(0,1) random number
    final double u2 = nextDouble(); // Uniform(0,1) random number
    final double z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return z;
  }
}

/// Extension on [double] to provide additional rounding functionality.
extension DoubleRoundingExtension on double {
  /// Rounds the double to the specified number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// 1.234564.roundWithPrecision(2) // Returns 1.23
  /// 1.236564.roundWithPrecision(4) // Returns 1.2366
  /// 1.234564.roundWithPrecision(3) // Returns 1.235
  /// ```
  double roundWithPrecision(final int precision) {
    final double mod = pow(10, precision).toDouble();
    return (this * mod).round() / mod;
  }

  /// Rounds the double to the nearest multiple of the specified step.
  ///
  /// Example:
  /// ```dart
  /// 1.234564.roundWithStep(0.5) // Returns 1
  /// 1.234564.roundWithStep(05) // Returns 1.25
  /// 1.234564.roundWithStep(0.25) // Returns 1.25
  /// ```
  double roundWithStep(final double step) => (this / step).round() * step;
}
