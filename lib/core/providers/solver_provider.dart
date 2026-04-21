import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/method_input.dart';
import '../../models/method_result.dart';
import '../../methods/root_finding/bisection.dart' as root;
import '../../methods/root_finding/false_position.dart' as root;
import '../../methods/root_finding/newton_raphson.dart' as root;
import '../../methods/root_finding/secant.dart' as root;
import '../../methods/linear_systems/doolittle.dart' as linear;
import '../../methods/linear_systems/thomas.dart' as linear;
import '../../methods/iterative/jacobi.dart' as iterative;
import '../../methods/iterative/gauss_seidel.dart' as iterative;
import '../../methods/interpolation/newton_forward.dart' as interp;
import '../../methods/interpolation/newton_backward.dart' as interp;
import '../../methods/interpolation/stirling.dart' as interp;
import '../../methods/interpolation/lagrange.dart' as interp;

/// All supported numerical methods.
enum NumericalMethod {
  bisection,
  falsePosition,
  newtonRaphson,
  secant,
  doolittleLU,
  thomasAlgorithm,
  jacobi,
  gaussSeidel,
  newtonForward,
  newtonBackward,
  stirling,
  lagrange,
}

/// Solver state — used by the UI to display results and loading.
class SolverState {
  final MethodInput? input;
  final MethodResult? result;
  final bool isLoading;
  final String? validationError;

  const SolverState({
    this.input,
    this.result,
    this.isLoading = false,
    this.validationError,
  });

  SolverState copyWith({
    MethodInput? input,
    MethodResult? result,
    bool? isLoading,
    String? validationError,
    bool clearResult = false,
    bool clearError = false,
  }) {
    return SolverState(
      input: input ?? this.input,
      result: clearResult ? null : (result ?? this.result),
      isLoading: isLoading ?? this.isLoading,
      validationError:
          clearError ? null : (validationError ?? this.validationError),
    );
  }
}

/// Solver state notifier — orchestrates validation, computation, and result.
class SolverNotifier extends StateNotifier<SolverState> {
  SolverNotifier() : super(const SolverState());

  /// Runs the selected method with the given input.
  ///
  /// Computation runs in an isolate via [compute()] to keep the UI responsive.
  Future<void> solve(NumericalMethod method, MethodInput input) async {
    state = state.copyWith(
      input: input,
      isLoading: true,
      clearResult: true,
      clearError: true,
    );

    try {
      final result = await compute(
        _runMethod,
        _SolverPayload(method: method, input: input),
      );
      state = state.copyWith(result: result, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        result: MethodResult.error('Computation error: $e'),
        isLoading: false,
      );
    }
  }

  void setValidationError(String error) {
    state = state.copyWith(validationError: error, clearResult: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void reset() {
    state = const SolverState();
  }
}

/// Payload sent to the isolate.
class _SolverPayload {
  final NumericalMethod method;
  final MethodInput input;

  const _SolverPayload({required this.method, required this.input});
}

/// Runs the correct method in an isolate.
///
/// This is a top-level function because [compute] requires it.
MethodResult _runMethod(_SolverPayload payload) {
  final input = payload.input;
  final p = input.precision;

  switch (payload.method) {
    case NumericalMethod.bisection:
      return root.bisection(
        expression: input.expression!,
        a: input.initialValues![0],
        b: input.initialValues![1],
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.falsePosition:
      return root.falsePosition(
        expression: input.expression!,
        a: input.initialValues![0],
        b: input.initialValues![1],
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.newtonRaphson:
      return root.newtonRaphson(
        expression: input.expression!,
        x0: input.initialValues![0],
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.secant:
      return root.secant(
        expression: input.expression!,
        x0: input.initialValues![0],
        x1: input.initialValues![1],
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.doolittleLU:
      return linear.doolittle(
        matrix: input.matrix!,
        vectorB: input.vectorB!,
        precision: p,
      );

    case NumericalMethod.thomasAlgorithm:
      return linear.thomas(
        matrix: input.matrix!,
        vectorB: input.vectorB!,
        precision: p,
      );

    case NumericalMethod.jacobi:
      return iterative.jacobi(
        matrix: input.matrix!,
        vectorB: input.vectorB!,
        initialVector: input.initialVector!,
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.gaussSeidel:
      return iterative.gaussSeidel(
        matrix: input.matrix!,
        vectorB: input.vectorB!,
        initialVector: input.initialVector!,
        tolerance: input.tolerance!,
        maxIterations: input.maxIterations!,
        precision: p,
      );

    case NumericalMethod.newtonForward:
      return interp.newtonForward(
        dataPoints: input.dataPoints!,
        targetX: input.targetX!,
        precision: p,
      );

    case NumericalMethod.newtonBackward:
      return interp.newtonBackward(
        dataPoints: input.dataPoints!,
        targetX: input.targetX!,
        precision: p,
      );

    case NumericalMethod.stirling:
      return interp.stirling(
        dataPoints: input.dataPoints!,
        targetX: input.targetX!,
        precision: p,
      );

    case NumericalMethod.lagrange:
      return interp.lagrange(
        dataPoints: input.dataPoints!,
        targetX: input.targetX!,
        precision: p,
      );
  }
}

/// Provider for the solver state.
final solverProvider =
    StateNotifierProvider<SolverNotifier, SolverState>(
  (ref) => SolverNotifier(),
);
