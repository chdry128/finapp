import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/expense.dart';

class PieChartWidget extends StatelessWidget {
  final Stream<List<Expense>> expenseStream;

  const PieChartWidget({super.key, required this.expenseStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: expenseStream,
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
            sections: data.entries.map((e) {
              return PieChartSectionData(
                value: e.value,
                title: '${e.key}\n${(e.value / total * 100).toStringAsFixed(1)}%',
                color: Colors.primaries[e.key.hashCode % Colors.primaries.length],
                radius: 80,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}