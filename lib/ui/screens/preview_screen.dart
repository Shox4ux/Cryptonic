import 'dart:async';
import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/core/state_management/crypto_list_bloc/crypto_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_preview_bloc/crypto_preview_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_selected_bloc/crypto_selected_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_swap_bloc/crypto_swap_data_bloc.dart';
import 'package:cryptonic/ui/res/constants/app_colors.dart';
import 'package:cryptonic/ui/res/constants/app_text_styles.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_days_enum.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_type_enum.dart';
import 'package:cryptonic/ui/res/widgets/crypto_list_item_widget.dart';
import 'package:cryptonic/ui/res/widgets/custom_line_chart_widget.dart';
import 'package:cryptonic/ui/res/widgets/on_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreviewScreen extends StatefulWidget {
  PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final List<String> vsCurrencyList = [
    "USD",
    "EUR",
    "RUB",
  ];
  final List<TextEditingController> controllerList = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? _initialDropValue;
  bool _isReversed = false;
  bool _isTimerRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 25.w),
          child: BlocBuilder<CryptoSelectedBloc, CryptoSelectedState>(
            builder: (context, state) {
              if (state is OnReceivedSelectedList) {
                return _onSelectedCryptosReceived(state.receivedList);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _onSelectedCryptosReceived(List<CryptoModel> receivedList) {
    return Column(
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
                    receivedList.first.image ?? "",
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
                      _callPreviewData(receivedList.first);
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
                    receivedList.last.image ?? "",
                  ),
                ),
              ],
            ),
            Text(
              "Track changes",
              style: AppTextStyles.primaryTextStyle.copyWith(fontSize: 16.sp),
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
                              style: AppTextStyles.primaryTextStyle.copyWith(
                                fontSize: 18.sp,
                                color: Colors.white,
                              ))),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _initialDropValue = value;
                    _callPreviewData(receivedList.first);
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
              return _lineGraph(state, receivedList.first);
            }
            if (state is OnCryptoPreviewError) {
              return OnErrorWidget(
                onPressed: () {
                  _callPreviewData(receivedList.first);
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
          receivedList.first,
          receivedList.last,
          controllerList.first,
          true,
        ),
        SizedBox(height: 20.h),
        _currencyItem(
          receivedList.last,
          receivedList.first,
          controllerList.last,
          false,
        ),
      ],
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
                if (!isPrimary) {
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    controller.text = swapList.last.alCryptoCurrency;
                  });
                }
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
                          _swapCryptos(
                              value, current.symbol, alternative.symbol);
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
                          onPressed: () {},
                          message: state.message,
                        )
                      : Text(state.message,
                          style: const TextStyle(color: Colors.white)),
                );
              }
              if (state is CryptoSwapDataInitial) {
                return _onInitialState(current, alternative);
              }
              return _onInitialState(current, alternative);
            },
          ),
        )
      ],
    );
  }

  Widget _onInitialState(CryptoModel current, CryptoModel alternative) {
    return SizedBox(
      height: 60.h,
      width: double.maxFinite,
      child: TextField(
        enableInteractiveSelection: false,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          _swapCryptos(value, current.symbol, alternative.symbol);
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

  Widget _lineGraph(OnCryptoPreviewSuccess state, CryptoModel actualCrypto) {
    return Flexible(
        child: Container(
            height: 300.h,
            padding: EdgeInsets.only(right: 10.w, left: 10.w, top: 12.w),
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(8.r)),
            child: CustomLineChartWidget(
                spots: state.spots,
                isPositive: !actualCrypto.priceChangePercentage24h!.isNegative,
                maxY: actualCrypto.high24h?.toDouble() ?? 0,
                minY: actualCrypto.low24h?.toDouble() ?? 0,
                fiatCurrCode: _initialDropValue ?? vsCurrencyList.first,
                dates: state.dates)));
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
                              _callPreviewData(
                                state.cryptoList[index].model,
                              );
                            }
                            context
                                .read<CryptoBloc>()
                                .selectCryptoToPreview(state.cryptoList[index]);
                            context.read<CryptoBloc>().add(
                                  OnChangeSelectedCrypto(
                                    cryptoToUpdate: cryptoToRemove,
                                    selectedCrypto:
                                        state.cryptoList[index].model,
                                    currentList: state.cryptoList,
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
              return OnErrorWidget(
                onPressed: () {
                  context.read<CryptoBloc>().add(OnFetch(
                        currencyCode: _initialDropValue ?? vsCurrencyList.first,
                      ));
                },
                message: state.message,
              );
            }
            if (state is OnCryptoProgress) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _callPreviewData(CryptoModel cryptoModel) {
    context.read<CryptoPreviewBloc>().add(
          OnPreview(
            coinId: cryptoModel.id!,
            currencyCode: _initialDropValue ?? vsCurrencyList.first,
            interval: PreviewIntervalType.hourly.interval,
            days: PreviewIntervalDays.day.interval,
          ),
        );
  }

  void _reverseSwapList() {
    context.read<CryptoSwapDataBloc>().add(OnReverseSwap());
  }

  void _reverseCryptoList() {
    context.read<CryptoSelectedBloc>().add(OnCryptosListReversed());
  }

  Future<void> _swapCryptos(
    String text,
    String? fromSym,
    String? toSym,
  ) async {
    context.read<CryptoSwapDataBloc>().add(OnStartSwap(
          givenAmount: num.tryParse(text) ?? 0,
          fromSymUpperCase: fromSym!.toUpperCase(),
          toSymUpperCase: toSym!.toUpperCase(),
          toFiatUpperCase: _initialDropValue ?? vsCurrencyList.first,
        ));
  }
}
