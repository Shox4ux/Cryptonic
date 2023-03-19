import 'dart:async';
import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/core/state_management/crypto_list_bloc/crypto_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_preview_bloc/crypto_preview_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_swap_bloc/crypto_swap_data_bloc.dart';
import 'package:cryptonic/ui/res/constants/app_colors.dart';
import 'package:cryptonic/ui/res/constants/app_text_styles.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_days_enum.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_type_enum.dart';
import 'package:cryptonic/ui/res/widgets/crypto_list_item_widget.dart';
import 'package:cryptonic/ui/res/widgets/custom_line_chart_widget.dart';
import 'package:cryptonic/ui/res/widgets/on_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviewScreen extends StatefulWidget {
  PreviewScreen({super.key, required this.model});
  List<CryptoModel> model;

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final List<String> vsCurrencyList = ["USD", "EUR", "RUB"];

  List<TextEditingController> controllerList = [
    TextEditingController(),
    TextEditingController(),
  ];
  String? _initialDropValue;
  bool _isReversed = false;
  Timer? mytimer;
  bool _shouldQuitRequest = false;
  bool _isTimerRunning = false;
  int _requestCount = 0;

  // @override
  // void dispose() {
  //   mytimer!.cancel();
  //   print("timer canceled");
  //   _stopSwapping();
  //   _disposeControllers();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // _clearControllers();
        // _stopTimer();
        // _stopSwapping();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.primaryBackground,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 25.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12.r,
                          child: Image.network(
                            widget.model.first.image ?? "",
                          ),
                        ),
                        SizedBox(width: 5.w),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          iconSize: 24.w,
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _reverseCryptoList();
                              _reverseControllerList();
                              _callPreviewData();
                              _startSwapping();
                              _reverseSwapList();
                              _isReversed = !_isReversed;
                            });
                          },
                          icon: const Icon(Icons.swap_horiz),
                        ),
                        SizedBox(width: 5.w),
                        CircleAvatar(
                          radius: 12.r,
                          child: Image.network(
                            widget.model.last.image ?? "",
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Track changes",
                      style: AppTextStyles.primaryTextStyle
                          .copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Container(
                      color: AppColors.secondaryText,
                      padding: EdgeInsets.all(8.w),
                      width: 100.w,
                      child: DropdownButton(
                        value: _initialDropValue ?? vsCurrencyList.first,
                        isExpanded: true,
                        isDense: true,
                        underline: const SizedBox.shrink(),
                        dropdownColor: Colors.blue,
                        items: vsCurrencyList
                            .map(
                              (value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value,
                                      style: AppTextStyles.primaryTextStyle
                                          .copyWith(
                                        fontSize: 18.sp,
                                        color: Colors.white,
                                      ))),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _initialDropValue = value;
                            _requestForPreview();
                            if (_isTimerRunning) {
                              _startSwapping();
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(height: 10.h),
                BlocBuilder<CryptoPreviewBloc, CryptoPreviewState>(
                  builder: (context, state) {
                    if (state is OnCryptoPreviewSuccess) {
                      return Flexible(
                        child: Container(
                          height: 300.h,
                          padding: EdgeInsets.only(
                            right: 10.w,
                            left: 10.w,
                            top: 12.w,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8.r)),
                          child: CustomLineChartWidget(
                            spots: state.spots,
                            isPositive: !widget.model.first
                                .priceChangePercentage24h!.isNegative,
                            maxY: widget.model.first.high24h?.toDouble() ?? 0,
                            minY: widget.model.first.low24h?.toDouble() ?? 0,
                            fiatCurrCode:
                                _initialDropValue ?? vsCurrencyList.first,
                            dates: state.dates,
                          ),
                        ),
                      );
                    }
                    if (state is OnCryptoPreviewError) {
                      return OnErrorWidget(
                        onPressed: () {
                          _callPreviewData();
                        },
                        message: state.message,
                      );
                    }
                    if (state is OnCryptoPreviewProgress) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Center(
                      child: Text(
                        "No data found",
                        style: AppTextStyles.primaryTextStyle,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                _currencyItem(
                  widget.model.first,
                  widget.model.last,
                  controllerList.first,
                  true,
                ),
                SizedBox(height: 20.h),
                _currencyItem(
                  widget.model.last,
                  widget.model.first,
                  controllerList.last,
                  false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTokenList(bool wasItPrimary, CryptoModel cryptoToRemove) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        titlePadding: EdgeInsets.all(5.w),
        contentPadding: EdgeInsets.all(5.w),
        backgroundColor: AppColors.primaryBackground,
        title: Center(
          child: Text(
            "Choose token",
            style: AppTextStyles.primaryTextStyle,
          ),
        ),
        content: BlocBuilder<CryptoBloc, CryptoState>(
          builder: (context, state) {
            if (state is OnCryptoSuccess) {
              return CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: state.cryptoList.length,
                      (context, index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (wasItPrimary) {
                              _requestForPreview(
                                calledFromDialog: true,
                                chosenModel: state.cryptoList[index].model,
                              );
                            }

                            context
                                .read<CryptoBloc>()
                                .selectCryptoToPreview(index);

                            context.read<CryptoBloc>().add(
                                  OnChangeSelectedCrypto(
                                    cryptoToUpdate: cryptoToRemove,
                                    selectedCrypto:
                                        state.cryptoList[index].model,
                                  ),
                                );

                            Navigator.pop(context);
                          });
                        },
                        child: CryptoListItemWidget(
                          cryptoModel: state.cryptoList[index],
                          isHomePage: false,
                        ),
                      ),
                    ),
                  )
                ],
              );
            }
            if (state is OnCryptoError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message,
                        style: const TextStyle(color: Colors.white)),
                    ElevatedButton(
                        onPressed: () {
                          context.read<CryptoBloc>().add(OnFetch(
                                currencyCode:
                                    _initialDropValue ?? vsCurrencyList.first,
                              ));
                        },
                        child: const Text("Retry"))
                  ],
                ),
              );
            }
            if (state is OnCryptoProgress) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return const Center(child: Text("There is no data yet"));
          },
        ),
      ),
    );
  }

  Widget _currencyItem(
    CryptoModel current,
    CryptoModel alternative,
    TextEditingController controller,
    bool isPrimary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              child: Image.network(current.image ?? ""),
            ),
            SizedBox(width: 10.w),
            Text(
              current.symbol?.toUpperCase() ?? "",
              style: AppTextStyles.primaryTextStyle.copyWith(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(width: 10.w),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                _showTokenList(isPrimary, current);

                setState(() {
                  _isTimerRunning = false;
                  _shouldQuitRequest = true;
                  _stopSwapping();
                  _clearControllers();
                });
              },
              icon: const Icon(
                Icons.arrow_downward,
                color: Colors.white,
              ),
            )
          ],
        ),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(10.w),
          width: double.maxFinite,
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: BlocBuilder<CryptoSwapDataBloc, CryptoSwapDataState>(
            builder: (context, state) {
              if (state is OnSwapSuccess) {
                final swapList = state.swapModelList;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  controllerList.last.text = swapList.first.alCryptoCurrency;
                });
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: TextField(
                        readOnly: !isPrimary,
                        enableInteractiveSelection: false,
                        controller: controller,
                        textAlign: TextAlign.right,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _requestCount = _requestCount + 1;
                          _swapCryptos(controller.text);
                        },
                        decoration: const InputDecoration.collapsed(
                          hintText: "0.0",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        style: AppTextStyles.primaryTextStyle.copyWith(
                          fontSize: 20.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "${_initialDropValue ?? vsCurrencyList.first}:",
                          style: AppTextStyles.secondaryTextStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          isPrimary
                              ? swapList.first.fiatCurrency
                              : swapList.last.fiatCurrency,
                          style: AppTextStyles.secondaryTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 18.sp,
                          ),
                        ),
                      ],
                    )
                  ],
                );
              }
              if (state is OnSwapError) {
                return Center(
                  child: isPrimary
                      ? OnErrorWidget(
                          onPressed: () {
                            _swapCryptos(controller.text);
                          },
                          message: state.message,
                        )
                      : Text(state.message,
                          style: const TextStyle(color: Colors.white)),
                );
              }
              if (state is CryptoSwapDataInitial) {
                return _onInitialState(controller);
              }
              return _onInitialState(controller);
            },
          ),
        )
      ],
    );
  }

  SizedBox _onInitialState(TextEditingController controller) {
    return SizedBox(
      height: 60.h,
      width: double.maxFinite,
      child: TextField(
        enableInteractiveSelection: false,
        controller: controller,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _swapCryptos(controller.text);
        },
        decoration: const InputDecoration.collapsed(
          hintText: "0.0",
          hintStyle: TextStyle(
            color: Colors.grey,
          ),
        ),
        style: AppTextStyles.primaryTextStyle.copyWith(
          fontSize: 20.sp,
          color: Colors.white,
        ),
      ),
    );
  }

  void _swapCryptos(String? givenAmount) {
    if (givenAmount == "0" || givenAmount == "" || givenAmount!.isEmpty) {
      setState(() {
        _shouldQuitRequest = true;
        _isTimerRunning = false;
      });
      _stopSwapping();
      _clearControllers();
      return;
    }
    _shouldQuitRequest = false;
    _isTimerRunning = true;
    if (_isTimerRunning) {
      if (_requestCount > 1) {
        return;
      }
      _startSwapping();
      _startTimer();
    }
  }

  void _requestForPreview({bool? calledFromDialog, CryptoModel? chosenModel}) {
    if (calledFromDialog != null && calledFromDialog == true) {
      context.read<CryptoPreviewBloc>().add(
            OnPreview(
              coinId: chosenModel!.id!,
              currencyCode: _initialDropValue ?? vsCurrencyList.first,
              interval: PreviewIntervalType.hourly.interval,
              days: PreviewIntervalDays.day.interval,
              model: chosenModel,
            ),
          );
      return;
    }
    context.read<CryptoPreviewBloc>().add(
          OnPreview(
            coinId: widget.model.first.id!,
            currencyCode: _initialDropValue ?? vsCurrencyList.first,
            interval: PreviewIntervalType.hourly.interval,
            days: PreviewIntervalDays.day.interval,
            model: widget.model.first,
          ),
        );
  }

  void _callPreviewData() {
    context.read<CryptoPreviewBloc>().add(
          OnPreview(
            coinId: widget.model.first.id!,
            currencyCode: _initialDropValue ?? vsCurrencyList.first,
            interval: PreviewIntervalType.hourly.interval,
            days: PreviewIntervalDays.day.interval,
            model: widget.model.first,
          ),
        );
  }

  void _reverseSwapList() {
    context.read<CryptoSwapDataBloc>().reverseSwapList();
  }

  void _stopTimer() {
    mytimer!.cancel();
  }

  void _startTimer() {
    mytimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_shouldQuitRequest) {
        timer.cancel();
        print("timer is canselled");

        return;
      }
      _startSwapping();
    });
  }

  void _stopSwapping() {
    context.read<CryptoSwapDataBloc>().add(OnStopSwap());
  }

  void _startSwapping() {
    context.read<CryptoSwapDataBloc>().add(OnStartSwap(
        givenAmount: num.tryParse(controllerList.first.text) ?? 0,
        fromSymUpperCase: widget.model.first.symbol?.toUpperCase() ?? "",
        toSymUpperCase: widget.model.last.symbol?.toUpperCase() ?? "",
        toFiatUpperCase:
            _initialDropValue?.toUpperCase() ?? vsCurrencyList.first));
  }

  void _clearControllers() {
    for (var element in controllerList) {
      element.clear();
    }
  }

  void _disposeControllers() {
    for (var element in controllerList) {
      element.dispose();
    }
  }

  void _reverseCryptoList() {
    widget.model = widget.model.reversed.toList();
  }

  void _reverseControllerList() {
    controllerList = controllerList.reversed.toList();
  }
}
