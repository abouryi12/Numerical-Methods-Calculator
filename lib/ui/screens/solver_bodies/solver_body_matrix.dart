import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/precision_provider.dart';
import '../../../core/providers/solver_provider.dart';
import '../../../core/validators/linear_system_validator.dart';
import '../../../core/validators/iterative_validator.dart';
import '../../../core/validators/validation_result.dart';
import '../../../models/method_input.dart';
import '../../theme/app_theme.dart';
import '../../widgets/matrix_grid.dart';
import '../../widgets/precision_panel.dart';

class SolverBodyMatrix extends ConsumerStatefulWidget {
  final NumericalMethod method;
  final String category;

  const SolverBodyMatrix({
    super.key,
    required this.method,
    required this.category,
  });

  @override
  ConsumerState<SolverBodyMatrix> createState() => _SolverBodyMatrixState();
}

class _SolverBodyMatrixState extends ConsumerState<SolverBodyMatrix> {
  int _size = 3;
  late List<List<double>> _matrix;
  late List<double> _vectorB;
  late List<double> _initialVector;
  final _tolController = TextEditingController(text: '0.0001');
  final _iterController = TextEditingController(text: '50');

  String? _validationError;

  @override
  void initState() {
    super.initState();
    _initMatrixAndVector();
  }

  void _initMatrixAndVector() {
    _matrix = List.generate(_size, (_) => List.filled(_size, 0.0));
    _vectorB = List.filled(_size, 0.0);
    _initialVector = List.filled(_size, 0.0);
  }

  @override
  void dispose() {
    _tolController.dispose();
    _iterController.dispose();
    super.dispose();
  }

  void _setSize(int size) {
    setState(() {
      _size = size;
      _initMatrixAndVector();
      _validationError = null;
    });
  }

  void _solve() {
    setState(() => _validationError = null);

    var validation = const ValidationResult.valid();
    if (widget.method == NumericalMethod.doolittleLU) {
      validation = LinearSystemValidator.validateLU(matrix: _matrix, vectorB: _vectorB);
    } else if (widget.method == NumericalMethod.thomasAlgorithm) {
      validation = LinearSystemValidator.validateThomas(matrix: _matrix, vectorB: _vectorB);
    } else if (widget.category == 'Iterative') {
      validation = IterativeValidator.validate(
        matrix: _matrix,
        vectorB: _vectorB,
        initialVector: _initialVector,
      );
    }

    if (!validation.isValid) {
      setState(() => _validationError = validation.errorMessage);
      return;
    }

    final precision = ref.read(precisionProvider);
    final tol = double.tryParse(_tolController.text) ?? 0.0001;
    final maxIter = int.tryParse(_iterController.text) ?? 50;

    final input = MethodInput(
      matrix: _matrix,
      vectorB: _vectorB,
      initialVector: widget.category == 'Iterative' ? _initialVector : null,
      tolerance: tol,
      maxIterations: maxIter,
      precision: precision,
    );

    ref.read(solverProvider.notifier).solve(widget.method, input);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(solverProvider).isLoading;
    final isIterative = widget.category == 'Iterative';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Matrix size selector
        _sectionLabel('MATRIX SIZE'),
        const SizedBox(height: 10),
        _buildSizeSelector(),
        const SizedBox(height: 16),

        // Divider
        Container(height: 1, color: const Color(0xFF232329)),
        const SizedBox(height: 16),

        // Matrix grid
        _sectionLabel('COEFFICIENT MATRIX  [A | b]'),
        const SizedBox(height: 10),
        MatrixGrid(
          size: _size,
          matrix: _matrix,
          vectorB: _vectorB,
          onMatrixChanged: (m) {
            _matrix = m;
            if (_validationError != null) setState(() => _validationError = null);
          },
          onVectorChanged: (v) {
            _vectorB = v;
            if (_validationError != null) setState(() => _validationError = null);
          },
        ),
        
        if (_validationError != null) ...[
          const SizedBox(height: 10),
          Text(_validationError!, style: const TextStyle(color: kErrorText, fontSize: kTextSM)),
        ],

        if (isIterative) ...[
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0xFF232329)),
          const SizedBox(height: 16),

          _sectionLabel('INITIAL GUESS'),
          const SizedBox(height: 10),
          _buildInput(
            controller: TextEditingController(text: _initialVector.join(', ')),
            hint: 'Comma separated (e.g. 0, 0, 0)',
            onChanged: (val) {
              final parts = val.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
              for (int i = 0; i < _size; i++) {
                _initialVector[i] = i < parts.length ? parts[i] : 0.0;
              }
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInput(controller: _tolController, hint: 'Tolerance'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInput(controller: _iterController, hint: 'Max Iterations'),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),
        Container(height: 1, color: const Color(0xFF232329)),
        const SizedBox(height: 16),

        const PrecisionPanel(),
        
        const SizedBox(height: 20),
        _solveButton(isLoading),
      ],
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: kBgBase,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF232329), width: 1),
      ),
      child: Row(
        children: [2, 3, 4, 5, 6].map((size) {
          final isSelected = size == _size;
          return Expanded(
            child: GestureDetector(
              onTap: () => _setSize(size),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4A8FE8).withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(
                          color: const Color(0xFF4A8FE8).withValues(alpha: 0.3),
                          width: 1)
                      : null,
                ),
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                child: Text(
                  '${size}x$size',
                  style: GoogleFonts.robotoMono(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? const Color(0xFF4A8FE8)
                        : kTextSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
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
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _solve,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A8FE8),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF1A1B24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'SOLVE',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
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
        filled: true,
        fillColor: kBgBase,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF232329)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF232329)),
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
