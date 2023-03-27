import 'package:cryptonic/src/domain/models/crypto_list_model.dart';
import 'package:cryptonic/src/utils/constants/app_colors.dart';
import 'package:cryptonic/src/utils/constants/app_icons.dart';
import 'package:cryptonic/src/utils/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CryptoListItemWidget extends StatelessWidget {
  const CryptoListItemWidget({
    required this.cryptoModel,
    required this.isHomePage,
    super.key,
  });

  final CryptoListModel cryptoModel;
  final bool isHomePage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            height: 50.w,
            width: 50.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
                color: (cryptoModel.isSelected && isHomePage)
                    ? Colors.amber
                    : AppColors.secondaryText,
                borderRadius: BorderRadius.circular(8.r)),
            child: Image.network(
              cryptoModel.model.image ?? "",
              width: 40.w,
              height: 40.w,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
          SizedBox(width: 10.w),
          Flexible(
            fit: FlexFit.loose,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cryptoModel.model.name ?? "",
                      style: AppTextStyles.primaryTextStyle
                          .copyWith(fontSize: 16.sp),
                    ),
                    Text(
                      cryptoModel.model.symbol!.toUpperCase(),
                      style: AppTextStyles.secondaryTextStyle,
                    ),
                  ],
                ),
                isHomePage
                    ? _trendIndicator(
                        cryptoModel.model.priceChangePercentage24h!.isNegative,
                        cryptoModel.model.priceChangePercentage24h!,
                      )
                    : const SizedBox.shrink()
              ],
            ),
          )
        ],
      ),
    );
  }

  _trendIndicator(bool isNegative, num percent) {
    return Row(
      children: [
        Text("${percent.toStringAsFixed(2)} %",
            style: AppTextStyles.primaryTextStyle.copyWith(
              fontSize: 12.sp,
            )),
        SizedBox(width: 5.w),
        Image.asset(
          isNegative ? AppIcons.decreaseIcon : AppIcons.increaseIcon,
          height: 20.w,
          width: 20.w,
        )
      ],
    );
  }
}
