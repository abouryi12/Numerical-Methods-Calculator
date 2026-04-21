import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Jacobi Iteration method for solving Ax = b.
///
/// Updates all x components simultaneously using values from
/// the previous iteration only.
MethodResult jacobi({
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

  for (int iter = 1; iter <= maxIterations; iter++) {
    final xNew = List.filled(n, 0.0);

    for (int i = 0; i < n; i++) {
      double sum = 0;
      for (int j = 0; j < n; j++) {
        if (j != i) {
          sum = applyPrecision(sum + matrix[i][j] * x[j], precision);
        }
      }
      xNew[i] = applyPrecision(
        (vectorB[i] - sum) / matrix[i][i],
        precision,
      );
    }

    // Compute error as max absolute difference.
    double maxError = 0;
    for (int i = 0; i < n; i++) {
      final diff = applyPrecision((xNew[i] - x[i]).abs(), precision);
      if (diff > maxError) maxError = diff;
    }

    final stepValues = <String, double>{};
    for (int i = 0; i < n; i++) {
      stepValues['x[$i]'] = xNew[i];
    }
    stepValues['error'] = maxError;

    steps.add(IterationStep(iteration: iter, values: stepValues));

    if (maxError < tolerance) {
      return MethodResult(
        solutionVector: xNew,
        iterations: iter,
        approximateError: maxError,
        steps: steps,
        converged: true,
      );
    }

    x = xNew;
  }

  return MethodResult(
    solutionVector: x,
    iterations: maxIterations,
    approximateError: steps.last.values['error'],
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
