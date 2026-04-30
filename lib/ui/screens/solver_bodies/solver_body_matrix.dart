import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/solver_provider.dart';
import '../../../core/validators/linear_system_validator.dart';
import '../../../core/validators/iterative_validator.dart';
import '../../../core/validators/validation_result.dart';
import '../../../models/method_input.dart';
import '../../theme/app_theme.dart';
import '../../widgets/matrix_grid.dart';

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
  late int _size;
  late List<List<double>> _matrix;
  late List<double> _vectorB;
  late List<double> _initialVector;
  final _tolController = TextEditingController(text: '0.0001');
  final _iterController = TextEditingController(text: '50');
  final _initialVectorController = TextEditingController();

  String? _validationError;
  int _gridKey = 0;
  bool _wasRearranged = false;

  @override
  void initState() {
    super.initState();
    _size = widget.method == NumericalMethod.thomasAlgorithm ? 4 : 3;
    _initMatrixAndVector();
  }

  void _initMatrixAndVector() {
    _matrix = List.generate(_size, (_) => List.filled(_size, 0.0));
    _vectorB = List.filled(_size, 0.0);
    _initialVector = List.filled(_size, 0.0);
    _initialVectorController.text = List.filled(_size, '0').join(', ');
  }

  @override
  void dispose() {
    _tolController.dispose();
    _iterController.dispose();
    _initialVectorController.dispose();
    super.dispose();
  }

  List<int> get _availableSizes {
    if (widget.method == NumericalMethod.thomasAlgorithm) {
      return [4, 5, 6];
    }
    return [2, 3, 4, 5, 6];
  }

  void _setSize(int size) {
    setState(() {
      _size = size;
      _initMatrixAndVector();
      _validationError = null;
    });
  }

  void _solve() {
    setState(() {
      _validationError = null;
      _wasRearranged = false;
    });

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

      // If not diagonally dominant, try auto-rearranging rows
      if (!validation.isValid &&
          validation.errorMessage != null &&
          validation.errorMessage!.contains('diagonally dominant')) {
        final success = IterativeValidator.makeDiagonallyDominant(
          matrix: _matrix,
          vectorB: _vectorB,
        );
        if (success) {
          _wasRearranged = true;
          _gridKey++;
          // Re-validate with rearranged matrix
          validation = IterativeValidator.validate(
            matrix: _matrix,
            vectorB: _vectorB,
            initialVector: _initialVector,
          );
        }
      }
    }

    if (!validation.isValid) {
      setState(() => _validationError = validation.errorMessage);
      return;
    }

    final tol = double.tryParse(_tolController.text) ?? 0.0001;
    final maxIter = int.tryParse(_iterController.text) ?? 50;

    final input = MethodInput(
      matrix: _matrix,
      vectorB: _vectorB,
      initialVector: widget.category == 'Iterative' ? _initialVector : null,
      tolerance: tol,
      maxIterations: maxIter,
    );

    // Trigger UI update if matrix was rearranged
    if (_wasRearranged) {
      setState(() {});
    }

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
          key: ValueKey(_gridKey),
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
        
        if (_wasRearranged) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_fix_high, color: Color(0xFF4CAF50), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Rows rearranged automatically for diagonal dominance',
                    style: GoogleFonts.inter(color: const Color(0xFF81C784), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            controller: _initialVectorController,
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
        children: _availableSizes.map((size) {
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
