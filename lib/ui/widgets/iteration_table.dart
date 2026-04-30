import 'package:flutter/material.dart';
import '../../models/method_result.dart';
import '../theme/app_theme.dart';

/// Expandable step-by-step iteration table.
class IterationTable extends StatefulWidget {
  final List<IterationStep> steps;

  const IterationTable({super.key, required this.steps});

  @override
  State<IterationTable> createState() => _IterationTableState();
}

class _IterationTableState extends State<IterationTable> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    // Get all unique column names across all steps (preserving order).
    final columnSet = <String>{};
    for (final step in widget.steps) {
      columnSet.addAll(step.values.keys);
    }
    final columns = columnSet.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: kSpace4),

        // Toggle header.
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: kSpace3,
              horizontal: kSpace4,
            ),
            decoration: BoxDecoration(
              color: kBgSurface,
              borderRadius: BorderRadius.circular(kRadiusSM),
              border: Border.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ITERATION TABLE',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                  color: kTextSecondary,
                ),
              ],
            ),
          ),
        ),

        // Table content.
        if (_expanded) ...[
          const SizedBox(height: kSpace2),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
              borderRadius: BorderRadius.circular(kRadiusSM),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(kBgSurface),
                dataRowColor: WidgetStateProperty.all(kBgBase),
                columnSpacing: 24,
                horizontalMargin: 16,
                headingRowHeight: 40,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 36,
                dividerThickness: 0.4,
                border: TableBorder(
                  horizontalInside: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
                  bottom: BorderSide(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
                ),
                columns: [
                  ...columns.map(
                    (col) => DataColumn(
                      label: Text(
                        col,
                        style: monoStyle(
                          fontSize: kTextXS,
                          color: const Color(0xFF4A8FE8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                rows: widget.steps.map((step) {
                  return DataRow(
                    cells: [
                      ...columns.map((col) {
                        final value = step.values[col];
                        // Format 'Iteration' and 'Iter' as integers.
                        final isIterCol = col == 'Iteration' || col == 'Iter';
                        return DataCell(
                          Text(
                            value != null
                                ? (isIterCol
                                    ? value.toInt().toString()
                                    : _formatValue(value))
                                : '—',
                            style: monoStyle(
                              fontSize: kTextXS,
                              color: isIterCol
                                  ? kTextSecondary
                                  : kTextPrimary,
                              fontWeight: isIterCol
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatValue(double v) {
    if (v == double.infinity) return '∞';
    if (v == double.negativeInfinity) return '-∞';
    if (v.isNaN) return 'NaN';

    // Show up to 8 decimal places, remove trailing zeros.
    final s = v.toStringAsFixed(8);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
