part of 'crypto_bloc.dart';

@immutable
abstract class CryptoEvent {}

class OnFetch extends CryptoEvent {
  final String currencyCode;
  OnFetch({required this.currencyCode});
}

class OnSearchCryptoList extends CryptoEvent {
  final String query;
  OnSearchCryptoList({required this.query});
}

class OnChangeSelectedCrypto extends CryptoEvent {
  final CryptoModel cryptoToUpdate;
  final CryptoModel selectedCrypto;
  final List<CryptoListModel> currentList;
  OnChangeSelectedCrypto({
    required this.selectedCrypto,
    required this.cryptoToUpdate,
    required this.currentList,
  });
}
