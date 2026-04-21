import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/precision_settings.dart';

/// Global precision settings provider.
///
/// Used by all solver screens to control rounding/chopping behaviour.
final precisionProvider =
    StateNotifierProvider<PrecisionNotifier, PrecisionSettings>(
  (ref) => PrecisionNotifier(),
);

class PrecisionNotifier extends StateNotifier<PrecisionSettings> {
  PrecisionNotifier() : super(const PrecisionSettings());

  void setMode(PrecisionMode mode) {
    state = state.copyWith(mode: mode);
  }

  void setDigits(int digits) {
    if (digits >= 1 && digits <= 10) {
      state = state.copyWith(digits: digits);
    }
  }

  void reset() {
    state = const PrecisionSettings();
  }
}
