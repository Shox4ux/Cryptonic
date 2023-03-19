import 'package:cryptonic/core/domain/crypto_line_graph_data.dart';
import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/core/repository/crypto_repository.dart';
import 'package:cryptonic/core/state_management/helper/functions/date_formatter.dart';
import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';

part 'crypto_preview_event.dart';
part 'crypto_preview_state.dart';

class CryptoPreviewBloc extends Bloc<CryptoPreviewEvent, CryptoPreviewState> {
  final _repo = CryptoRepository();

  CryptoPreviewBloc() : super(CryptoPreviewInitial()) {
    on<CryptoPreviewEvent>((event, emit) async {
      if (event is OnPreview) {
        emit(OnCryptoPreviewProgress());

        try {
          final response = await _repo.getCoinGraphDataById(
            coinId: event.coinId,
            days: event.days,
            currency: event.currencyCode,
            interval: event.interval,
          );

          print(response.data);

          final data = CryptoLineGraphData.fromJson(response.data);

          List<FlSpot> spots = [];
          List<String> dates = [];
          double i = 0;
          for (var element in data.prices) {
            spots.add(FlSpot(
              i,
              element.last,
            ));
            i++;

            dates.add(dateFormatter(element.first));
          }
          print(dates);

          emit(OnCryptoPreviewSuccess(spots: spots, dates: dates));
        } on DioError {
          emit(OnCryptoPreviewError(message: "Something went wrong"));
        }
      }
    });
  }
}
