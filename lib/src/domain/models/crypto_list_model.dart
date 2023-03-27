import 'package:cryptonic/src/domain/models/response/crypto_model.dart';

class CryptoListModel {
  final bool isSelected;
  final CryptoModel model;

  CryptoListModel({
    required this.isSelected,
    required this.model,
  });
}
