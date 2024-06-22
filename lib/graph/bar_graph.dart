// ignore_for_file: prefer_const_constructors

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:square_pants/graph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List weeklySummary;
  const MyBarGraph({super.key, required this.weeklySummary});

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
      sunAmount: weeklySummary[0],
      monAmount: weeklySummary[1],
      tueAmount: weeklySummary[2],
      wedAmount: weeklySummary[3],
      thuAmount: weeklySummary[4],
      friAmount: weeklySummary[5],
      satAmount: weeklySummary[6],
    );
    myBarData.initializeBarData();
    return BarChart(
      BarChartData(
        maxY: 100,
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: getBottomTitles,
            ),
          ),
        ),
        barGroups: myBarData.barData
            .map((data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                        toY: data.y,
                        color: Color(0xff12171D),
                        width: 19,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: Color(0xffE4E4E4),
                        )),
                  ],
                ))
            .toList(),
      ),
    );
  }
}

Widget getBottomTitles(double value, TitleMeta meta) {
  const style = TextStyle(
      color: Color(0xff12171D),
      fontFamily: 'poppins',
      fontWeight: FontWeight.w400,
      fontSize: 13);

  String text;
  switch (value.toInt()) {
    case 0:
      text = 'S';
      break;
    case 1:
      text = 'M';
      break;
    case 2:
      text = 'T';
      break;
    case 3:
      text = 'W';
      break;
    case 4:
      text = 'T';
      break;
    case 5:
      text = 'F';
      break;
    case 6:
      text = 'S';
      break;
    default:
      text = '';
  }

  return SideTitleWidget(
      child: Text(text, style: style), axisSide: meta.axisSide);
}
