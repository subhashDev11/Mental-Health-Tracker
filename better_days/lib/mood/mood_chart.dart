import 'package:better_days/models/mood.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MoodChartSyncfusion extends StatelessWidget {
  final List<Mood> moods;

  const MoodChartSyncfusion({super.key, required this.moods});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Mood Tracker'),
      legend: Legend(isVisible: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time'),
        dateFormat: DateFormat.Hm(),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 6,
        interval: 1,
        title: AxisTitle(text: 'Mood Level'),
        axisLabelFormatter: (axisLabelRenderArgs) {
          switch (axisLabelRenderArgs.value) {
            case 1:
              return ChartAxisLabel("😠", TextStyle());
            case 2:
              return ChartAxisLabel("😞", TextStyle());
            case 3:
              return ChartAxisLabel("😐", TextStyle());
            case 4:
              return ChartAxisLabel('🙂', TextStyle());
            case 5:
              return ChartAxisLabel('😁', TextStyle());
            default:
              return ChartAxisLabel(axisLabelRenderArgs.text, TextStyle());
          }
        },
      ),
      series: <CartesianSeries<Mood, DateTime>>[
        LineSeries<Mood, DateTime>(
          dataSource: moods,
          xValueMapper: (Mood mood, _) => mood.date ?? DateTime.now(),
          yValueMapper: (Mood mood, _) => mood.value!.value,
          name: 'Mood',
          markerSettings: const MarkerSettings(isVisible: true),
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          color: Colors.blue,
          enableTooltip: true,
          pointColorMapper: (Mood mood, _) {
            switch (mood.value) {
              case 1:
                return Colors.red;
              case 2:
                return Colors.orange;
              case 3:
                return Colors.yellow;
              case 4:
                return Colors.lightGreen;
              case 5:
                return Colors.green;
              default:
                return Colors.grey;
            }
          },
        ),
      ],
    );
  }
}

class SmoothMoodChart extends StatefulWidget {
  final List<Mood> moods;

  const SmoothMoodChart({super.key, required this.moods});

  @override
  State<SmoothMoodChart> createState() => _SmoothMoodChartState();
}

class _SmoothMoodChartState extends State<SmoothMoodChart> {
  List<Mood> get moods => widget.moods;

  @override
  Widget build(BuildContext context) {
    if (moods.isEmpty) {
      return const Center(child: Text('No mood data available'));
    }

    // Sort moods by date
    final sortedMoods = List<Mood>.from(moods)
      ..sort((a, b) => (a.date ?? DateTime.now()).compareTo(b.date ?? DateTime.now()));

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          mainData(sortedMoods),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        ),
      ),
    );
  }

  LineChartData mainData(List<Mood> moods) {
    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          //tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              final mood = moods[spot.spotIndex];
              return LineTooltipItem(
                '${_moodEmoji(mood.value!.value)} ${mood.value}/5\n'
                    '${mood.note ?? 'No note'}\n'
                    '${DateFormat('MMM d, H:mm').format(mood.date ?? DateTime.now())}',
                const TextStyle(color: Colors.white),
              );
            }).toList();
          },
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: _calculateVerticalInterval(moods),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateVerticalInterval(moods),
            getTitlesWidget: (value, meta) {
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  DateFormat.Hm().format(date),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _moodEmoji(value.toInt()),
                  style: const TextStyle(fontSize: 16),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      minX: moods.first.date?.millisecondsSinceEpoch.toDouble() ?? 0,
      maxX: moods.last.date?.millisecondsSinceEpoch.toDouble() ?? 0,
      minY: 0,
      maxY: 6,
      lineBarsData: [
        LineChartBarData(
          spots: moods.map((mood) {
            return FlSpot(
              (mood.date?.millisecondsSinceEpoch.toDouble() ?? 0),
              mood.value!.value.toDouble(),
            );
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.3,
          color: Colors.blue.withOpacity(0.5),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: moods[index].value!.getMoodColor,
                strokeColor: Colors.black.withOpacity(0.5),
                strokeWidth: 1,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.1),
                Colors.blue.withOpacity(0.01),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          shadow: const Shadow(
            blurRadius: 8,
            color: Colors.blue,
          ),
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          for (int i = 1; i <= 5; i++)
            HorizontalLine(
              y: i.toDouble(),
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
        ],
      ),
    );
  }

  double _calculateVerticalInterval(List<Mood> moods) {
    if (moods.length < 2) return 3600000; // 1 hour default

    final duration = moods.last.date!.difference(moods.first.date!);
    if (duration.inHours < 2) return 900000; // 15 minutes
    if (duration.inHours < 6) return 1800000; // 30 minutes
    if (duration.inHours < 12) return 3600000; // 1 hour
    return 7200000; // 2 hours
  }

  Color _moodColor(int value) {
    switch (value) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      case 3: return Colors.yellow;
      case 4: return Colors.lightGreen;
      case 5: return Colors.green;
      default: return Colors.grey;
    }
  }

  String _moodEmoji(int value) {
    switch (value) {
      case 1: return '😠';
      case 2: return '😞';
      case 3: return '😐';
      case 4: return '🙂';
      case 5: return '😁';
      default: return '😒';
    }
  }
}