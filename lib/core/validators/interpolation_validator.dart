import '../../models/method_input.dart';
import 'validation_result.dart';

/// Validates inputs for interpolation methods.
class InterpolationValidator {
  /// Validates inputs for methods requiring equal spacing (Newton Fwd/Bwd, Stirling).
  static ValidationResult validateEqualSpacing({
    required List<DataPoint> dataPoints,
    required double targetX,
  }) {
    final base = _validateBase(dataPoints);
    if (!base.isValid) return base;

    // Check equal spacing.
    final h = dataPoints[1].x - dataPoints[0].x;
    if (h.abs() < 1e-12) {
      return const ValidationResult.invalid(
        'Spacing between data points cannot be zero',
      );
    }

    for (int i = 2; i < dataPoints.length; i++) {
      final spacing = dataPoints[i].x - dataPoints[i - 1].x;
      if ((spacing - h).abs() > 1e-8) {
        return const ValidationResult.invalid(
          'Data points are not equally spaced — this method requires uniform x intervals',
        );
      }
    }

    return const ValidationResult.valid();
  }

  /// Validates Stirling's formula inputs (needs odd number of points + center).
  static ValidationResult validateStirling({
    required List<DataPoint> dataPoints,
    required double targetX,
  }) {
    final spacingCheck = validateEqualSpacing(
      dataPoints: dataPoints,
      targetX: targetX,
    );
    if (!spacingCheck.isValid) return spacingCheck;

    if (dataPoints.length.isEven) {
      return const ValidationResult.invalid(
        'Stirling\'s formula requires an odd number of data points',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validates Lagrange inputs (any spacing allowed).
  static ValidationResult validateLagrange({
    required List<DataPoint> dataPoints,
    required double targetX,
  }) {
    final base = _validateBase(dataPoints);
    if (!base.isValid) return base;

    // Check for duplicate x values.
    final xValues = dataPoints.map((p) => p.x).toSet();
    if (xValues.length != dataPoints.length) {
      return const ValidationResult.invalid(
        'Data points must have unique x values',
      );
    }

    return const ValidationResult.valid();
  }

  /// Common base validation for all interpolation methods.
  static ValidationResult _validateBase(List<DataPoint> dataPoints) {
    if (dataPoints.length < 2) {
      return const ValidationResult.invalid(
        'At least 2 data points are required',
      );
    }

    return const ValidationResult.valid();
  }
}
