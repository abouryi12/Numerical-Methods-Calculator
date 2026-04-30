import 'validation_result.dart';
import '../expression_parser.dart';

/// Validates inputs for all root-finding methods.
class RootFindingValidator {
  /// Validates Bisection and False Position inputs.
  static ValidationResult validateBracket({
    required String expression,
    required double a,
    required double b,
  }) {
    if (expression.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter a function f(x)');
    }

    final parser = ExpressionParser();
    double fa, fb;
    try {
      fa = parser.evaluate(expression, a);
      fb = parser.evaluate(expression, b);
    } catch (_) {
      return const ValidationResult.invalid(
        'Could not evaluate the function — check your expression',
      );
    }

    if (fa.isNaN || fb.isNaN || fa.isInfinite || fb.isInfinite) {
      return const ValidationResult.invalid(
        'Function is undefined at one or both endpoints',
      );
    }

    if (fa * fb > 0) {
      return ValidationResult.invalid(
        'Root is not bracketed — f($a) = ${fa.toStringAsFixed(4)}, f($b) = ${fb.toStringAsFixed(4)} (must have opposite signs)',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validates Newton-Raphson inputs.
  static ValidationResult validateNewton({
    required String expression,
    required double x0,
  }) {
    if (expression.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter a function f(x)');
    }

    final parser = ExpressionParser();
    double dfx0;
    try {
      parser.evaluate(expression, x0);
      dfx0 = parser.evaluateDerivative(expression, x0);
    } catch (_) {
      return const ValidationResult.invalid(
        'Could not evaluate the function — check your expression',
      );
    }

    if (dfx0.abs() < 1e-15) {
      return const ValidationResult.invalid(
        'Derivative is zero at the initial point — Newton-Raphson cannot proceed',
      );
    }

    return const ValidationResult.valid();
  }

  /// Validates Secant method inputs.
  static ValidationResult validateSecant({
    required String expression,
    required double x0,
    required double x1,
  }) {
    if (expression.trim().isEmpty) {
      return const ValidationResult.invalid('Please enter a function f(x)');
    }

    if ((x0 - x1).abs() < 1e-15) {
      return const ValidationResult.invalid(
        'Initial guesses must be distinct — x₀ and x₁ cannot be equal',
      );
    }

    final parser = ExpressionParser();
    try {
      parser.evaluate(expression, x0);
      parser.evaluate(expression, x1);
    } catch (_) {
      return const ValidationResult.invalid(
        'Could not evaluate the function — check your expression',
      );
    }

    return const ValidationResult.valid();
  }
}
