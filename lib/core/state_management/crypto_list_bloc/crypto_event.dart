part of 'crypto_bloc.dart';

@immutable
abstract class CryptoEvent {}

class OnFetch extends CryptoEvent {
  final String currencyCode;
  OnFetch({required this.currencyCode});
}

class OnChangeSelectedCrypto extends CryptoEvent {
  final CryptoModel cryptoToUpdate;
  final CryptoModel selectedCrypto;
  OnChangeSelectedCrypto({
    required this.selectedCrypto,
    required this.cryptoToUpdate,
  });
}
