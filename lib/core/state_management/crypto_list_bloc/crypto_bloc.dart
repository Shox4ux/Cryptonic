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
  List<CryptoListModel> searchCryptoList = [];

  CryptoBloc() : super(CryptoInitial()) {
    on<OnFetch>((event, emit) => _onFetch(event, emit));
    on<OnChangeSelectedCrypto>(
        (event, emit) => _onChangeSelectedCrypto(event, emit));

    on<OnSearchCryptoList>((event, emit) => searchCrypto(event.query, emit));
  }

  void searchCrypto(String query, Emitter<CryptoState> emit) {
    searchCryptoList.clear();
    if (state is OnCryptoSuccess) {
      final oldState = state as OnCryptoSuccess;
      if (query.isNotEmpty) {
        cryptoList.forEach((element) {
          if (element.model.name!.toLowerCase().contains(query.toLowerCase())) {
            searchCryptoList.add(element);
          }
        });

        final newState = oldState.copyWithSearchedList(
          searchedList: searchCryptoList,
        );
        emit(newState);
      }
      if (query.isEmpty) {
        searchCryptoList.clear();
        final newState = oldState.copyWithGeneralUpdates(
          updatedCryptoList: cryptoList,
          updatedToWatch: isReadyToWatch,
          updatedSelectedCryptos: selectedCryptos,
        );
        emit(newState);
      }
    }
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
        updatedCryptoList: searchCryptoList,
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

  selectCryptoToPreview(CryptoListModel listModel) async {
    if (selectedCryptos.length == 2) {
      int? indexToRemove;
      for (int i = 0; selectedCryptos.length > i; i++) {
        if (selectedCryptos[i].id == listModel.model.id) {
          indexToRemove = i;
        }
      }

      if (indexToRemove != null) {
        selectedCryptos.removeAt(indexToRemove);
        if (selectedCryptos.length < 2) {
          isReadyToWatch = false;
        }
        _updateCryptoList(listModel, false);
        return;
      } else {
        return;
      }
    }

    //----------------------------------
    if (selectedCryptos.isEmpty) {
      selectedCryptos.add(listModel.model);
      _updateCryptoList(listModel, true);
      return;
    }
    //--------------------------------------------
    if (selectedCryptos.isNotEmpty) {
      int? indexToRemove;
      int? indexToAdd;
      for (int i = 0; selectedCryptos.length > i; i++) {
        if (selectedCryptos[i].id == listModel.model.id) {
          indexToRemove = i;
        }
        if (selectedCryptos[i].id != listModel.model.id) {
          indexToAdd = i;
        }
      }
      if (indexToRemove != null) {
        selectedCryptos.removeAt(indexToRemove);
        if (selectedCryptos.length < 2) {
          isReadyToWatch = false;
        }
        _updateCryptoList(listModel, false);
        return;
      }
      if (indexToAdd != null) {
        selectedCryptos.add(listModel.model);
        if (selectedCryptos.length == 2) {
          isReadyToWatch = true;
        }
        _updateCryptoList(listModel, true);
        return;
      }
    }
  }

  void _updateCryptoList(CryptoListModel listModel, bool isSelected) {
    final replaceWith =
        CryptoListModel(isSelected: isSelected, model: listModel.model);
    cryptoList.contains(listModel)
        ? cryptoList[cryptoList.indexWhere((v) => v == listModel)] = replaceWith
        : cryptoList;
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
