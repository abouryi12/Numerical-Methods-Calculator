import 'precision_settings.dart';

/// A single (x, y) data point for interpolation methods.
class DataPoint {
  final double x;
  final double y;

  const DataPoint({required this.x, required this.y});
}

/// Unified input model for all numerical methods.
///
/// Each method uses only the fields relevant to it.
class MethodInput {
  /// f(x) as a user-typed expression string (root finding).
  final String? expression;

  /// Initial guesses: [x₀] for Newton, [x₀, x₁] for Secant, [a, b] for bracket.
  final List<double>? initialValues;

  /// Convergence tolerance (e.g. 0.0001).
  final double? tolerance;

  /// Maximum number of iterations allowed.
  final int? maxIterations;

  /// Precision settings (rounding/chopping + digit count).
  final PrecisionSettings precision;

  /// Coefficient matrix A for linear systems / iterative methods.
  final List<List<double>>? matrix;

  /// Right-hand side vector b for linear systems / iterative methods.
  final List<double>? vectorB;

  /// Initial guess vector x₀ for iterative methods (Jacobi, Gauss-Seidel).
  final List<double>? initialVector;

  /// Data points for interpolation methods.
  final List<DataPoint>? dataPoints;

  /// Target x value for interpolation.
  final double? targetX;

  const MethodInput({
    this.expression,
    this.initialValues,
    this.tolerance,
    this.maxIterations,
    this.precision = const PrecisionSettings(),
    this.matrix,
    this.vectorB,
    this.initialVector,
    this.dataPoints,
    this.targetX,
  });
}
