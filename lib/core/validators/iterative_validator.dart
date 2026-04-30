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

  /// Attempts to rearrange the rows of [matrix] and [vectorB] to make the
  /// matrix diagonally dominant. Returns true if successful, false otherwise.
  static bool makeDiagonallyDominant({
    required List<List<double>> matrix,
    required List<double> vectorB,
  }) {
    if (matrix.isEmpty) return false;
    final n = matrix.length;
    final newMatrix = List.generate(n, (_) => <double>[]);
    final newVectorB = List.filled(n, 0.0);
    final rowAssigned = List.filled(n, false);

    for (int i = 0; i < n; i++) {
      int foundRow = -1;
      for (int r = 0; r < n; r++) {
        if (rowAssigned[r]) continue;
        
        double diag = matrix[r][i].abs();
        double sum = 0;
        for (int c = 0; c < n; c++) {
          if (c != i) sum += matrix[r][c].abs();
        }
        
        if (diag >= sum && diag > 0) {
          foundRow = r;
          break;
        }
      }

      if (foundRow == -1) {
        // Could not find a dominant row for column i.
        return false;
      }

      newMatrix[i] = List<double>.from(matrix[foundRow]);
      newVectorB[i] = vectorB[foundRow];
      rowAssigned[foundRow] = true;
    }

    // Apply the rearranged rows back to the original references.
    for (int i = 0; i < n; i++) {
      matrix[i] = newMatrix[i];
      vectorB[i] = newVectorB[i];
    }
    
    return true;
  }
}
