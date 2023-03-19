class ApiUrls {
  static const geckoBaseUrl = "https://api.coingecko.com/api/v3/";

  static const cryptoCompareBaseUrl = "https://min-api.cryptocompare.com/";

  static const coinMarketUrl = "coins/markets";
  static const copmareCryptos = "data/pricemulti";

  static String coinGraphDataUrl({required String coinId}) {
    return "coins/$coinId/market_chart";
  }
}
