import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/navigation/app_router.dart';
import '../../core/providers/solver_provider.dart';
import '../theme/app_theme.dart';

class MethodSelectionScreen extends StatefulWidget {
  final String category;

  const MethodSelectionScreen({super.key, required this.category});

  @override
  State<MethodSelectionScreen> createState() => _MethodSelectionScreenState();
}

class _MethodSelectionScreenState extends State<MethodSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _headerController;
  late Animation<double> _iconScale;
  late Animation<double> _iconOpacity;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();

    // Header icon entrance animation.
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _iconScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeOutBack),
    );
    _iconOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _headerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _headerController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Staggered card entrance animation.
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start animations sequentially.
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _headerController.forward();
    });
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Color _accentForCategory() {
    // Unified app blue for all categories.
    return const Color(0xFF4A8FE8);
  }

  IconData _iconForCategory() {
    switch (widget.category) {
      case 'Root Finding':
        return CupertinoIcons.graph_circle;
      case 'Linear Systems':
        return CupertinoIcons.rectangle_grid_2x2;
      case 'Iterative':
        return CupertinoIcons.arrow_2_squarepath;
      case 'Interpolation':
        return Icons.trending_up_rounded;
      default:
        return Icons.category;
    }
  }

  String _subtitleForCategory() {
    switch (widget.category) {
      case 'Root Finding':
        return 'Find where f(x) = 0 using iterative bracketing & tangent methods.';
      case 'Linear Systems':
        return 'Solve systems of linear equations using direct decomposition.';
      case 'Iterative':
        return 'Approximate solutions through successive iteration until convergence.';
      case 'Interpolation':
        return 'Estimate values between known data points using polynomials.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final methods = _getMethodsForCategory();
    final accent = _accentForCategory();

    return Scaffold(
      backgroundColor: kBgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Custom Header ──
          SliverToBoxAdapter(
            child: _buildHeader(context, accent),
          ),

          // ── Methods List ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final method = methods[index];
                  // Calculate stagger interval for each card.
                  final begin = (index / methods.length) * 0.5;
                  final end = begin + 0.5;
                  final curvedAnim = CurvedAnimation(
                    parent: _staggerController,
                    curve: Interval(begin.clamp(0, 1), end.clamp(0, 1),
                        curve: Curves.easeOutCubic),
                  );

                  return FadeTransition(
                    opacity: curvedAnim,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(curvedAnim),
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: index < methods.length - 1 ? 10 : 0,
                        ),
                        child: _MethodCard(
                          index: index,
                          name: method.name,
                          description: method.description,
                          accent: accent,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.solver,
                              arguments: {
                                'method': method.method,
                                'name': method.name,
                                'category': widget.category,
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                childCount: methods.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color accent) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      decoration: BoxDecoration(
        color: kBgBase,
        border: Border(
          bottom: BorderSide(color: kBgBorder.withValues(alpha: 0.5), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Back button row (left-aligned)
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111116),
                    border: Border.all(color: const Color(0xFF232329)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: kTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Centered animated icon
          AnimatedBuilder(
            animation: _headerController,
            builder: (context, child) {
              return Opacity(
                opacity: _iconOpacity.value,
                child: Transform.scale(
                  scale: _iconScale.value,
                  child: child,
                ),
              );
            },
            child: Icon(
              _iconForCategory(),
              size: 48,
              color: accent,
            ),
          ),
          const SizedBox(height: 16),

          // Centered title (fades in after icon)
          FadeTransition(
            opacity: _headerFade,
            child: Text(
              widget.category,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_MethodInfo> _getMethodsForCategory() {
    switch (widget.category) {
      case 'Root Finding':
        return [
          _MethodInfo('Bisection Method', 'Interval halving technique, reliable but slow.', NumericalMethod.bisection),
          _MethodInfo('False Position', 'Linear interpolation between bracket points.', NumericalMethod.falsePosition),
          _MethodInfo('Newton-Raphson', 'Tangent-based iteration, requires derivative.', NumericalMethod.newtonRaphson),
          _MethodInfo('Secant Method', 'Two-point derivative approximation.', NumericalMethod.secant),
        ];
      case 'Linear Systems':
        return [
          _MethodInfo('Doolittle LU', 'Decomposes matrix into lower and upper triangulars.', NumericalMethod.doolittleLU),
          _MethodInfo('Thomas Algorithm', 'O(n) solver for tridiagonal systems.', NumericalMethod.thomasAlgorithm),
        ];
      case 'Iterative':
        return [
          _MethodInfo('Jacobi Iteration', 'Simultaneous updates, requires diagonal dominance.', NumericalMethod.jacobi),
          _MethodInfo('Gauss-Seidel', 'Immediate updates, generally faster than Jacobi.', NumericalMethod.gaussSeidel),
        ];
      case 'Interpolation':
        return [
          _MethodInfo('Newton Forward', 'Difference table, best near the start of data.', NumericalMethod.newtonForward),
          _MethodInfo('Newton Backward', 'Difference table, best near the end of data.', NumericalMethod.newtonBackward),
          _MethodInfo('Stirling\'s Formula', 'Central differences, requires an odd number of points.', NumericalMethod.stirling),
          _MethodInfo('Lagrange', 'Basis polynomials, handles unequal spacing.', NumericalMethod.lagrange),
        ];
      default:
        return [];
    }
  }
}

// ─── Individual Method Card ───

class _MethodCard extends StatefulWidget {
  final int index;
  final String name;
  final String description;
  final Color accent;
  final VoidCallback onTap;

  const _MethodCard({
    required this.index,
    required this.name,
    required this.description,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_MethodCard> createState() => _MethodCardState();
}

class _MethodCardState extends State<_MethodCard> {
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
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: const Color(0xFF111116),
            border: Border.all(
              color: const Color(0xFF232329),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Row(
              children: [
                // Index number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: widget.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.name,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: kTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: kTextSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: kTextMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodInfo {
  final String name;
  final String description;
  final NumericalMethod method;

  const _MethodInfo(this.name, this.description, this.method);
}
