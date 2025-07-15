import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/income.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:personal_finance_lite/screens/income/add_edit_income_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class IncomeListScreen extends StatelessWidget {
  const IncomeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);
    return Scaffold(
      appBar: AppBar(title: const Text('Income')),
      body: StreamBuilder<List<Income>>(
        stream: data.incomeStream,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final inc = list[i];
              return ListTile(
                title: Text(NumberFormat.currency(symbol: '\$').format(inc.amount)),
                subtitle: Text('${inc.category} | ${DateFormat.yMMMd().format(inc.date)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditIncomeScreen(income: inc),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddEditIncomeScreen())),
      ),
    );
  }
}