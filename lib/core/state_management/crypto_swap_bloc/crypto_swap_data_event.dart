part of 'crypto_swap_data_bloc.dart';

@immutable
abstract class CryptoSwapDataEvent {}

class OnStartSwap extends CryptoSwapDataEvent {
  final num givenAmount;
  final String fromSymUpperCase;
  final String toSymUpperCase;
  final String toFiatUpperCase;

  OnStartSwap({
    required this.givenAmount,
    required this.fromSymUpperCase,
    required this.toSymUpperCase,
    required this.toFiatUpperCase,
  });
}

class OnStopSwap extends CryptoSwapDataEvent {}
