import 'dart:async';

import 'package:cryptonic/src/domain/models/request/compare_request.dart';
import 'package:cryptonic/src/domain/models/swap_model.dart';
import 'package:cryptonic/src/domain/repositories/compare_crypto_repository.dart';
import 'package:cryptonic/src/utils/functions/calculation.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

part 'crypto_swap_data_event.dart';
part 'crypto_swap_data_state.dart';

class CryptoSwapDataBloc
    extends Bloc<CryptoSwapDataEvent, CryptoSwapDataState> {
  final _repo = CompareCryptoRepository();

  bool _isBusy = false;
  bool _isFirstSwap = true;
  bool _isTimerDisActivated = false;
  Timer? swapTimer;

  CryptoSwapDataBloc() : super(CryptoSwapDataInitial()) {
    on<OnStopSwap>((event, emit) => _onStopSwap(emit));
    on<OnReverseSwap>((event, emit) => _reverseSwapList());

    on<OnStartSwap>((event, emit) async => await _onStartSwapping(event, emit));
  }

  Future<void> _onStartSwapping(
      OnStartSwap event, Emitter<CryptoSwapDataState> emit) async {
    if (_isBusy) return;
    try {
      if (_isFirstSwap && event.givenAmount != 0) {
        _isTimerDisActivated = false;
        _isBusy = true;
        _sendSimpleSwapRequest(event, emit);
        _startSwapRequestWithTimer(event, emit);
        _isBusy = false;
      }

      if (event.givenAmount == 0) {
        _onStopSwap(emit);
      }
    } on DioError {
      emit(OnSwapError(message: "Something went wrong"));
    }
  }

  void _fromNetworkToLocalData(
    OnStartSwap event,
    Map<String, dynamic> fromSwapData,
    Map<String, dynamic> toSwapData,
  ) {
    List<SwapModel> swapList = [];

    final fromSymbol = SwapModel(
      cryptoCurrency: calculation(
        fromSwapData[event.fromSymUpperCase],
        event.givenAmount,
      ),
      alCryptoCurrency: calculation(
        fromSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
      fiatCurrency: calculation(
        fromSwapData[event.toFiatUpperCase],
        event.givenAmount,
      ),
    );

    swapList.add(fromSymbol);
    //-------------------------------------

    final toSymbol = SwapModel(
      cryptoCurrency: calculation(
        toSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
      alCryptoCurrency: calculation(
        toSwapData[event.fromSymUpperCase],
        event.givenAmount,
      ),
      fiatCurrency: complexCalculation(
        toSwapData[event.toFiatUpperCase],
        fromSwapData[event.toSymUpperCase],
        event.givenAmount,
      ),
    );

    swapList.add(toSymbol);

    if (_isFirstSwap) {
      _onFirstSwap(swapList);
      return;
    } else {
      _onContinuousSwap(swapList);
    }
  }

  void _onFirstSwap(List<SwapModel> swapModelList) {
    emit(OnSwapSuccess(swapModelList: swapModelList));
    _isFirstSwap = false;
  }

  void _onContinuousSwap(List<SwapModel> newSwapList) {
    if (state is OnSwapSuccess) {
      final oldState = state as OnSwapSuccess;
      final newState = oldState.setModifiedList(newSwapList);
      emit(newState);
    }
  }

  void _reverseSwapList() {
    if (state is OnSwapSuccess) {
      final oldState = state as OnSwapSuccess;
      final reversedList = oldState.swapModelList.reversed.toList();
      final newState = oldState.setModifiedList(reversedList);

      emit(newState);
    }
  }

  _onStopSwap(Emitter<CryptoSwapDataState> emit) {
    _isFirstSwap = true;
    _isTimerDisActivated = true;
    _isBusy = false;
    if (swapTimer != null && swapTimer!.isActive) {
      swapTimer!.cancel();
    }
    emit(CryptoSwapDataInitial());
  }

  Future<void> _startSwapRequestWithTimer(
      OnStartSwap event, Emitter<CryptoSwapDataState> emit) async {
    swapTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_isTimerDisActivated) {
        timer.cancel();
        return;
      }
      print("timer is running");
      _sendSimpleSwapRequest(event, emit);
    });
  }

  Future<void> _sendSimpleSwapRequest(
      OnStartSwap event, Emitter<CryptoSwapDataState> emit) async {
    final response = await _repo.getComparison(
      request: CompareRequest(
        fromSymbol: event.fromSymUpperCase,
        toSymbol: event.toFiatUpperCase,
        toFiat: event.toSymUpperCase,
      ),
    );

    Map<String, dynamic> fromSwapData = response.data[event.fromSymUpperCase];
    Map<String, dynamic> toSwapData = response.data[event.toSymUpperCase];

    _fromNetworkToLocalData(event, fromSwapData, toSwapData);
  }
}
