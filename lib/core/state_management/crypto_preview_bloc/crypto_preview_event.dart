part of 'crypto_preview_bloc.dart';

@immutable
abstract class CryptoPreviewEvent {}

class OnPreview extends CryptoPreviewEvent {
  final String coinId;
  final String currencyCode;
  final String interval;
  final String days;
  final CryptoModel model;

  OnPreview({
    required this.coinId,
    required this.currencyCode,
    required this.interval,
    required this.days,
    required this.model,
  });
}
