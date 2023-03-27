import 'package:cryptonic/src/utils/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

abstract class AppTextStyles {
  static TextStyle primaryTextStyle = TextStyle(
    color: AppColors.primaryText,
    fontSize: 24.sp,
    fontFamily: "Poppins",
    fontWeight: FontWeight.bold,
  );

  static TextStyle secondaryTextStyle = TextStyle(
    color: AppColors.secondaryText,
    fontSize: 12.sp,
    fontFamily: "Poppins",
    fontWeight: FontWeight.bold,
  );
}
