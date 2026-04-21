import '../../core/precision/precision_utils.dart';
import '../../models/method_input.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Lagrange Interpolation.
///
/// Works with any spacing (equal or unequal).
/// Uses Lagrange basis polynomials.
MethodResult lagrange({
  required List<DataPoint> dataPoints,
  required double targetX,
  required PrecisionSettings precision,
}) {
  final n = dataPoints.length;
  final steps = <IterationStep>[];

  double result = 0;

  for (int i = 0; i < n; i++) {
    // Compute Lagrange basis polynomial L_i(x).
    double li = 1.0;
    for (int j = 0; j < n; j++) {
      if (j != i) {
        li = applyPrecision(
          li * (targetX - dataPoints[j].x) / (dataPoints[i].x - dataPoints[j].x),
          precision,
        );
      }
    }

    final term = applyPrecision(li * dataPoints[i].y, precision);
    result = applyPrecision(result + term, precision);

    steps.add(IterationStep(
      iteration: i + 1,
      values: {
        'x_$i': dataPoints[i].x,
        'y_$i': dataPoints[i].y,
        'L_$i': li,
        'term_$i': term,
        'partial_sum': result,
      },
    ));
  }

  return MethodResult(
    answer: result,
    iterations: n,
    steps: steps,
    converged: true,
  );
}
