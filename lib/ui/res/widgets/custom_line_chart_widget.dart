import 'package:cryptonic/ui/res/constants/app_text_styles.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomLineChartWidget extends StatelessWidget {
  const CustomLineChartWidget({
    required this.spots,
    required this.isPositive,
    required this.minY,
    required this.maxY,
    required this.fiatCurrCode,
    required this.dates,
    super.key,
  });
  final List<FlSpot> spots;
  final bool isPositive;
  final double minY;
  final double maxY;
  final String fiatCurrCode;
  final List<String> dates;

  @override
  Widget build(BuildContext context) {
    List<Color> greenColors = [
      Colors.green.shade900,
      Colors.green.shade700,
    ];
    List<Color> redColors = [
      Colors.red.shade900,
      Colors.red.shade700,
    ];

    return LineChart(
      LineChartData(
        maxX: spots.last.x,
        maxY: _calculateMax(spots.last.y),
        minX: 0,
        minY: _calculateMin(spots.first.y),
        titlesData: FlTitlesData(
          show: true,
          topTitles: SideTitles(showTitles: false),
          leftTitles: SideTitles(showTitles: false),
          rightTitles: SideTitles(
            showTitles: false,
            reservedSize: 45.w,
            getTextStyles: (context, value) {
              return AppTextStyles.primaryTextStyle.copyWith(
                color: Colors.white,
                fontSize: 10.sp,
              );
            },
          ),
          bottomTitles: SideTitles(
            interval: 3,
            showTitles: true,
            getTitles: (value) {
              final index = int.tryParse(value.toString().replaceAll(".0", ""));
              return dates[index!];
            },
            checkToShowTitle:
                (minValue, maxValue, sideTitles, appliedInterval, value) {
              if ((value % 2) == 0) {
                return false;
              }

              return true;
            },
            getTextStyles: (context, value) {
              return AppTextStyles.primaryTextStyle.copyWith(
                color: Colors.white,
                fontSize: 8.sp,
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          drawHorizontalLine: true,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xff37434d),
              strokeWidth: 1,
            );
          },
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final flSpot = barSpot;
                return LineTooltipItem(
                  "${flSpot.y.toStringAsFixed(3)} $fiatCurrCode",
                  AppTextStyles.primaryTextStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    letterSpacing: 0.5,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            dotData: FlDotData(show: false),
            isCurved: true,
            barWidth: 3.w,
            colors: isPositive ? greenColors : redColors,
            belowBarData: BarAreaData(
              show: true,
              colors: isPositive
                  ? greenColors.map((e) => e.withOpacity(0.3)).toList()
                  : redColors.map((e) => e.withOpacity(0.3)).toList(),
            ),
            spots: spots,
            show: true,
          )
        ],
      ),
    );
  }

  _calculateMax(double maxY) {
    final calculated = maxY + (maxY * 0.06);
    return calculated;
  }

  _calculateMin(double minY) {
    final calculated = minY - (minY * 0.07);
    return calculated;
  }
}
