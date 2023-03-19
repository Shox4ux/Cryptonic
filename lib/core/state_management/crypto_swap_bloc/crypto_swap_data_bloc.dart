import 'package:cryptonic/core/repository/compare_crypto_repository.dart';
import 'package:cryptonic/core/state_management/helper/models/swap_model.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

part 'crypto_swap_data_event.dart';
part 'crypto_swap_data_state.dart';

class CryptoSwapDataBloc
    extends Bloc<CryptoSwapDataEvent, CryptoSwapDataState> {
  final _repo = CompareCryptoRepository();

  bool isFirstSwap = true;

  CryptoSwapDataBloc() : super(CryptoSwapDataInitial()) {
    on<OnStopSwap>((event, emit) {
      isFirstSwap = true;
      emit(CryptoSwapDataInitial());
    });

    on<OnStartSwap>(
      (event, emit) async {
        if (isFirstSwap) {
          emit(OnSwapProgress());
        }
        try {
          final response = await _repo.getCopmarison(
            fromSym: event.fromSymUpperCase,
            toFiat: event.toFiatUpperCase,
            toSym: event.toSymUpperCase,
          );

          print(response.data);

          Map<String, dynamic> fromSwapData =
              response.data[event.fromSymUpperCase];
          Map<String, dynamic> toSwapData = response.data[event.toSymUpperCase];

          fromNetworkToLocalData(event, fromSwapData, toSwapData);
        } on DioError {
          emit(OnSwapError(message: "Something went wrong"));
        }
      },
    );
  }

  void fromNetworkToLocalData(
    OnStartSwap event,
    Map<String, dynamic> fromSwapData,
    Map<String, dynamic> toSwapData,
  ) {
    List<SwapModel> swapList = [];

    final fromSymbol = SwapModel(
      cryptoCurrency: _calculation(
        fromSwapData[event.fromSymUpperCase],
        event.givenAmount,
      ),
      alCryptoCurrency: _calculation(
        fromSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
      fiatCurrency: _calculation(
        fromSwapData[event.toFiatUpperCase],
        event.givenAmount,
      ),
    );

    swapList.add(fromSymbol);
    //-------------------------------------

    final toSymbol = SwapModel(
      cryptoCurrency: _calculation(
        toSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
      alCryptoCurrency: _calculation(
        toSwapData[event.fromSymUpperCase],
        event.givenAmount,
      ),
      fiatCurrency: _complexCalculation(
        toSwapData[event.toFiatUpperCase],
        fromSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
    );

    swapList.add(toSymbol);

    if (isFirstSwap) {
      onFirstSwap(swapList);
      return;
    } else {
      onContinuousSwap(swapList);
    }
  }

  void onFirstSwap(List<SwapModel> swapModelList) {
    emit(OnSwapSuccess(swapModelList: swapModelList));
    isFirstSwap = false;
  }

  void onContinuousSwap(List<SwapModel> newSwapList) {
    if (state is OnSwapSuccess) {
      final oldState = state as OnSwapSuccess;
      final newState = oldState.setModifiedList(newSwapList);
      emit(newState);
    }
  }

  void reverseSwapList() {
    if (state is OnSwapSuccess) {
      final oldState = state as OnSwapSuccess;
      final reversedList = oldState.swapModelList.reversed.toList();
      final newState = oldState.setModifiedList(reversedList);

      emit(newState);
    }
  }

  String _complexCalculation(
      num receivedAmount, num receivedCurrency, num requestedAmount) {
    final productResult = receivedAmount * receivedCurrency * requestedAmount;
    final result = productResult.toStringAsFixed(2);
    return result;
  }

  String _calculation(num receivedAmount, num requestedAmount) {
    final productResult = receivedAmount * requestedAmount;
    final result = productResult.toStringAsFixed(2);
    return result;
  }
}
