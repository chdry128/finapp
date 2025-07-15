import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_lite/models/loan.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:provider/provider.dart';

class LoanScreen extends StatefulWidget {
  const LoanScreen({super.key});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddEditDialog(BuildContext context, DataProvider data, {Loan? loan}) {
    final nameCtrl = TextEditingController(text: loan?.name);
    final amountCtrl = TextEditingController(text: loan?.amount.toString());
    final notesCtrl = TextEditingController(text: loan?.notes);
    DateTime dueDate = loan?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    bool isLent = loan?.isLent ?? true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(loan == null ? 'Add Loan' : 'Edit Loan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextFormField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(labelText: 'Amount'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: Text('Due: ${DateFormat.yMMMd().format(dueDate)}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final dt = await showDatePicker(
                      context: context,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (dt != null) setState(() => dueDate = dt);
                  },
                ),
                TextFormField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
                if (loan == null)
                  SwitchListTile(
                    title: const Text('I lent the money'),
                    value: isLent,
                    onChanged: (v) => setState(() => isLent = v),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newLoan = Loan(
                  id: loan?.id,
                  name: nameCtrl.text,
                  amount: double.parse(amountCtrl.text),
                  dueDate: dueDate,
                  notes: notesCtrl.text,
                  isLent: isLent,
                  isPaid: loan?.isPaid ?? false,
                );
                if (loan == null) {
                  await data.addLoan(newLoan);
                } else {
                  await data.updateLoan(newLoan);
                }
                if (mounted) Navigator.pop(context);
              },
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Tracker'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'I Lent'),
            Tab(text: 'I Owe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LoanList(data: data, isLent: true, onEdit: (loan) => _showAddEditDialog(context, data, loan: loan)),
          _LoanList(data: data, isLent: false, onEdit: (loan) => _showAddEditDialog(context, data, loan: loan)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddEditDialog(context, data),
      ),
    );
  }
}

class _LoanList extends StatelessWidget {
  final DataProvider data;
  final bool isLent;
  final void Function(Loan loan) onEdit;

  const _LoanList({required this.data, required this.isLent, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Loan>>(
      stream: data.loanStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final loans = snapshot.data!.where((l) => l.isLent == isLent).toList();
        if (loans.isEmpty) {
          return Center(
            child: Text('No ${isLent ? 'lent' : 'borrowed'} loans'),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: loans.length,
          itemBuilder: (_, index) {
            final loan = loans[index];
            final overdue =
                !loan.isPaid && loan.dueDate.isBefore(DateTime.now());
            return Card(
              color: overdue ? Colors.red.shade50 : null,
              child: ListTile(
                title: Text(loan.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${NumberFormat.currency(symbol: '\$').format(loan.amount)}'),
                    Text('Due ${DateFormat.yMMMd().format(loan.dueDate)}'),
                    if (loan.notes.isNotEmpty) Text(loan.notes),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!loan.isPaid)
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          await data.updateLoan(
                            loan.copyWith(isPaid: true),
                          );
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(loan),
                    ),
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

extension _LoanCopy on Loan {
  Loan copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? dueDate,
    String? notes,
    bool? isLent,
    bool? isPaid,
  }) =>
      Loan(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        dueDate: dueDate ?? this.dueDate,
        notes: notes ?? this.notes,
        isLent: isLent ?? this.isLent,
        isPaid: isPaid ?? this.isPaid,
      );
}