import 'package:math_expressions/math_expressions.dart';
void main() {
  try {
    final parser = GrammarParser();
    final expr = parser.parse('x^3 - x - 2');
    final cm = ContextModel();
    cm.bindVariable(Variable('x'), Number(1.0));
    print(expr.evaluate(EvaluationType.REAL, cm));
  } catch(e) {
    print('Error: $e');
  }
}
