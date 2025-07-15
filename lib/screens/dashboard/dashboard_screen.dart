import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/expense.dart';
import 'package:personal_finance_lite/models/income.dart';
import 'package:personal_finance_lite/models/budget.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:personal_finance_lite/screens/budget/budget_screen.dart';
import 'package:personal_finance_lite/screens/expense/expense_list_screen.dart';
import 'package:personal_finance_lite/screens/income/income_list_screen.dart';
import 'package:personal_finance_lite/screens/loan/loan_screen.dart';
import 'package:personal_finance_lite/screens/notes/notes_screen.dart';
import 'package:personal_finance_lite/screens/settings/settings_screen.dart';
import 'package:personal_finance_lite/widgets/pie_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);
    final today = DateTime.now();
    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _TodaySummary(data: data, today: today),
            _MonthlyBudget(data: data, monthStart: monthStart, monthEnd: monthEnd),
            const SizedBox(height: 20),
            Image.asset('assets/images/finance_illustration.png', height: 150),
            const SizedBox(height: 20),
            const Text('Expense by Category', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: PieChartWidget(expenseStream: data.expenseStream),
            ),
            const SizedBox(height: 30),
            _NavigationButtons(),
          ],
        ),
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  final DataProvider data;
  final DateTime today;

  const _TodaySummary({required this.data, required this.today});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Income>>(
      stream: data.incomeStream,
      builder: (context, incomeSnap) {
        final todayIncome = (incomeSnap.data ?? [])
            .where((e) =>
        e.date.year == today.year &&
            e.date.month == today.month &&
            e.date.day == today.day)
            .fold<double>(0, (sum, e) => sum + e.amount);
        return StreamBuilder<List<Expense>>(
          stream: data.expenseStream,
          builder: (context, expenseSnap) {
            final todayExpense = (expenseSnap.data ?? [])
                .where((e) =>
            e.date.year == today.year &&
                e.date.month == today.month &&
                e.date.day == today.day)
                .fold<double>(0, (sum, e) => sum + e.amount);
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Income: ${NumberFormat.currency(symbol: '\$').format(todayIncome)}'),
                    Text('Expense: ${NumberFormat.currency(symbol: '\$').format(todayExpense)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MonthlyBudget extends StatelessWidget {
  final DataProvider data;
  final DateTime monthStart;
  final DateTime monthEnd;

  const _MonthlyBudget({required this.data, required this.monthStart, required this.monthEnd});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Expense>>(
      stream: data.expenseStream,
      builder: (context, expenseSnap) {
        final monthExpense = (expenseSnap.data ?? [])
            .where((e) =>
                !e.date.isBefore(monthStart) && e.date.isBefore(monthEnd))
            .fold<double>(0, (sum, e) => sum + e.amount);
        return StreamBuilder<List<Budget>>(
          stream: data.budgetStream,
          builder: (context, budgetSnap) {
            final totalBudget = (budgetSnap.data ?? []).fold<double>(0, (sum, e) => sum + e.limit);
            final used = totalBudget == 0 ? 0.0 : monthExpense / totalBudget;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month Budget', style: Theme.of(context).textTheme.titleMedium),
                    LinearProgressIndicator(value: (used > 1 ? 1.0 : used).toDouble()),
                    Text(
                        '${NumberFormat.currency(symbol: '\$').format(monthExpense)} / ${NumberFormat.currency(symbol: '\$').format(totalBudget)}'),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _NavButton(label: 'Income', icon: Icons.trending_up, screen: const IncomeListScreen()),
        _NavButton(label: 'Expense', icon: Icons.trending_down, screen: const ExpenseListScreen()),
        _NavButton(label: 'Budget', icon: Icons.pie_chart, screen: const BudgetScreen()),
        _NavButton(label: 'Loans', icon: Icons.account_balance, screen: const LoanScreen()),
        _NavButton(label: 'Notes', icon: Icons.note, screen: const NotesScreen()),
        _NavButton(label: 'Settings', icon: Icons.settings, screen: const SettingsScreen()),
      ],
    );
  }
}

class _NavButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Widget screen;

  const _NavButton({required this.label, required this.icon, required this.screen});

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => widget.screen),
          );
        });
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          icon: Icon(widget.icon, color: Colors.white),
          label: Text(widget.label, style: const TextStyle(color: Colors.white)),
          onPressed: null, // Disable the default onPressed
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}