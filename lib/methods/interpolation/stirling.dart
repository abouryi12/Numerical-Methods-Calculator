import '../../core/precision/precision_utils.dart';
import '../../models/method_input.dart';
import '../../models/method_result.dart';
import '../../models/precision_settings.dart';

/// Stirling's Interpolation Formula.
///
/// Central difference method — requires odd number of points.
/// Uses the central point as origin.
MethodResult stirling({
  required List<DataPoint> dataPoints,
  required double targetX,
  required PrecisionSettings precision,
}) {
  final n = dataPoints.length;
  final steps = <IterationStep>[];
  final mid = n ~/ 2; // center index

  final h = applyPrecision(dataPoints[1].x - dataPoints[0].x, precision);
  final s = applyPrecision((targetX - dataPoints[mid].x) / h, precision);

  // Build central difference table.
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

  // Record the difference table.
  final tableValues = <String, double>{};
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n - i; j++) {
      tableValues['δ$j[$i]'] = diffTable[i][j];
    }
  }
  tableValues['h'] = h;
  tableValues['s'] = s;
  tableValues['center'] = dataPoints[mid].x;
  steps.add(IterationStep(iteration: 0, values: tableValues));

  // Stirling's formula: uses average of forward and backward differences
  // for odd-order terms.
  double result = applyPrecision(diffTable[mid][0], precision);

  double sProduct = s;
  double s2Product = s * s;

  for (int k = 1; k < n; k++) {
    double term;
    if (k.isOdd) {
      // Odd order: average of δ^k[mid] and δ^k[mid-1]
      final order = (k + 1) ~/ 2;
      final upperIdx = mid - order + 1;
      final lowerIdx = mid - order;

      if (upperIdx < 0 || lowerIdx < 0 || upperIdx >= n - k || lowerIdx >= n - k) break;

      final avg = applyPrecision(
        (diffTable[upperIdx][k] + diffTable[lowerIdx][k]) / 2.0,
        precision,
      );

      double factorial = 1;
      for (int f = 1; f <= k; f++) {
        factorial *= f;
      }

      term = applyPrecision(sProduct * avg / factorial, precision);
      sProduct = applyPrecision(sProduct * (s * s - (order * order).toDouble()), precision);
    } else {
      // Even order: use δ^k[mid - k/2]
      final idx = mid - k ~/ 2;
      if (idx < 0 || idx >= n - k) break;

      double factorial = 1;
      for (int f = 1; f <= k; f++) {
        factorial *= f;
      }

      term = applyPrecision(s2Product * diffTable[idx][k] / factorial, precision);
      s2Product = applyPrecision(
        s2Product * (s * s - ((k ~/ 2) * (k ~/ 2)).toDouble()),
        precision,
      );
    }

    result = applyPrecision(result + term, precision);

    steps.add(IterationStep(
      iteration: k,
      values: {
        'order': k.toDouble(),
        'term_$k': term,
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
