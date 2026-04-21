import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Numeri',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: kTextPrimary,
                      ),
                ),
                TextSpan(
                  text: 'X',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: kAccentBlue,
                      ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        toolbarHeight: 96,
      ),
      body: Align(
        alignment: const Alignment(0, -0.5),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: kSpace5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  // Bigger cards on mobile (taller), normal on tablet.
                  final ratio = constraints.maxWidth < 400 ? 0.78 : 1.0;
                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: kSpace4,
                    crossAxisSpacing: kSpace4,
                    childAspectRatio: ratio,
                    children: [
                      CategoryCard(
                        title: 'Root Finding',
                        imagePath: 'assets/images/bg_root_finding.png',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.methodSelection,
                          arguments: 'Root Finding',
                        ),
                      ),
                      CategoryCard(
                        title: 'Linear Systems',
                        imagePath: 'assets/images/bg_linear_systems.png',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.methodSelection,
                          arguments: 'Linear Systems',
                        ),
                      ),
                      CategoryCard(
                        title: 'Iterative Solutions',
                        imagePath: 'assets/images/bg_iterative.png',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.methodSelection,
                          arguments: 'Iterative',
                        ),
                      ),
                      CategoryCard(
                        title: 'Interpolation',
                        imagePath: 'assets/images/bg_interpolation.png',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.methodSelection,
                          arguments: 'Interpolation',
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
