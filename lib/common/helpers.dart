/// Parses the transaction amount.
/// 
/// This converts amount from minor units format to human friendly
/// string with decimals.
/// 
/// If [stripSign] is true, minus sign is removed from negative amounts.
String parseTransactionAmount(int amount, { bool stripSign = false }) {
  if (stripSign) amount = amount.abs();

  return (amount / 100).toStringAsFixed(2);
}
