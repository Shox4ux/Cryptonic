// To parse this JSON data, do
//
//     final cryptoLineGraphData = cryptoLineGraphDataFromJson(jsonString);

import 'dart:convert';

class CryptoLineGraphData {
  CryptoLineGraphData({
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
  });

  List<List<double>> prices;
  List<List<double>> marketCaps;
  List<List<double>> totalVolumes;

  factory CryptoLineGraphData.fromRawJson(String str) =>
      CryptoLineGraphData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CryptoLineGraphData.fromJson(Map<String, dynamic> json) =>
      CryptoLineGraphData(
        prices: List<List<double>>.from(json["prices"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
        marketCaps: List<List<double>>.from(json["market_caps"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
        totalVolumes: List<List<double>>.from(json["total_volumes"]
            .map((x) => List<double>.from(x.map((x) => x?.toDouble())))),
      );

  Map<String, dynamic> toJson() => {
        "prices": List<dynamic>.from(
            prices.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "market_caps": List<dynamic>.from(
            marketCaps.map((x) => List<dynamic>.from(x.map((x) => x)))),
        "total_volumes": List<dynamic>.from(
            totalVolumes.map((x) => List<dynamic>.from(x.map((x) => x)))),
      };
}
