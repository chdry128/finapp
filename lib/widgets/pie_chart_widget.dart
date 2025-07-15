import 'package:fl_chart/fl_chart.dart';
import 'package.flutter/material.dart';
import 'package:personal_finance_lite/models/expense.dart';

class PieChartWidget extends StatefulWidget {
  final Stream<List<Expense>> expenseStream;

  const PieChartWidget({super.key, required this.expenseStream});

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: widget.expenseStream,
      builder: (context, snap) {
        if (!snap.hasData) return const CircularProgressIndicator();
        final expenses = snap.data!;
        final Map<String, double> data = {};
        for (var e in expenses) {
          data[e.category] = (data[e.category] ?? 0) + e.amount;
        }
        final total = data.values.fold<double>(0, (a, b) => a + b);
        if (total == 0) {
          return Image.asset('assets/placeholder/empty.png');
        }
        return PieChart(
          PieChartData(
            pieTouchData: PieTouchData(
              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                setState(() {
                  if (!event.isInterestedForInteractions ||
                      pieTouchResponse == null ||
                      pieTouchResponse.touchedSection == null) {
                    touchedIndex = -1;
                    return;
                  }
                  touchedIndex =
                      pieTouchResponse.touchedSection!.touchedSectionIndex;
                });
              },
            ),
            sections: data.entries.map((e) {
              final isTouched =
                  data.keys.toList().indexOf(e.key) == touchedIndex;
              final fontSize = isTouched ? 25.0 : 16.0;
              final radius = isTouched ? 90.0 : 80.0;
              return PieChartSectionData(
                value: e.value,
                title:
                    '${e.key}\n${(e.value / total * 100).toStringAsFixed(1)}%',
                color: Colors
                    .primaries[e.key.hashCode % Colors.primaries.length],
                radius: radius,
                titleStyle: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xffffffff),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}