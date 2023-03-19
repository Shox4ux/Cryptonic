part of 'crypto_swap_data_bloc.dart';

@immutable
abstract class CryptoSwapDataState {}

class CryptoSwapDataInitial extends CryptoSwapDataState {}

class OnSwapProgress extends CryptoSwapDataState {}

class OnSwapSuccess extends CryptoSwapDataState {
  final List<SwapModel> swapModelList;

  OnSwapSuccess({required this.swapModelList});

  OnSwapSuccess setModifiedList(List<SwapModel> reversedList) {
    return OnSwapSuccess(swapModelList: reversedList);
  }
}

class OnSwapError extends CryptoSwapDataState {
  final String message;

  OnSwapError({required this.message});
}
