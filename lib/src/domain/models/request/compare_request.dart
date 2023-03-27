class CompareRequest {
  final String fromSymbol;
  final String toSymbol;
  final String toFiat;

  CompareRequest({
    required this.fromSymbol,
    required this.toSymbol,
    required this.toFiat,
  });
}
