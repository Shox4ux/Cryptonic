import 'package:cryptonic/core/domain/crypto_model.dart';
import 'package:cryptonic/core/state_management/crypto_list_bloc/crypto_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_preview_bloc/crypto_preview_bloc.dart';
import 'package:cryptonic/core/state_management/crypto_selected_bloc/crypto_selected_bloc.dart';
import 'package:cryptonic/ui/res/constants/app_colors.dart';
import 'package:cryptonic/ui/res/constants/app_text_styles.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_days_enum.dart';
import 'package:cryptonic/ui/res/enums/preview_interval_type_enum.dart';
import 'package:cryptonic/ui/res/navigation/route_names.dart';
import 'package:cryptonic/ui/res/widgets/crypto_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TokensListScreen extends StatelessWidget {
  const TokensListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            right: 20.w,
            left: 20.w,
            top: 20.w,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  "Crypto currency",
                  style: AppTextStyles.primaryTextStyle,
                ),
              ),
              SizedBox(height: 10.h),
              Flexible(
                flex: 1,
                child: Container(
                  height: 50.h,
                  width: double.maxFinite,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.greenLine,
                      width: 2.h,
                    ),
                  ),
                  child: TextField(
                    style: AppTextStyles.primaryTextStyle.copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.normal,
                    ),
                    onChanged: (value) {
                      context
                          .read<CryptoBloc>()
                          .add(OnSearchCryptoList(query: value));
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Flexible(
                flex: 12,
                child: BlocBuilder<CryptoBloc, CryptoState>(
                  builder: (context, state) {
                    if (state is OnCryptoSuccess) {
                      return SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          children: [
                            Flexible(
                              fit: FlexFit.loose,
                              flex: 5,
                              child: CustomScrollView(
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      childCount: state.cryptoList.length,
                                      (context, index) => GestureDetector(
                                        onTap: () {
                                          context
                                              .read<CryptoBloc>()
                                              .selectCryptoToPreview(
                                                state.cryptoList[index],
                                              );

                                          // context.read<CryptoBloc>().testFunc(
                                          //     state.cryptoList[index]);
                                        },
                                        child: CryptoListItemWidget(
                                          cryptoModel: state.cryptoList[index],
                                          isHomePage: true,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: Padding(
                                padding: EdgeInsets.only(top: 20.h),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      fixedSize: Size(double.maxFinite, 60.h)),
                                  onPressed: state.isReadyToWatch
                                      ? () {
                                          _requestForPreview(state, context);
                                          //============
                                          _submitSelectedList(
                                              state.selectedCryptos, context);
                                          //================
                                          Navigator.pushNamed(
                                              context, RouteNames.preview);
                                        }
                                      : null,
                                  child: Text(
                                    "Watch",
                                    style:
                                        AppTextStyles.primaryTextStyle.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
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
                                  context
                                      .read<CryptoBloc>()
                                      .add(OnFetch(currencyCode: "usd"));
                                },
                                child: const Text("Retry"))
                          ],
                        ),
                      );
                    }
                    if (state is OnCryptoProgress) {
                      return const Center(
                          child: CircularProgressIndicator.adaptive());
                    }

                    return const Center(child: Text("There is no data yet"));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitSelectedList(
    List<CryptoModel> selectedCryptos,
    BuildContext context,
  ) {
    context
        .read<CryptoSelectedBloc>()
        .add(OnSubmitSelectedCryptosList(submittedList: selectedCryptos));
  }

  void _requestForPreview(OnCryptoSuccess state, BuildContext context) {
    context.read<CryptoPreviewBloc>().add(
          OnPreview(
            coinId: state.selectedCryptos.first.id!,
            currencyCode: "usd",
            interval: PreviewIntervalType.hourly.interval,
            days: PreviewIntervalDays.day.interval,
          ),
        );
  }
}
