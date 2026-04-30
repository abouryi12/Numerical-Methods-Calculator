import '../../core/expression_parser.dart';
import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Bisection method for root finding.
///
/// Repeatedly halves the interval [a, b] where f(a)×f(b) < 0,
/// applying precision to every intermediate value.
MethodResult bisection({
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
  double xMid = 0;
  double fMid = 0;
  double error = double.infinity;

  for (int i = 1; i <= maxIterations; i++) {
    final fA = applyPrecision(parser.evaluate(expression, aVal), precision);
    final fB = applyPrecision(parser.evaluate(expression, bVal), precision);

    xMid = applyPrecision((aVal + bVal) / 2.0, precision);
    fMid = applyPrecision(parser.evaluate(expression, xMid), precision);

    if (i > 1) {
      final prevMid = steps.last.values['x_mid']!;
      error = applyPrecision((xMid - prevMid).abs(), precision);
    }

    steps.add(IterationStep(
      iteration: i,
      values: {
        'Iteration': i.toDouble(),
        'a': aVal,
        'b': bVal,
        'x_mid': xMid,
        'f(a)': fA,
        'f(b)': fB,
        'f(x_mid)': fMid,
      },
    ));

    if (fMid.abs() < 1e-15 || error < tolerance) {
      return MethodResult(
        answer: xMid,
        iterations: i,
        approximateError: error,
        steps: steps,
        converged: true,
      );
    }

    if (fA * fMid < 0) {
      bVal = xMid;
    } else {
      aVal = xMid;
    }
  }

  return MethodResult(
    answer: xMid,
    iterations: maxIterations,
    approximateError: error,
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
