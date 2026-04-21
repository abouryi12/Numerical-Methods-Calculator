import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/precision_provider.dart';
import '../../models/precision_settings.dart';
import '../theme/app_theme.dart';

/// Precision control panel — rounding/chopping toggle + digit selector.
class PrecisionPanel extends ConsumerWidget {
  const PrecisionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final precision = ref.watch(precisionProvider);
    final notifier = ref.read(precisionProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Text(
          'PRECISION',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6B80),
            letterSpacing: 0.88,
          ),
        ),
        const SizedBox(height: 10),

        // Rounding / Chopping toggle.
        Container(
          height: 40,
          decoration: BoxDecoration(
            color: kBgBase,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF232329), width: 1),
          ),
          child: Row(
            children: [
              _SegmentButton(
                label: 'ROUNDING',
                isActive: precision.mode == PrecisionMode.rounding,
                onTap: () => notifier.setMode(PrecisionMode.rounding),
              ),
              _SegmentButton(
                label: 'CHOPPING',
                isActive: precision.mode == PrecisionMode.chopping,
                onTap: () => notifier.setMode(PrecisionMode.chopping),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Digit selector label
        Text(
          'SIGNIFICANT DIGITS',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B6B80),
            letterSpacing: 0.88,
          ),
        ),
        const SizedBox(height: 10),

        // Digit selector (1–10).
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: kBgBase,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF232329), width: 1),
          ),
          child: Row(
            children: List.generate(10, (index) {
              final digit = index + 1;
              final isSelected = precision.digits == digit;
              return Expanded(
                child: GestureDetector(
                  onTap: () => notifier.setDigits(digit),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A8FE8).withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF4A8FE8).withValues(alpha: 0.4),
                              width: 1)
                          : null,
                    ),
                    margin: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    child: Text(
                      '$digit',
                      style: GoogleFonts.robotoMono(
                        fontSize: 12,
                        color: isSelected
                            ? const Color(0xFF4A8FE8)
                            : kTextSecondary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF4A8FE8).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: const Color(0xFF4A8FE8).withValues(alpha: 0.3),
                    width: 1)
                : null,
          ),
          margin: const EdgeInsets.all(2),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF4A8FE8) : kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
