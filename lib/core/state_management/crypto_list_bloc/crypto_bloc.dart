import 'dart:math';

import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/core/repository/crypto_repository.dart';
import 'package:cryptonic/core/state_management/helper/models/crypto_list_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

part 'crypto_event.dart';
part 'crypto_state.dart';

class CryptoBloc extends Bloc<CryptoEvent, CryptoState> {
  final _repo = CryptoRepository();

  List<CryptoModel> selectedCryptos = [];
  bool isReadyToWatch = false;
  List<CryptoListModel> cryptoList = [];

  CryptoBloc() : super(CryptoInitial()) {
    on<OnFetch>((event, emit) => _onFetch(event, emit));
    on<OnChangeSelectedCrypto>(
        (event, emit) => _onChangeSelectedCrypto(event, emit));
  }

  void _onChangeSelectedCrypto(
      OnChangeSelectedCrypto event, Emitter<CryptoState> emit) {
    for (var element in selectedCryptos) {
      if (element.id == event.cryptoToUpdate.id) {
        final indexToInsert = selectedCryptos.indexOf(element);
        selectedCryptos.remove(element);
        selectedCryptos.insert(indexToInsert, event.selectedCrypto);
      }
    }

    _updateCryptoListFromPreview(event, emit);
  }

  _updateCryptoListFromPreview(
      OnChangeSelectedCrypto event, Emitter<CryptoState> emit) {
    //---------------------updating old one
    _remarkCryptoToUpdate(event);
    //---------------------inserting new one
    _remarkSelectedCryptoToReplace(event);

    if (state is OnCryptoSuccess) {
      final oldState = state as OnCryptoSuccess;

      final newState = oldState.copyWithGeneralUpdates(
        updatedCryptoList: cryptoList,
        updatedToWatch: isReadyToWatch,
        updatedSelectedCryptos: selectedCryptos,
      );

      emit(newState);
    }
  }

  void _remarkCryptoToUpdate(OnChangeSelectedCrypto event) {
    for (var element in cryptoList) {
      if (element.model.id == event.cryptoToUpdate.id) {
        int index = cryptoList.indexOf(element);
        final updatedElement =
            CryptoListModel(isSelected: false, model: event.cryptoToUpdate);
        cryptoList.removeAt(index);

        cryptoList.insert(index, updatedElement);
        break;
      }
    }
  }

  void _remarkSelectedCryptoToReplace(OnChangeSelectedCrypto event) {
    for (var element in cryptoList) {
      //------------------------marking new one
      if (element.model.id == event.selectedCrypto.id) {
        int index = cryptoList.indexOf(element);
        final updatedElement =
            CryptoListModel(isSelected: true, model: event.selectedCrypto);
        cryptoList.removeAt(index);
        cryptoList.insert(index, updatedElement);
        break;
      }
    }
  }

  _onFetch(OnFetch event, Emitter<CryptoState> emit) async {
    emit(OnCryptoProgress());
    try {
      final response = await _repo.getCoinMarket(currency: event.currencyCode);
      final rowData = response.data as List;
      cryptoList = rowData
          .map(
            (e) => CryptoListModel(
              isSelected: false,
              model: CryptoModel.fromJson(e),
            ),
          )
          .toList();

      emit(OnCryptoSuccess(
        cryptoList: cryptoList,
        selectedCryptos: selectedCryptos,
        isReadyToWatch: isReadyToWatch,
      ));
    } on DioError catch (e) {
      emit(OnCryptoError(message: "Something went wrong"));
    }
  }

  selectCryptoToPreview(int selectedIndex) async {
    final selectedElement = cryptoList.elementAt(selectedIndex).model;

    if (selectedCryptos.length == 2) {
      int? indexToRemove;
      for (int i = 0; selectedCryptos.length > i; i++) {
        if (selectedCryptos[i].id == selectedElement.id) {
          indexToRemove = i;
        }
      }

      if (indexToRemove != null) {
        selectedCryptos.removeAt(indexToRemove);
        if (selectedCryptos.length < 2) {
          isReadyToWatch = false;
        }
        _updateCryptoList(selectedIndex, false);
        return;
      } else {
        return;
      }
    }
    if (selectedCryptos.isEmpty) {
      selectedCryptos.add(selectedElement);
      _updateCryptoList(selectedIndex, true);
      return;
    }
    if (selectedCryptos.isNotEmpty) {
      int? indexToRemove;
      int? indexToAdd;
      for (int i = 0; selectedCryptos.length > i; i++) {
        if (selectedCryptos[i].id == selectedElement.id) {
          indexToRemove = i;
        }
        if (selectedCryptos[i].id != selectedElement.id) {
          indexToAdd = i;
        }
      }
      if (indexToRemove != null) {
        selectedCryptos.removeAt(indexToRemove);
        if (selectedCryptos.length < 2) {
          isReadyToWatch = false;
        }
        _updateCryptoList(selectedIndex, false);
        return;
      }
      if (indexToAdd != null) {
        final cryptoToAdd = cryptoList.elementAt(selectedIndex);
        selectedCryptos.add(cryptoToAdd.model);
        if (selectedCryptos.length == 2) {
          isReadyToWatch = true;
        }
        _updateCryptoList(selectedIndex, true);
        return;
      }
    }
  }

  void _updateCryptoList(int selectedIndex, bool shouldInsert) {
    final selectedElement = cryptoList.elementAt(selectedIndex);

    final elementToUpdate =
        CryptoListModel(isSelected: shouldInsert, model: selectedElement.model);
    cryptoList.removeAt(selectedIndex);
    cryptoList.insert(selectedIndex, elementToUpdate);

    if (state is OnCryptoSuccess) {
      final oldState = state as OnCryptoSuccess;
      final newState = oldState.copyWithGeneralUpdates(
        updatedCryptoList: cryptoList,
        updatedToWatch: isReadyToWatch,
        updatedSelectedCryptos: selectedCryptos,
      );
      // ignore: invalid_use_of_visible_for_testing_member
      emit(newState);
    }
  }
}
