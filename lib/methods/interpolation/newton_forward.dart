import '../../core/precision/precision_utils.dart';
import '../../models/method_input.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Newton Forward Interpolation.
///
/// Uses forward difference table for equally-spaced data.
/// Best for interpolation near the beginning of the table.
MethodResult newtonForward({
  required List<DataPoint> dataPoints,
  required double targetX,
  required PrecisionSettings precision,
}) {
  final n = dataPoints.length;
  final steps = <IterationStep>[];

  final h = applyPrecision(dataPoints[1].x - dataPoints[0].x, precision);
  final s = applyPrecision((targetX - dataPoints[0].x) / h, precision);

  // Build forward difference table.
  final diffTable = List.generate(n, (i) => List.filled(n, 0.0));
  for (int i = 0; i < n; i++) {
    diffTable[i][0] = applyPrecision(dataPoints[i].y, precision);
  }

  for (int j = 1; j < n; j++) {
    for (int i = 0; i < n - j; i++) {
      diffTable[i][j] = applyPrecision(
        diffTable[i + 1][j - 1] - diffTable[i][j - 1],
        precision,
      );
    }
  }

  // Record difference table as step.
  final tableValues = <String, double>{};
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n - i; j++) {
      tableValues['Δ$j f[$i]'] = diffTable[i][j];
    }
  }
  tableValues['h'] = h;
  tableValues['s'] = s;
  steps.add(IterationStep(iteration: 0, values: tableValues));

  // Newton forward formula.
  double result = applyPrecision(diffTable[0][0], precision);
  double sTerm = 1.0;

  for (int k = 1; k < n; k++) {
    sTerm = applyPrecision(sTerm * (s - (k - 1)) / k, precision);
    final term = applyPrecision(sTerm * diffTable[0][k], precision);
    result = applyPrecision(result + term, precision);

    steps.add(IterationStep(
      iteration: k,
      values: {
        'term_$k': term,
        's_term': sTerm,
        'Δ$k f[0]': diffTable[0][k],
        'partial_sum': result,
      },
    ));
  }

  return MethodResult(
    answer: result,
    iterations: n - 1,
    steps: steps,
    converged: true,
  );
}
