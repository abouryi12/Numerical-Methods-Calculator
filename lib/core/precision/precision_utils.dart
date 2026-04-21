import 'dart:math' as math;
import '../../models/precision_settings.dart';

/// Applies the chosen precision mode to a [value].
///
/// This MUST be called on every intermediate value inside every
/// iteration loop — not only on the final result.
double applyPrecision(double value, PrecisionSettings settings) {
  if (value == 0 || value.isNaN || value.isInfinite) return value;

  switch (settings.mode) {
    case PrecisionMode.rounding:
      return _round(value, settings.digits);
    case PrecisionMode.chopping:
      return _chop(value, settings.digits);
  }
}

/// Rounds [value] to [significantDigits] significant digits.
double _round(double value, int significantDigits) {
  if (value == 0) return 0;
  final d = (math.log(value.abs()) / math.ln10).ceil();
  final power = significantDigits - d;
  final magnitude = math.pow(10, power).toDouble();
  return (value * magnitude).roundToDouble() / magnitude;
}

/// Chops (truncates) [value] to [significantDigits] significant digits.
double _chop(double value, int significantDigits) {
  if (value == 0) return 0;
  final d = (math.log(value.abs()) / math.ln10).ceil();
  final power = significantDigits - d;
  final magnitude = math.pow(10, power).toDouble();
  return (value * magnitude).truncateToDouble() / magnitude;
}
