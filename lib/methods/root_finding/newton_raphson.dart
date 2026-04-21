import '../../core/expression_parser.dart';
import '../../core/precision/precision_utils.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Newton-Raphson method for root finding.
///
/// Uses tangent-line approximation: x_{n+1} = x_n - f(x_n) / f'(x_n)
MethodResult newtonRaphson({
  required String expression,
  required double x0,
  required double tolerance,
  required int maxIterations,
  required PrecisionSettings precision,
}) {
  final parser = ExpressionParser();
  final steps = <IterationStep>[];

  var x = applyPrecision(x0, precision);
  double error = double.infinity;

  for (int i = 1; i <= maxIterations; i++) {
    final fx = applyPrecision(parser.evaluate(expression, x), precision);
    final dfx = applyPrecision(
      parser.evaluateDerivative(expression, x),
      precision,
    );

    if (dfx.abs() < 1e-15) {
      return MethodResult(
        answer: x,
        iterations: i,
        approximateError: error,
        steps: steps,
        converged: false,
        errorMessage: 'Derivative became zero during iteration $i',
      );
    }

    final xNew = applyPrecision(x - fx / dfx, precision);
    error = applyPrecision((xNew - x).abs(), precision);

    steps.add(IterationStep(
      iteration: i,
      values: {
        'x': x,
        'f(x)': fx,
        "f'(x)": dfx,
        'x_new': xNew,
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

    x = xNew;
  }

  return MethodResult(
    answer: x,
    iterations: maxIterations,
    approximateError: error,
    steps: steps,
    converged: false,
    errorMessage: 'Maximum iterations reached without convergence',
  );
}
