/// Parses the transaction amount.
/// 
/// This converts amount from minor units format to human friendly
/// string with decimals.
/// 
/// If [stripSign] is true, minus sign is removed from negative amounts.
/// 
/// If [explicitSign] is true, positive sign is included in positive amounts.
/// 
/// Both sign controlling parameters are mutually exclusive.
String parseTransactionAmount(int amount, { bool stripSign = false, bool explicitSign = false }) {
  if (explicitSign && stripSign) {
    throw ArgumentError("explicitSign and stripSign are exclusive parameters");
  }

  if (stripSign) amount = amount.abs();

  var result = (amount / 100).toStringAsFixed(2);

  if (explicitSign && amount > 0) result = "+$result";

  return result;
}

/// Parses the raw text amount converting it to minor units format integer.
/// 
/// This returns null if the amount is not convertible.
int? parseRawAmount(String? raw, int sign) {
  if (raw == null || raw.isEmpty) return null;

  final parts = raw.split('.');

  final whole = int.parse(parts[0]);
  final frac = parts.length == 1 ? 0 : int.parse(parts[1].padRight(2, '0'));

  final calcAmount = (whole * 100 + frac);

  return sign * calcAmount;
}
