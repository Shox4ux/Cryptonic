String complexCalculation(
    num receivedAmount, num receivedCurrency, num requestedAmount) {
  final productResult = receivedAmount * receivedCurrency * requestedAmount;
  final result = productResult.toStringAsFixed(2);
  return result;
}

String calculation(num receivedAmount, num requestedAmount) {
  final productResult = receivedAmount * requestedAmount;
  final result = productResult.toStringAsFixed(2);
  return result;
}
