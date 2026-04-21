import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MethodListItem extends StatefulWidget {
  final String name;
  final String description;
  final VoidCallback onTap;

  const MethodListItem({
    super.key,
    required this.name,
    required this.description,
    required this.onTap,
  });

  @override
  State<MethodListItem> createState() => _MethodListItemState();
}

class _MethodListItemState extends State<MethodListItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF111116),
          border: Border.all(color: const Color(0xFF232329), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: _pressed ? const Color(0xFF4A8FE8) : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 20, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFF0F0F5),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: GoogleFonts.robotoMono(
                          fontSize: 12,
                          color: const Color(0xFF6B6B80),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
