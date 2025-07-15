import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_lite/models/expense.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:personal_finance_lite/screens/expense/add_edit_expense_screen.dart';
import 'package:provider/provider.dart';

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by date',
            onPressed: () => _showFilterDialog(context, data),
          ),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: data.expenseStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data!;
          if (expenses.isEmpty) {
            return const Center(child: Text('No expenses yet'));
          }
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (_, index) {
              final exp = expenses[index];
              return ListTile(
                title: Text(NumberFormat.currency(symbol: '\$').format(exp.amount)),
                subtitle: Text('${exp.category} • ${DateFormat.yMMMd().format(exp.date)}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEditExpenseScreen(expense: exp),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await _confirmDelete(context);
                        if (ok ?? false) {
                          await data.deleteExpense(exp.id!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete expense?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('DELETE'),
        ),
      ],
    ),
  );

  void _showFilterDialog(BuildContext context, DataProvider data) {
    final now = DateTime.now();
    DateTimeRange? range = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0),
    );
    showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
      initialDateRange: range,
    ).then((r) {
      if (r != null) {
        // TODO: Implement filtered list (not covered here for brevity)
      }
    });
  }
}