import 'package:cryptonic/core/domain/crypto_model.dart';

class CryptoListModel {
  final bool isSelected;
  final CryptoModel model;

  CryptoListModel({
    required this.isSelected,
    required this.model,
  });
}
