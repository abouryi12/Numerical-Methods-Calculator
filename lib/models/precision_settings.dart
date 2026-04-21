/// Determines how intermediate values are truncated.
enum PrecisionMode {
  rounding,
  chopping,
}

/// Immutable settings for precision control.
///
/// Every numerical method receives this and applies it
/// to every intermediate value via `applyPrecision`.
class PrecisionSettings {
  final PrecisionMode mode;
  final int digits;

  const PrecisionSettings({
    this.mode = PrecisionMode.rounding,
    this.digits = 6,
  }) : assert(digits >= 1 && digits <= 10);

  PrecisionSettings copyWith({
    PrecisionMode? mode,
    int? digits,
  }) {
    return PrecisionSettings(
      mode: mode ?? this.mode,
      digits: digits ?? this.digits,
    );
  }
}
