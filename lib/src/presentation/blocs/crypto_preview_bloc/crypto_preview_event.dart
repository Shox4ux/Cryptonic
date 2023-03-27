part of 'crypto_preview_bloc.dart';

@immutable
abstract class CryptoPreviewEvent {}

class OnPreview extends CryptoPreviewEvent {
  final String coinId;
  final String currency;
  final String interval;
  final String days;

  OnPreview({
    required this.coinId,
    required this.currency,
    required this.interval,
    required this.days,
  });
}
