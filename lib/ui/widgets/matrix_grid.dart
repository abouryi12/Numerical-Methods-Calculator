import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tap-to-edit matrix grid for linear systems and iterative methods.
class MatrixGrid extends StatefulWidget {
  final int size;
  final List<List<double>> matrix;
  final List<double> vectorB;
  final ValueChanged<List<List<double>>> onMatrixChanged;
  final ValueChanged<List<double>> onVectorChanged;

  const MatrixGrid({
    super.key,
    required this.size,
    required this.matrix,
    required this.vectorB,
    required this.onMatrixChanged,
    required this.onVectorChanged,
  });

  @override
  State<MatrixGrid> createState() => _MatrixGridState();
}

class _MatrixGridState extends State<MatrixGrid> {
  late List<List<TextEditingController>> _matrixControllers;
  late List<TextEditingController> _vectorControllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  @override
  void didUpdateWidget(MatrixGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.size != widget.size) {
      _disposeControllers();
      _initControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initControllers() {
    _matrixControllers = List.generate(
      widget.size,
      (i) => List.generate(
        widget.size,
        (j) {
          final v = widget.matrix[i][j];
          return TextEditingController(
            text: v != 0.0 ? _formatValue(v) : '',
          );
        },
      ),
    );
    _vectorControllers = List.generate(
      widget.size,
      (i) {
        final v = widget.vectorB[i];
        return TextEditingController(
          text: v != 0.0 ? _formatValue(v) : '',
        );
      },
    );
  }

  void _disposeControllers() {
    for (final row in _matrixControllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    for (final c in _vectorControllers) {
      c.dispose();
    }
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toString();
  }

  void _onMatrixCellChanged() {
    final matrix = List.generate(
      widget.size,
      (i) => List.generate(
        widget.size,
        (j) => double.tryParse(_matrixControllers[i][j].text) ?? 0.0,
      ),
    );
    widget.onMatrixChanged(matrix);
  }

  void _onVectorCellChanged() {
    final vector = List.generate(
      widget.size,
      (i) => double.tryParse(_vectorControllers[i].text) ?? 0.0,
    );
    widget.onVectorChanged(vector);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matrix A.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MATRIX A',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: kSpace2),
              _buildGrid(_matrixControllers, _onMatrixCellChanged),
            ],
          ),
          const SizedBox(width: kSpace4),
          // Vector b.
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VECTOR b',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const SizedBox(height: kSpace2),
              _buildVectorColumn(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
    List<List<TextEditingController>> controllers,
    VoidCallback onChange,
  ) {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(56),
      border: TableBorder.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
      children: List.generate(widget.size, (i) {
        return TableRow(
          children: List.generate(widget.size, (j) {
            return _MatrixCell(
              controller: controllers[i][j],
              onChanged: (_) => onChange(),
            );
          }),
        );
      }),
    );
  }

  Widget _buildVectorColumn() {
    return Table(
      defaultColumnWidth: const FixedColumnWidth(56),
      border: TableBorder.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
      children: List.generate(widget.size, (i) {
        return TableRow(
          children: [
            _MatrixCell(
              controller: _vectorControllers[i],
              onChanged: (_) => _onVectorCellChanged(),
            ),
          ],
        );
      }),
    );
  }
}

class _MatrixCell extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _MatrixCell({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: kBgElevated,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: monoStyle(fontSize: kTextBase, color: kTextPrimary),
        cursorColor: kAccentBlue,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        decoration: InputDecoration(
          hintText: '0',
          hintStyle: monoStyle(fontSize: kTextBase, color: const Color(0xFF3A3A4A)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
          filled: false,
        ),
      ),
    );
  }
}
