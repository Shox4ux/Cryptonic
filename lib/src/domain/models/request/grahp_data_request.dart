class GraphDataRequest {
  final String coinId;
  final String days;
  final String currency;
  final String interval;

  GraphDataRequest({
    required this.coinId,
    required this.days,
    required this.currency,
    required this.interval,
  });
}
