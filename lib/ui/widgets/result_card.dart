import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/method_result.dart';
import '../theme/app_theme.dart';

/// Displays the final answer, stats, and convergence status.
class ResultCard extends StatelessWidget {
  final MethodResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Error message if computation failed.
        if (result.errorMessage != null && result.answer == null && result.solutionVector == null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kError.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kError.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: kErrorText, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.errorMessage!,
                    style: GoogleFonts.inter(
                      fontSize: kTextSM,
                      color: kErrorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Result label + badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RESULT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6B6B80),
                  letterSpacing: 0.88,
                ),
              ),
              _ConvergenceBadge(converged: result.converged),
            ],
          ),
          const SizedBox(height: 12),

          // Answer.
          if (result.answer != null)
            Text(
              result.answer!.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), ''),
              style: GoogleFonts.robotoMono(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A8FE8),
              ),
            ),

          // Solution vector.
          if (result.solutionVector != null) ...[
            for (int i = 0; i < result.solutionVector!.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'x${_subscript(i)}',
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: kTextSecondary,
                        ),
                      ),
                      TextSpan(
                        text: ' = ',
                        style: GoogleFonts.robotoMono(
                          fontSize: 16,
                          color: kTextMuted,
                        ),
                      ),
                      TextSpan(
                        text: _formatNum(result.solutionVector![i]),
                        style: GoogleFonts.robotoMono(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4A8FE8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: 14),

          // Stats row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kBgBase,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF232329)),
            ),
            child: Row(
              children: [
                _statItem('Iterations', '${result.iterations}'),
                if (result.approximateError != null) ...[
                  Container(
                    width: 1,
                    height: 20,
                    color: const Color(0xFF232329),
                    margin: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  _statItem('Error (ε)', _formatNum(result.approximateError!)),
                ],
              ],
            ),
          ),

          // Error message (if max iter reached but we do have a result).
          if (result.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              result.errorMessage!,
              style: GoogleFonts.inter(fontSize: kTextSM, color: kWarningText),
            ),
          ],
        ],
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6B80),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextPrimary,
          ),
        ),
      ],
    );
  }

  String _subscript(int i) {
    const subscripts = '₀₁₂₃₄₅₆₇₈₉';
    if (i < 10) return subscripts[i];
    return i.toString();
  }

  String _formatNum(double v) {
    final s = v.toStringAsFixed(10);
    return s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}

class _ConvergenceBadge extends StatelessWidget {
  final bool converged;

  const _ConvergenceBadge({required this.converged});

  @override
  Widget build(BuildContext context) {
    final color = converged ? const Color(0xFF2D6A4F) : const Color(0xFF78350F);
    final textColor = converged ? kSuccessText : kWarningText;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        converged ? '✓ CONVERGED' : '⚠ MAX ITERATIONS',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
