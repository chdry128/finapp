import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/budget.dart';
import 'package:personal_finance_lite/models/expense.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:personal_finance_lite/screens/budget/edit_budget_screen.dart';
import 'package:personal_finance_lite/widgets/progress_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditBudgetScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Budget>>(
        stream: data.budgetStream,
        builder: (context, budgetSnap) {
          if (!budgetSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final budgets =
              budgetSnap.data!.where((b) => b.monthYear == monthKey).toList();
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets set for this month'));
          }
          return StreamBuilder<List<Expense>>(
            stream: data.expenseStream,
            builder: (context, expenseSnap) {
              final expenses = expenseSnap.data ?? [];
              final monthStart = DateTime(now.year, now.month, 1);
              final monthEnd = DateTime(now.year, now.month + 1, 1);
              final monthExpenses = expenses.where((e) =>
                  e.date
                      .isAfter(monthStart.subtract(const Duration(days: 1))) &&
                  e.date.isBefore(monthEnd));
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: budgets.length,
                itemBuilder: (_, index) {
                  final budget = budgets[index];
                  final spent = monthExpenses
                      .where((e) => e.category == budget.category)
                      .fold<double>(0, (sum, e) => sum + e.amount);
                  final percent = budget.limit == 0 ? 0 : spent / budget.limit;
                  return Card(
                    child: ListTile(
                      title: Text(budget.category),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProgressBar(value: percent.toDouble()),
                          Text(
                              '${NumberFormat.currency(symbol: '\$').format(spent)} / ${NumberFormat.currency(symbol: '\$').format(budget.limit)}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditBudgetScreen(budget: budget),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
