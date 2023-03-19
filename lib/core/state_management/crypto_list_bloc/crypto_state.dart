part of 'crypto_bloc.dart';

@immutable
abstract class CryptoState {}

class CryptoInitial extends CryptoState {}

class OnCryptoSuccess extends CryptoState {
  final List<CryptoListModel> cryptoList;
  final List<CryptoModel> selectedCryptos;
  final bool isReadyToWatch;

  OnCryptoSuccess({
    required this.cryptoList,
    required this.selectedCryptos,
    required this.isReadyToWatch,
  });

  OnCryptoSuccess copyWithGeneralUpdates(
      {required List<CryptoListModel> updatedCryptoList,
      required bool updatedToWatch,
      required List<CryptoModel> updatedSelectedCryptos}) {
    return OnCryptoSuccess(
      cryptoList: updatedCryptoList,
      selectedCryptos: updatedSelectedCryptos,
      isReadyToWatch: updatedToWatch,
    );
  }

  OnCryptoSuccess copyWithChangedSelectedTokens(
      {required List<CryptoModel> changedSelectedCryptos}) {
    return OnCryptoSuccess(
      cryptoList: cryptoList,
      selectedCryptos: changedSelectedCryptos,
      isReadyToWatch: isReadyToWatch,
    );
  }
}

class OnCryptoProgress extends CryptoState {}

class OnCryptoError extends CryptoState {
  final String message;

  OnCryptoError({required this.message});
}
