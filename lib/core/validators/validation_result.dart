/// Result of input validation — used before any computation.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(String message)
      : isValid = false,
        errorMessage = message;

  @override
  String toString() =>
      isValid ? 'ValidationResult(valid)' : 'ValidationResult($errorMessage)';
}
