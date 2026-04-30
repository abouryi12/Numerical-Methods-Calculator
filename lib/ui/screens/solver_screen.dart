import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/providers/solver_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/responsive_container.dart';
import '../widgets/result_card.dart';
import '../widgets/iteration_table.dart';
import 'solver_bodies/solver_body_root_finding.dart';
import 'solver_bodies/solver_body_matrix.dart';
import 'solver_bodies/solver_body_interpolation.dart';

class SolverScreen extends ConsumerStatefulWidget {
  final NumericalMethod method;
  final String methodName;
  final String category;

  const SolverScreen({
    super.key,
    required this.method,
    required this.methodName,
    required this.category,
  });

  @override
  ConsumerState<SolverScreen> createState() => _SolverScreenState();
}

class _SolverScreenState extends ConsumerState<SolverScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(solverProvider.notifier).reset();
    });

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solverProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 900;

    return Scaffold(
      backgroundColor: kBgBase,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──
          SliverToBoxAdapter(
            child: ResponsiveContainer(
              maxWidth: isWide ? 1200 : 720,
              child: _buildHeader(context),
            ),
          ),

          // ── Content: side-by-side on wide, stacked on mobile ──
          if (isWide)
            SliverToBoxAdapter(
              child: ResponsiveContainer(
                maxWidth: 1200,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input panel
                    Expanded(
                      flex: 5,
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF111116),
                            border: Border.all(
                                color: const Color(0xFF2A61C2)
                                    .withValues(alpha: 0.3),
                                width: 0.4),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: _buildInputs(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Results panel
                    Expanded(
                      flex: 5,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.1),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: state.result != null
                            ? Container(
                                key: ValueKey(state.result.hashCode),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111116),
                                  border: Border.all(
                                      color: const Color(0xFF2A61C2)
                                          .withValues(alpha: 0.3),
                                      width: 0.4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    ResultCard(result: state.result!),
                                    IterationTable(
                                        steps: state.result!.steps),
                                  ],
                                ),
                              )
                            : Container(
                                key: const ValueKey('empty_results'),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 80, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111116),
                                  border: Border.all(
                                      color: const Color(0xFF2A61C2)
                                          .withValues(alpha: 0.15),
                                      width: 0.4),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.calculate_outlined,
                                        size: 48,
                                        color: kTextMuted.withValues(alpha: 0.5)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Results will appear here',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: kTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // ── Mobile: stacked layout ──
            // Input Section
            SliverToBoxAdapter(
              child: ResponsiveContainer(
                maxWidth: 720,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111116),
                        border: Border.all(
                            color: const Color(0xFF2A61C2)
                                .withValues(alpha: 0.3),
                            width: 0.4),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: _buildInputs(),
                    ),
                  ),
                ),
              ),
            ),

            // Results Section
            SliverToBoxAdapter(
              child: ResponsiveContainer(
                maxWidth: 720,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    final slideAnim = Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ));
                    final scaleAnim = Tween<double>(
                      begin: 0.95,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ));
                    return SlideTransition(
                      position: slideAnim,
                      child: ScaleTransition(
                        scale: scaleAnim,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      ),
                    );
                  },
                  child: state.result != null
                      ? Padding(
                          key: ValueKey(state.result.hashCode),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                          child: _buildResults(state),
                        )
                      : const SizedBox.shrink(key: ValueKey('empty')),
                ),
              ),
            ),
          ],

          // Bottom spacing
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      child: Column(
        children: [
          // Back button row
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
              const SizedBox(width: 14),
              // Method name
              Expanded(
                child: Text(
                  widget.methodName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: kTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputs() {
    switch (widget.category) {
      case 'Root Finding':
        return SolverBodyRootFinding(method: widget.method);
      case 'Linear Systems':
      case 'Iterative':
        return SolverBodyMatrix(method: widget.method, category: widget.category);
      case 'Interpolation':
        return SolverBodyInterpolation(method: widget.method);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResults(SolverState state) {
    if (state.result == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        border: Border.all(color: const Color(0xFF2A61C2).withValues(alpha: 0.3), width: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ResultCard(result: state.result!),
          IterationTable(steps: state.result!.steps),
        ],
      ),
    );
  }
}
