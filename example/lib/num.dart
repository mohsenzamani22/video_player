import 'dart:math' as math;

extension NumCoerceAtMostExtension<T extends num> on T {
  T coerceAtMost(T maximumValue) => this > maximumValue ? maximumValue : this;
}

extension NumConvertAnglesExtension<T extends num> on T {
  double toRadian() => this * (math.pi / 180);
  double toDegree() => this * (180 / math.pi);
}
