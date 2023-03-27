import 'package:cryptonic/src/domain/models/request/grahp_data_request.dart';
import 'package:cryptonic/src/domain/models/response/crypto_line_graph_data.dart';
import 'package:cryptonic/src/domain/repositories/crypto_repository.dart';
import 'package:cryptonic/src/utils/functions/date_formatter.dart';
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
          final response = await _repo.getGraphData(
              request: GraphDataRequest(
            coinId: event.coinId,
            days: event.days,
            currency: event.currency,
            interval: event.interval,
          ));

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
