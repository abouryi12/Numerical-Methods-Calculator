import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Doolittle LU Decomposition for solving Ax = b.
///
/// Decomposes A into lower (L) and upper (U) triangular matrices,
/// then solves via forward + back substitution.
MethodResult doolittle({
  required List<List<double>> matrix,
  required List<double> vectorB,
  required PrecisionSettings precision,
}) {
  final n = matrix.length;
  final steps = <IterationStep>[];

  // Create L and U matrices.
  final L = List.generate(n, (i) => List.filled(n, 0.0));
  final U = List.generate(n, (i) => List.filled(n, 0.0));

  // Copy the matrix to avoid mutation.
  final A = List.generate(
    n,
    (i) => List.generate(n, (j) => matrix[i][j]),
  );

  // Doolittle decomposition: L has 1s on diagonal.
  for (int i = 0; i < n; i++) {
    L[i][i] = 1.0;

    // Upper triangular.
    for (int j = i; j < n; j++) {
      double sum = 0;
      for (int k = 0; k < i; k++) {
        sum = applyPrecision(sum + L[i][k] * U[k][j], precision);
      }
      U[i][j] = applyPrecision(A[i][j] - sum, precision);
    }

    // Lower triangular.
    for (int j = i + 1; j < n; j++) {
      double sum = 0;
      for (int k = 0; k < i; k++) {
        sum = applyPrecision(sum + L[j][k] * U[k][i], precision);
      }
      if (U[i][i].abs() < 1e-15) {
        return MethodResult.error('Zero pivot encountered — matrix may be singular');
      }
      L[j][i] = applyPrecision((A[j][i] - sum) / U[i][i], precision);
    }

    // Record L and U state at this step.
    final stepValues = <String, double>{};
    for (int r = 0; r < n; r++) {
      for (int c = 0; c < n; c++) {
        stepValues['L[$r][$c]'] = L[r][c];
        stepValues['U[$r][$c]'] = U[r][c];
      }
    }
    steps.add(IterationStep(iteration: i + 1, values: stepValues));
  }

  // Forward substitution: Ly = b.
  final y = List.filled(n, 0.0);
  for (int i = 0; i < n; i++) {
    double sum = 0;
    for (int j = 0; j < i; j++) {
      sum = applyPrecision(sum + L[i][j] * y[j], precision);
    }
    y[i] = applyPrecision(vectorB[i] - sum, precision);
  }

  // Back substitution: Ux = y.
  final x = List.filled(n, 0.0);
  for (int i = n - 1; i >= 0; i--) {
    double sum = 0;
    for (int j = i + 1; j < n; j++) {
      sum = applyPrecision(sum + U[i][j] * x[j], precision);
    }
    if (U[i][i].abs() < 1e-15) {
      return MethodResult.error('Zero pivot in back substitution');
    }
    x[i] = applyPrecision((y[i] - sum) / U[i][i], precision);
  }

  return MethodResult(
    solutionVector: x,
    iterations: n,
    steps: steps,
    converged: true,
  );
}
