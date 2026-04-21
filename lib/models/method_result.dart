/// One row in the iteration table.
class IterationStep {
  final int iteration;

  /// Column name → value, e.g. {'a': 1.0, 'b': 2.0, 'x_mid': 1.5, 'f(x)': -0.3}
  final Map<String, double> values;

  const IterationStep({
    required this.iteration,
    required this.values,
  });
}

/// Final output of any numerical method.
class MethodResult {
  /// The computed answer (root, interpolated value, etc.).
  final double? answer;

  /// For linear system solvers — returns a vector of solutions.
  final List<double>? solutionVector;

  /// Total iterations performed.
  final int iterations;

  /// Final approximate error at convergence.
  final double? approximateError;

  /// Step-by-step iteration rows for the table display.
  final List<IterationStep> steps;

  /// Whether the method converged within tolerance.
  final bool converged;

  /// Human-readable error message if computation failed.
  final String? errorMessage;

  const MethodResult({
    this.answer,
    this.solutionVector,
    required this.iterations,
    this.approximateError,
    this.steps = const [],
    this.converged = false,
    this.errorMessage,
  });

  /// Convenience constructor for error results.
  factory MethodResult.error(String message) {
    return MethodResult(
      iterations: 0,
      converged: false,
      errorMessage: message,
    );
  }
}
