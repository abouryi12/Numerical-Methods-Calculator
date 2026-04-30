import '../../models/method_result.dart';

/// Thomas Algorithm for solving tridiagonal systems.
///
/// Uses the 3-step method:
///   Step 1: Compute y vector (decomposition of main diagonal)
///   Step 2: Compute z vector (forward substitution)
///   Step 3: Compute x vector (back substitution)
MethodResult thomas({
  required List<List<double>> matrix,
  required List<double> vectorB,
}) {
  final n = matrix.length;
  final steps = <IterationStep>[];

  // Extract diagonals from the tridiagonal matrix.
  // a[i][1] = sub-diagonal (a_{i,1} in notation), stored as matrix[i][i-1]
  // a[i][2] = main diagonal (a_{i,2}), stored as matrix[i][i]
  // a[i][3] = super-diagonal (a_{i,3}), stored as matrix[i][i+1]
  final a1 = List.filled(n, 0.0); // sub-diagonal
  final a2 = List.filled(n, 0.0); // main diagonal
  final a3 = List.filled(n, 0.0); // super-diagonal
  final b = List<double>.from(vectorB);

  for (int i = 0; i < n; i++) {
    a2[i] = matrix[i][i];
    if (i > 0) a1[i] = matrix[i][i - 1];
    if (i < n - 1) a3[i] = matrix[i][i + 1];
  }

  // ── Step 1: Compute y vector ──
  // y₁ = a₁₂ (main diagonal of first row)
  // yᵢ = aᵢ₂ - (aᵢ₁ * a(i-1)₃) / y(i-1)
  final y = List.filled(n, 0.0);
  y[0] = a2[0];

  if (y[0].abs() < 1e-15) {
    return MethodResult.error('Zero pivot at y[1]');
  }

  final step1Values = <String, double>{'y₁': y[0]};
  for (int i = 1; i < n; i++) {
    y[i] = a2[i] - (a1[i] * a3[i - 1]) / y[i - 1];
    step1Values['y${_sub(i + 1)}'] = y[i];

    if (y[i].abs() < 1e-15) {
      return MethodResult.error('Zero pivot at y[${i + 1}]');
    }
  }
  steps.add(IterationStep(iteration: 1, values: step1Values));

  // ── Step 2: Compute z vector (forward substitution) ──
  // z₁ = b₁ / y₁
  // zᵢ = (bᵢ - aᵢ₁ * z(i-1)) / yᵢ
  final z = List.filled(n, 0.0);
  z[0] = b[0] / y[0];

  final step2Values = <String, double>{'z₁': z[0]};
  for (int i = 1; i < n; i++) {
    z[i] = (b[i] - a1[i] * z[i - 1]) / y[i];
    step2Values['z${_sub(i + 1)}'] = z[i];
  }
  steps.add(IterationStep(iteration: 2, values: step2Values));

  // ── Step 3: Compute x vector (back substitution) ──
  // xₙ = zₙ
  // xᵢ = zᵢ - (aᵢ₃ * x(i+1)) / yᵢ
  final x = List.filled(n, 0.0);
  x[n - 1] = z[n - 1];

  final step3Values = <String, double>{};
  for (int i = n - 2; i >= 0; i--) {
    x[i] = z[i] - (a3[i] * x[i + 1]) / y[i];
  }
  // Add x values in order
  for (int i = 0; i < n; i++) {
    step3Values['x${_sub(i + 1)}'] = x[i];
  }
  steps.add(IterationStep(iteration: 3, values: step3Values));

  return MethodResult(
    solutionVector: x,
    intermediateVectors: {
      'y': y,
      'z': z,
    },
    iterations: 3,
    steps: steps,
    converged: true,
  );
}

/// Returns subscript string for index.
String _sub(int i) {
  const subs = '₁₂₃₄₅₆₇₈₉';
  if (i >= 1 && i <= 9) return subs[i - 1];
  return '$i';
}
