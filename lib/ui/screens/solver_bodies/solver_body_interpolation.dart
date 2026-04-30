import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/providers/solver_provider.dart';
import '../../../core/validators/interpolation_validator.dart';
import '../../../core/validators/validation_result.dart';
import '../../../models/method_input.dart';
import '../../theme/app_theme.dart';

class SolverBodyInterpolation extends ConsumerStatefulWidget {
  final NumericalMethod method;

  const SolverBodyInterpolation({super.key, required this.method});

  @override
  ConsumerState<SolverBodyInterpolation> createState() => _SolverBodyInterpolationState();
}

class _SolverBodyInterpolationState extends ConsumerState<SolverBodyInterpolation> {
  final List<DataPoint> _dataPoints = [
    const DataPoint(x: 0, y: 0),
    const DataPoint(x: 1, y: 1),
  ];
  final _targetXController = TextEditingController();
  
  String? _validationError;
  String? _targetXError;

  @override
  void dispose() {
    _targetXController.dispose();
    super.dispose();
  }

  void _addDataPoint() {
    setState(() {
      _dataPoints.add(const DataPoint(x: 0, y: 0));
      _validationError = null;
    });
  }

  void _removeDataPoint(int index) {
    if (_dataPoints.length > 2) {
      setState(() {
        _dataPoints.removeAt(index);
        _validationError = null;
      });
    }
  }

  void _updateDataPoint(int index, String xStr, String yStr) {
    final x = double.tryParse(xStr) ?? _dataPoints[index].x;
    final y = double.tryParse(yStr) ?? _dataPoints[index].y;
    _dataPoints[index] = DataPoint(x: x, y: y);
    if (_validationError != null) setState(() => _validationError = null);
  }

  void _solve() {
    setState(() {
      _validationError = null;
      _targetXError = null;
    });

    final targetX = double.tryParse(_targetXController.text);
    if (targetX == null) {
      setState(() => _targetXError = 'Invalid number');
      return;
    }

    var validation = const ValidationResult.valid();
    if (widget.method == NumericalMethod.newtonForward || widget.method == NumericalMethod.newtonBackward) {
      validation = InterpolationValidator.validateEqualSpacing(dataPoints: _dataPoints, targetX: targetX);
    } else if (widget.method == NumericalMethod.stirling) {
      validation = InterpolationValidator.validateStirling(dataPoints: _dataPoints, targetX: targetX);
    } else if (widget.method == NumericalMethod.lagrange) {
      validation = InterpolationValidator.validateLagrange(dataPoints: _dataPoints, targetX: targetX);
    }

    if (!validation.isValid) {
      setState(() => _validationError = validation.errorMessage);
      return;
    }

    final input = MethodInput(
      dataPoints: _dataPoints,
      targetX: targetX,
    );

    ref.read(solverProvider.notifier).solve(widget.method, input);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(solverProvider).isLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('DATA POINTS'),
        const SizedBox(height: 10),
        
        // Data points table
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
            borderRadius: BorderRadius.circular(10),
            color: kBgBase,
          ),
          child: Column(
            children: [
              // Header row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('x', textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          color: const Color(0xFF4A8FE8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text('f(x)', textAlign: TextAlign.center,
                        style: GoogleFonts.robotoMono(
                          color: const Color(0xFF4A8FE8),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              // Data rows
              ...List.generate(_dataPoints.length, (index) {
                return Container(
                  decoration: BoxDecoration(
                    border: index < _dataPoints.length - 1
                        ? Border(bottom: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4))
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DataPointField(
                          initialValue: _dataPoints[index].x.toString(),
                          onChanged: (val) => _updateDataPoint(index, val, _dataPoints[index].y.toString()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DataPointField(
                          initialValue: _dataPoints[index].y.toString(),
                          onChanged: (val) => _updateDataPoint(index, _dataPoints[index].x.toString(), val),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: _dataPoints.length > 2 ? kErrorText : kTextMuted,
                            size: 18,
                          ),
                          onPressed: _dataPoints.length > 2 ? () => _removeDataPoint(index) : null,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              // Add row button
              GestureDetector(
                onTap: _addDataPoint,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xFF232329))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, size: 16, color: Color(0xFF4A8FE8)),
                      const SizedBox(width: 6),
                      Text(
                        'ADD ROW',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A8FE8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_validationError != null) ...[
          const SizedBox(height: 10),
          Text(_validationError!, style: const TextStyle(color: kErrorText, fontSize: kTextSM)),
        ],

        const SizedBox(height: 16),
        Container(height: 1, color: const Color(0xFF232329)),
        const SizedBox(height: 16),

        // Target X
        _sectionLabel('TARGET VALUE'),
        const SizedBox(height: 10),
        _buildInput(
          controller: _targetXController,
          hint: 'Target x value (e.g. 2.5)',
          errorText: _targetXError,
          onChanged: (_) {
            if (_targetXError != null) setState(() => _targetXError = null);
          },
        ),

        const SizedBox(height: 20),
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

class _DataPointField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _DataPointField({required this.initialValue, required this.onChanged});

  @override
  State<_DataPointField> createState() => _DataPointFieldState();
}

class _DataPointFieldState extends State<_DataPointField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      textAlign: TextAlign.center,
      style: monoStyle(fontSize: kTextBase, color: kTextPrimary),
      cursorColor: const Color(0xFF4A8FE8),
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}
