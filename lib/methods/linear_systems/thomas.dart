import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Thomas Algorithm (TDMA) for solving tridiagonal systems.
///
/// Efficient O(n) solver for tridiagonal matrices via
/// forward sweep + back substitution.
MethodResult thomas({
  required List<List<double>> matrix,
  required List<double> vectorB,
  required PrecisionSettings precision,
}) {
  final n = matrix.length;
  final steps = <IterationStep>[];

  // Extract diagonals from the matrix.
  // a = lower, b = main, c = upper diagonal.
  final a = List.filled(n, 0.0); // sub-diagonal (a[0] unused)
  final b = List.filled(n, 0.0); // main diagonal
  final c = List.filled(n, 0.0); // super-diagonal (c[n-1] unused)
  final d = List<double>.from(vectorB);

  for (int i = 0; i < n; i++) {
    b[i] = matrix[i][i];
    if (i > 0) a[i] = matrix[i][i - 1];
    if (i < n - 1) c[i] = matrix[i][i + 1];
  }

  // Forward sweep.
  final cPrime = List.filled(n, 0.0);
  final dPrime = List.filled(n, 0.0);

  if (b[0].abs() < 1e-15) {
    return MethodResult.error('Zero pivot at position [0][0]');
  }

  cPrime[0] = applyPrecision(c[0] / b[0], precision);
  dPrime[0] = applyPrecision(d[0] / b[0], precision);

  steps.add(IterationStep(
    iteration: 1,
    values: {"c'[0]": cPrime[0], "d'[0]": dPrime[0]},
  ));

  for (int i = 1; i < n; i++) {
    final m = applyPrecision(
      a[i] / (b[i] - a[i] * cPrime[i - 1]),
      precision,
    );
    if (i < n - 1) {
      cPrime[i] = applyPrecision(
        c[i] / (b[i] - a[i] * cPrime[i - 1]),
        precision,
      );
    }
    dPrime[i] = applyPrecision(
      (d[i] - a[i] * dPrime[i - 1]) / (b[i] - a[i] * cPrime[i - 1]),
      precision,
    );

    steps.add(IterationStep(
      iteration: i + 1,
      values: {
        'm': m,
        "c'[$i]": cPrime[i],
        "d'[$i]": dPrime[i],
      },
    ));
  }

  // Back substitution.
  final x = List.filled(n, 0.0);
  x[n - 1] = dPrime[n - 1];

  for (int i = n - 2; i >= 0; i--) {
    x[i] = applyPrecision(dPrime[i] - cPrime[i] * x[i + 1], precision);
  }

  // Final step with solution.
  final solnValues = <String, double>{};
  for (int i = 0; i < n; i++) {
    solnValues['x[$i]'] = x[i];
  }
  steps.add(IterationStep(
    iteration: n + 1,
    values: solnValues,
  ));

  return MethodResult(
    solutionVector: x,
    iterations: n,
    steps: steps,
    converged: true,
  );
}
