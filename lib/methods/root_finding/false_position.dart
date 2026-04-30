import '../../core/expression_parser.dart';
import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// False Position (Regula Falsi) method for root finding.
///
/// Uses linear interpolation between [a, b] instead of midpoint.
MethodResult falsePosition({
  required String expression,
  required double a,
  required double b,
  required double tolerance,
  required int maxIterations,
  required PrecisionSettings precision,
}) {
  final parser = ExpressionParser();
  final steps = <IterationStep>[];

  var aVal = applyPrecision(a, precision);
  var bVal = applyPrecision(b, precision);
  double xR = 0;
  double fR = 0;
  double error = double.infinity;

  for (int i = 1; i <= maxIterations; i++) {
    final fA = applyPrecision(parser.evaluate(expression, aVal), precision);
    final fB = applyPrecision(parser.evaluate(expression, bVal), precision);

    // Avoid division by zero.
    if ((fB - fA).abs() < 1e-15) {
      return MethodResult.error('f(a) ≈ f(b) — cannot compute false position');
    }

    // Regula Falsi formula: xR = b - f(b) * (b - a) / (f(b) - f(a))
    xR = applyPrecision(
      bVal - fB * (bVal - aVal) / (fB - fA),
      precision,
    );
    fR = applyPrecision(parser.evaluate(expression, xR), precision);

    if (i > 1) {
      final prevXR = steps.last.values['x_r']!;
      error = applyPrecision((xR - prevXR).abs(), precision);
    }

    steps.add(IterationStep(
      iteration: i,
      values: {
        'Iteration': i.toDouble(),
        'a': aVal,
        'b': bVal,
        'x_r': xR,
        'f(a)': fA,
        'f(b)': fB,
        'f(x_r)': fR,
      },
    ));

    if (fR.abs() < 1e-15 || error < tolerance) {
      return MethodResult(
        answer: xR,
        iterations: i,
        approximateError: error,
        steps: steps,
        converged: true,
      );
    }

    if (fA * fR < 0) {
      bVal = xR;
    } else {
      aVal = xR;
    }
  }

  return MethodResult(
    answer: xR,
    iterations: maxIterations,
    approximateError: error,
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
