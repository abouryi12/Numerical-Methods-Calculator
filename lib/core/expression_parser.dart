import 'package:math_expressions/math_expressions.dart';

/// Wraps the `math_expressions` package for parsing, evaluating,
/// and differentiating user-typed math expressions.
class ExpressionParser {
  final GrammarParser _parser = GrammarParser();
  final ContextModel _context = ContextModel();

  ExpressionParser() {
    _context.bindVariable(Variable('e'), Number(2.718281828459045));
    _context.bindVariable(Variable('pi'), Number(3.141592653589793));
  }

  /// Parses [expr] string and evaluates it at [x].
  ///
  /// Supported: +, -, *, /, ^, sin, cos, tan, exp, ln, log, sqrt, abs
  double evaluate(String expr, double x) {
    final expression = _parser.parse(_normalize(expr));
    _context.bindVariable(Variable('x'), Number(x));
    return expression.evaluate(EvaluationType.REAL, _context) as double;
  }

  /// Numerical derivative of [expr] at [x] using central difference.
  ///
  /// f'(x) ≈ [f(x+h) - f(x-h)] / (2h)
  double evaluateDerivative(String expr, double x, {double h = 1e-8}) {
    final fxPlusH = evaluate(expr, x + h);
    final fxMinusH = evaluate(expr, x - h);
    return (fxPlusH - fxMinusH) / (2 * h);
  }

  /// Converts a user expression to a basic LaTeX string for rendering.
  ///
  /// This is a best-effort conversion — complex expressions may
  /// not render perfectly.
  String toLatex(String expr) {
    if (expr.trim().isEmpty) return '';

    var latex = expr.trim();

    // Replace common functions with LaTeX equivalents.
    latex = latex.replaceAll('sqrt', '\\sqrt');
    latex = latex.replaceAll('sin', '\\sin');
    latex = latex.replaceAll('cos', '\\cos');
    latex = latex.replaceAll('tan', '\\tan');
    latex = latex.replaceAll('log', '\\log');
    latex = latex.replaceAll('ln', '\\ln');
    latex = latex.replaceAll('exp', '\\exp');
    latex = latex.replaceAll('abs', '\\left|');
    latex = latex.replaceAll('*', ' \\cdot ');

    // Replace ^ with proper superscript where possible.
    latex = latex.replaceAllMapped(
      RegExp(r'\^(\d+)'),
      (m) => '^{${m.group(1)}}',
    );
    latex = latex.replaceAllMapped(
      RegExp(r'\^\(([^)]+)\)'),
      (m) => '^{${m.group(1)}}',
    );

    return latex;
  }

  String _normalize(String expr) {
    var normalized = expr.trim().toLowerCase();
    
    // Replace mathematical italic characters often copied from PDFs
    normalized = normalized.replaceAll('𝑥', 'x');
    normalized = normalized.replaceAll('𝑒', 'e');
    
    // Replace smart dashes/typographical minus signs with standard hyphen-minus
    normalized = normalized.replaceAll('–', '-'); // en-dash
    normalized = normalized.replaceAll('—', '-'); // em-dash
    normalized = normalized.replaceAll('−', '-'); // mathematical minus
    
    // Ensure all x are bound correctly
    normalized = normalized.replaceAll('ln', 'log');
    
    // Convert e^... to (e^(...)) to prevent precedence issues and avoid unsupported 'exp' function
    // Matches e^(...)
    normalized = normalized.replaceAllMapped(RegExp(r'e\^\(([^)]+)\)'), (m) => '(e^(${m.group(1)}))');
    // Matches e^-x, e^-2x, etc.
    normalized = normalized.replaceAllMapped(RegExp(r'e\^-([a-zA-Z0-9.]+)'), (m) => '(e^(-${m.group(1)}))');
    // Matches e^x, e^2x, etc.
    normalized = normalized.replaceAllMapped(RegExp(r'e\^([a-zA-Z0-9.]+)'), (m) => '(e^(${m.group(1)}))');
    
    // Also convert any explicit exp(...) to (e^(...)) just in case
    normalized = normalized.replaceAllMapped(RegExp(r'exp\(([^)]+)\)'), (m) => '(e^(${m.group(1)}))');
    
    // Add implicit multiplication: 2x -> 2*x, 3.5x -> 3.5*x
    normalized = normalized.replaceAllMapped(RegExp(r'(\d)(x)'), (match) {
      return '${match.group(1)}*${match.group(2)}';
    });
    // Add implicit multiplication: x( -> x*(, )( -> )*(, digit( -> digit*(
    normalized = normalized.replaceAllMapped(RegExp(r'(x|\d|\))(\()'), (match) {
      return '${match.group(1)}*(';
    });
    // Add implicit multiplication: )x -> )*x
    normalized = normalized.replaceAllMapped(RegExp(r'(\))(x)'), (match) {
      return '${match.group(1)}*${match.group(2)}';
    });
    // Add implicit multiplication before functions: 2sin -> 2*sin, xsin -> x*sin
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d|x)(sin|cos|tan|log|sqrt|exp|abs)'),
      (match) => '${match.group(1)}*${match.group(2)}',
    );

    return normalized;
  }
}
