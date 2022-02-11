import 'dart:math' as math;

enum CartesianAxisType { X, Y }

extension NumCoerceAtMostExtension<T extends num> on T {
  /// Ensures that this value is not greater than the specified [maximumValue].
  ///
  /// Return this value if it's less than or equal to the [maximumValue] or the
  /// [maximumValue] otherwise.
  ///
  /// ```dart
  /// print(10.coerceAtMost(5)) // 5
  /// print(10.coerceAtMost(20)) // 10
  /// ```
  T coerceAtMost(T maximumValue) => this > maximumValue ? maximumValue : this;
}

extension NumConvertAnglesExtension<T extends num> on T {
  double toRadian() => this * (math.pi / 180);
  double toDegree() => this * (180 / math.pi);
}
