import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Variable names for display: x, y, z, w, v, u...
String _varName(int i) {
  const names = ['x', 'y', 'z', 'w', 'v', 'u'];
  if (i < names.length) return names[i];
  return 'x${i + 1}';
}

/// Gauss-Seidel Iteration method for solving Ax = b.
///
/// Like Jacobi but uses the latest computed values immediately,
/// which typically converges faster.
MethodResult gaussSeidel({
  required List<List<double>> matrix,
  required List<double> vectorB,
  required List<double> initialVector,
  required double tolerance,
  required int maxIterations,
  required PrecisionSettings precision,
}) {
  final n = matrix.length;
  final steps = <IterationStep>[];

  var x = List<double>.from(initialVector);
  for (int i = 0; i < n; i++) {
    x[i] = applyPrecision(x[i], precision);
  }

  // Add initial guess as iteration 0.
  final initValues = <String, double>{};
  initValues['Iter'] = 0;
  for (int i = 0; i < n; i++) {
    initValues[_varName(i)] = x[i];
  }
  steps.add(IterationStep(iteration: 0, values: initValues));

  for (int iter = 1; iter <= maxIterations; iter++) {
    final xOld = List<double>.from(x);

    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        if (j != i) {
          // Uses latest x[j] values (already updated for j < i).
          sum = applyPrecision(sum + matrix[i][j] * x[j], precision);
        }
      }
      x[i] = applyPrecision(
        (vectorB[i] - sum) / matrix[i][i],
        precision,
      );
    }

    // Compute error as max absolute difference.
    double maxError = 0;
    for (int i = 0; i < n; i++) {
      final diff = applyPrecision((x[i] - xOld[i]).abs(), precision);
      if (diff > maxError) maxError = diff;
    }

    final stepValues = <String, double>{};
    stepValues['Iter'] = iter.toDouble();
    for (int i = 0; i < n; i++) {
      stepValues[_varName(i)] = x[i];
    }
    stepValues['ε'] = maxError;

    steps.add(IterationStep(iteration: iter, values: stepValues));

    if (maxError < tolerance) {
      return MethodResult(
        solutionVector: List<double>.from(x),
        iterations: iter,
        approximateError: maxError,
        steps: steps,
        converged: true,
      );
    }
  }

  return MethodResult(
    solutionVector: List<double>.from(x),
    iterations: maxIterations,
    approximateError: steps.last.values['ε'],
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
