part of 'crypto_selected_bloc.dart';

@immutable
abstract class CryptoSelectedState {}

class CryptoSelectedInitial extends CryptoSelectedState {}

class OnReceivedSelectedList extends CryptoSelectedState {
  final List<CryptoModel> receivedList;
  OnReceivedSelectedList({
    required this.receivedList,
  });

  OnReceivedSelectedList copyWithChangedCryptoList(
      List<CryptoModel> changedList) {
    return OnReceivedSelectedList(
      receivedList: changedList,
    );
  }
}
