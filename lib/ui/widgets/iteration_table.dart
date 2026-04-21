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

    // Get all column names from the first step.
    final columns = widget.steps.first.values.keys.toList();

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
              border: Border.all(color: kBgBorder, width: 1),
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
              border: Border.all(color: kBgBorder, width: 1),
              borderRadius: BorderRadius.circular(kRadiusSM),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(kBgSurface),
                dataRowColor: WidgetStateProperty.all(kBgBase),
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 36,
                columnSpacing: kSpace4,
                horizontalMargin: kSpace3,
                columns: [
                  DataColumn(
                    label: Text(
                      '#',
                      style: monoStyle(
                        fontSize: kTextXS,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ...columns.map(
                    (col) => DataColumn(
                      label: Text(
                        col,
                        style: monoStyle(
                          fontSize: kTextXS,
                          color: kTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
                rows: widget.steps.map((step) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          '${step.iteration}',
                          style: monoStyle(
                            fontSize: kTextXS,
                            color: kTextMuted,
                          ),
                        ),
                      ),
                      ...columns.map((col) {
                        final value = step.values[col];
                        return DataCell(
                          Text(
                            value != null ? _formatValue(value) : '—',
                            style: monoStyle(
                              fontSize: kTextXS,
                              color: kTextPrimary,
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
