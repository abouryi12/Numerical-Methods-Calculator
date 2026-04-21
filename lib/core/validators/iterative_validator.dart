import 'validation_result.dart';

/// Validates inputs for iterative methods (Jacobi, Gauss-Seidel).
class IterativeValidator {
  /// Checks diagonal dominance and basic matrix requirements.
  static ValidationResult validate({
    required List<List<double>> matrix,
    required List<double> vectorB,
    required List<double> initialVector,
  }) {
    if (matrix.isEmpty) {
      return const ValidationResult.invalid('Matrix cannot be empty');
    }

    final n = matrix.length;
    for (final row in matrix) {
      if (row.length != n) {
        return const ValidationResult.invalid(
          'Matrix must be square',
        );
      }
    }

    if (vectorB.length != n) {
      return const ValidationResult.invalid(
        'Vector b must have the same size as the matrix',
      );
    }

    if (initialVector.length != n) {
      return const ValidationResult.invalid(
        'Initial guess vector must have the same size as the matrix',
      );
    }

    // Check diagonal dominance.
    for (int i = 0; i < n; i++) {
      double diag = matrix[i][i].abs();
      double offDiagSum = 0;
      for (int j = 0; j < n; j++) {
        if (j != i) offDiagSum += matrix[i][j].abs();
      }
      if (diag < offDiagSum) {
        return const ValidationResult.invalid(
          'Matrix is not diagonally dominant — convergence is not guaranteed',
        );
      }
    }

    // Check for zero diagonal.
    for (int i = 0; i < n; i++) {
      if (matrix[i][i].abs() < 1e-12) {
        return const ValidationResult.invalid(
          'Matrix has a zero on the diagonal — cannot solve',
        );
      }
    }

    return const ValidationResult.valid();
  }
}
