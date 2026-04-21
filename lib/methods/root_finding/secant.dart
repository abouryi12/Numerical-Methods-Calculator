import '../../core/expression_parser.dart';
import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Secant method for root finding.
///
/// Uses two initial points to approximate the derivative:
/// x_{n+1} = x_n - f(x_n) * (x_n - x_{n-1}) / (f(x_n) - f(x_{n-1}))
MethodResult secant({
  required String expression,
  required double x0,
  required double x1,
  required double tolerance,
  required int maxIterations,
  required PrecisionSettings precision,
}) {
  final parser = ExpressionParser();
  final steps = <IterationStep>[];

  var xPrev = applyPrecision(x0, precision);
  var xCurr = applyPrecision(x1, precision);
  double error = double.infinity;

  for (int i = 1; i <= maxIterations; i++) {
    final fPrev = applyPrecision(parser.evaluate(expression, xPrev), precision);
    final fCurr = applyPrecision(parser.evaluate(expression, xCurr), precision);

    final denominator = fCurr - fPrev;
    if (denominator.abs() < 1e-15) {
      return MethodResult(
        answer: xCurr,
        iterations: i,
        approximateError: error,
        steps: steps,
        converged: false,
        errorMessage: 'Division by zero — f(x_n) ≈ f(x_{n-1})',
      );
    }

    final xNew = applyPrecision(
      xCurr - fCurr * (xCurr - xPrev) / denominator,
      precision,
    );
    error = applyPrecision((xNew - xCurr).abs(), precision);

    steps.add(IterationStep(
      iteration: i,
      values: {
        'x_{n-1}': xPrev,
        'x_n': xCurr,
        'f(x_{n-1})': fPrev,
        'f(x_n)': fCurr,
        'x_{n+1}': xNew,
        'error': error,
      },
    ));

    if (error < tolerance) {
      return MethodResult(
        answer: xNew,
        iterations: i,
        approximateError: error,
        steps: steps,
        converged: true,
      );
    }

    xPrev = xCurr;
    xCurr = xNew;
  }

  return MethodResult(
    answer: xCurr,
    iterations: maxIterations,
    approximateError: error,
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
