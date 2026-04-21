import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Minimal, structural category card for a grid layout with a real background image.
class CategoryCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: kBgBase,
          borderRadius: BorderRadius.circular(kRadiusMD),
          border: Border.all(color: kBgBorder, width: 1),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image — fill entire card
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            // Gradient overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.3, 1.0],
                    colors: [
                      kBgBase.withValues(alpha: 0.0),
                      kBgBase.withValues(alpha: 0.9),
                    ],
                  ),
                ),
              ),
            ),
            // Foreground Content
            Positioned(
              left: kSpace4,
              right: kSpace4,
              bottom: kSpace4,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: kTextBase,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
