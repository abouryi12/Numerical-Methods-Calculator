import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Minimal, structural category card for a grid layout with a real background image.
class CategoryCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedSlide(
        offset: _isPressed ? const Offset(0, -0.03) : Offset.zero,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: AnimatedScale(
          scale: _isPressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.black, // Force black base
              borderRadius: BorderRadius.circular(kRadiusMD),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusMD),
              border: Border.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image — scaled slightly to crop any baked-in grey borders
                Positioned.fill(
                  child: Transform.scale(
                    scale: 1.05,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                // Foreground Content
                Positioned(
                  left: kSpace4,
                  right: kSpace4,
                  bottom: kSpace4,
                  child: Text(
                    widget.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: kTextBase,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.9),
                              blurRadius: 20,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
