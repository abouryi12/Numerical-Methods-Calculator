import 'validation_result.dart';

/// Validates inputs for linear system methods (Doolittle LU, Thomas).
class LinearSystemValidator {
  /// Validates that matrix A is square and non-singular for LU decomposition.
  static ValidationResult validateLU({
    required List<List<double>> matrix,
    required List<double> vectorB,
  }) {
    if (matrix.isEmpty) {
      return const ValidationResult.invalid('Matrix cannot be empty');
    }

    final n = matrix.length;
    for (final row in matrix) {
      if (row.length != n) {
        return const ValidationResult.invalid(
          'Matrix must be square (same number of rows and columns)',
        );
      }
    }

    if (vectorB.length != n) {
      return const ValidationResult.invalid(
        'Vector b must have the same size as the matrix',
      );
    }

    // Simple determinant check for small matrices — full check via pivoting.
    final det = _determinant(matrix);
    if (det.abs() < 1e-12) {
      return const ValidationResult.invalid(
        'Matrix is singular — no unique solution exists',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validates that matrix is tridiagonal for the Thomas algorithm.
  static ValidationResult validateThomas({
    required List<List<double>> matrix,
    required List<double> vectorB,
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

    // Check tridiagonal structure.
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < n; j++) {
        if ((i - j).abs() > 1 && matrix[i][j].abs() > 1e-12) {
          return const ValidationResult.invalid(
            'Matrix is not tridiagonal — only the main diagonal and adjacent diagonals should have non-zero values',
          );
        }
      }
    }

    return const ValidationResult.valid();
  }

  /// Computes determinant recursively (for small matrices up to 6×6).
  static double _determinant(List<List<double>> m) {
    final n = m.length;
    if (n == 1) return m[0][0];
    if (n == 2) return m[0][0] * m[1][1] - m[0][1] * m[1][0];

    double det = 0;
    for (int j = 0; j < n; j++) {
      final subMatrix = <List<double>>[];
      for (int i = 1; i < n; i++) {
        final row = <double>[];
        for (int k = 0; k < n; k++) {
          if (k != j) row.add(m[i][k]);
        }
        subMatrix.add(row);
      }
      det += (j.isEven ? 1 : -1) * m[0][j] * _determinant(subMatrix);
    }
    return det;
  }
}
