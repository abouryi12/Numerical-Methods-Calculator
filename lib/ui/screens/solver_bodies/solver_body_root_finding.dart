import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/solver_provider.dart';
import '../../../core/validators/root_finding_validator.dart';
import '../../../core/validators/validation_result.dart';
import '../../../models/method_input.dart';
import '../../theme/app_theme.dart';
import '../../widgets/math_input_field.dart';

class SolverBodyRootFinding extends ConsumerStatefulWidget {
  final NumericalMethod method;

  const SolverBodyRootFinding({super.key, required this.method});

  @override
  ConsumerState<SolverBodyRootFinding> createState() => _SolverBodyRootFindingState();
}

class _SolverBodyRootFindingState extends ConsumerState<SolverBodyRootFinding> {
  String _expression = '';
  final _aController = TextEditingController();
  final _bController = TextEditingController();
  final _tolController = TextEditingController(text: '0.0001');
  final _iterController = TextEditingController(text: '50');

  String? _expressionError;
  String? _aError;
  String? _bError;

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _tolController.dispose();
    _iterController.dispose();
    super.dispose();
  }

  void _solve() {
    setState(() {
      _expressionError = null;
      _aError = null;
      _bError = null;
    });

    final a = double.tryParse(_aController.text);
    final b = double.tryParse(_bController.text);
    final tol = double.tryParse(_tolController.text) ?? 0.0001;
    final maxIter = int.tryParse(_iterController.text) ?? 50;
    
    if (_expression.isEmpty) {
      setState(() => _expressionError = 'Please enter a function');
      return;
    }

    if (a == null) {
      setState(() => _aError = 'Invalid number');
      return;
    }

    if (widget.method != NumericalMethod.newtonRaphson && b == null) {
      setState(() => _bError = 'Invalid number');
      return;
    }

    var validation = const ValidationResult.valid();
    if (widget.method == NumericalMethod.bisection || widget.method == NumericalMethod.falsePosition) {
      validation = RootFindingValidator.validateBracket(expression: _expression, a: a, b: b!);
    } else if (widget.method == NumericalMethod.newtonRaphson) {
      validation = RootFindingValidator.validateNewton(expression: _expression, x0: a);
    } else if (widget.method == NumericalMethod.secant) {
      validation = RootFindingValidator.validateSecant(expression: _expression, x0: a, x1: b!);
    }

    if (!validation.isValid) {
      setState(() => _expressionError = validation.errorMessage);
      return;
    }

    final input = MethodInput(
      expression: _expression,
      initialValues: widget.method == NumericalMethod.newtonRaphson ? [a] : [a, b!],
      tolerance: tol,
      maxIterations: maxIter,
    );

    ref.read(solverProvider.notifier).solve(widget.method, input);
  }

  @override
  Widget build(BuildContext context) {
    final isNewton = widget.method == NumericalMethod.newtonRaphson;
    final isSecant = widget.method == NumericalMethod.secant;
    final isLoading = ref.watch(solverProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Function input
        MathInputField(
          onChanged: (val) {
            _expression = val;
            if (_expressionError != null) setState(() => _expressionError = null);
          },
          errorText: _expressionError,
        ),
        const SizedBox(height: 16),

        // Divider
        Container(height: 1, color: const Color(0xFF232329)),
        const SizedBox(height: 16),

        // Parameters section
        _sectionLabel('PARAMETERS'),
        const SizedBox(height: 10),
        
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInput(
                controller: _aController,
                hint: isNewton ? 'x₀' : (isSecant ? 'X0' : 'a'),
                errorText: _aError,
                onChanged: (_) {
                  if (_aError != null) setState(() => _aError = null);
                },
              ),
            ),
            if (!isNewton) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  controller: _bController,
                  hint: isSecant ? 'X1' : 'b',
                  errorText: _bError,
                  onChanged: (_) {
                    if (_bError != null) setState(() => _bError = null);
                  },
                ),
              ),
            ]
          ],
        ),
        if (widget.method != NumericalMethod.bisection) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  controller: _tolController,
                  hint: 'Tolerance',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(
                  controller: _iterController,
                  hint: 'Max Iterations',
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 20),

        // Solve button
        _solveButton(isLoading),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B6B80),
        letterSpacing: 0.88,
      ),
    );
  }

  Widget _solveButton(bool isLoading) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: isLoading ? 48 : constraints.maxWidth,
            height: 48,
            decoration: BoxDecoration(
              color: isLoading ? Colors.transparent : const Color(0xFF2A61C2),
              borderRadius: BorderRadius.circular(isLoading ? 24 : 10),
              border: isLoading ? Border.all(color: const Color(0xFF2A61C2), width: 2) : null,
              boxShadow: isLoading
                  ? [
                      BoxShadow(
                        color: const Color(0xFF2A61C2).withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : _solve,
                borderRadius: BorderRadius.circular(isLoading ? 24 : 10),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2A61C2)),
                          ),
                        )
                      : Text(
                          'SOLVE',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      style: monoStyle(fontSize: kTextBase, color: kTextPrimary),
      cursorColor: const Color(0xFF4A8FE8),
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: kBgBase,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF4A8FE8)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
