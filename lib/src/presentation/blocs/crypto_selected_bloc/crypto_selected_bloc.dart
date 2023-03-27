import 'package:bloc/bloc.dart';
import 'package:cryptonic/src/domain/models/response/crypto_model.dart';
import 'package:meta/meta.dart';
part 'crypto_selected_event.dart';
part 'crypto_selected_state.dart';

class CryptoSelectedBloc
    extends Bloc<CryptoSelectedEvent, CryptoSelectedState> {
  CryptoSelectedBloc() : super(CryptoSelectedInitial()) {
    on<OnSubmitSelectedCryptosList>((event, emit) {
      _onListSubmitted(event, emit);
    });

    on<OnCryptosListReversed>((event, emit) => _onListReversed(event, emit));
    on<OnCryptosListChanged>((event, emit) => _onListChanged(event, emit));
  }

  void _onListSubmitted(
      OnSubmitSelectedCryptosList event, Emitter<CryptoSelectedState> emit) {
    emit(OnReceivedSelectedList(receivedList: event.submittedList));
  }

  _onListReversed(
      OnCryptosListReversed event, Emitter<CryptoSelectedState> emit) {
    if (state is OnReceivedSelectedList) {
      final oldState = state as OnReceivedSelectedList;
      var reversedList = oldState.receivedList.reversed.toList();
      final newState = oldState.copyWithChangedCryptoList(reversedList);
      emit(newState);
    }
  }

  _onListChanged(
      OnCryptosListChanged event, Emitter<CryptoSelectedState> emit) {
    if (state is OnReceivedSelectedList) {
      final oldState = state as OnReceivedSelectedList;
      var listToUpdate = oldState.receivedList;
      listToUpdate.remove(event.unselectedCrypto);
      listToUpdate.add(event.selectedCrypto);
      final newState = oldState.copyWithChangedCryptoList(listToUpdate);
      emit(newState);
    }
  }
}
