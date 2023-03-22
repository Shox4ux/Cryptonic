part of 'crypto_selected_bloc.dart';

@immutable
abstract class CryptoSelectedEvent {}

class OnSubmitSelectedCryptosList extends CryptoSelectedEvent {
  final List<CryptoModel> submittedList;
  OnSubmitSelectedCryptosList({required this.submittedList});
}

class OnCryptosListReversed extends CryptoSelectedEvent {}

class OnCryptosListChanged extends CryptoSelectedEvent {
  final CryptoModel unselectedCrypto;
  final CryptoModel selectedCrypto;

  OnCryptosListChanged({
    required this.unselectedCrypto,
    required this.selectedCrypto,
  });
}
