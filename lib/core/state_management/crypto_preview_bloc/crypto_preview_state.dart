part of 'crypto_preview_bloc.dart';

@immutable
abstract class CryptoPreviewState {}

class CryptoPreviewInitial extends CryptoPreviewState {}

class OnCryptoPreviewProgress extends CryptoPreviewState {}

class OnCryptoPreviewSuccess extends CryptoPreviewState {
  final List<FlSpot> spots;
  final List<String> dates;

  OnCryptoPreviewSuccess({
    required this.spots,
    required this.dates,
  });
}

class OnCryptoPreviewError extends CryptoPreviewState {
  final String message;

  OnCryptoPreviewError({required this.message});
}
