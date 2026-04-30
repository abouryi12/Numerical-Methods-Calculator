import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/navigation/app_router.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/responsive_container.dart';

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
          child: ResponsiveContainer(
            maxWidth: 560,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Always 2 columns, slightly taller on laptop
                    final width = constraints.maxWidth;
                    const crossAxisCount = 2;
                    double ratio;
                    if (width >= 500) {
                      ratio = 0.9; // slightly bigger on laptop
                    } else if (width >= 400) {
                      ratio = 1.0;
                    } else {
                      ratio = 0.78;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
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
      ),
    );
  }
}
