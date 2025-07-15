import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/budget.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:provider/provider.dart';

class EditBudgetScreen extends StatefulWidget {
  final Budget? budget;
  const EditBudgetScreen({super.key, this.budget});

  @override
  State<EditBudgetScreen> createState() => _EditBudgetScreenState();
}

class _EditBudgetScreenState extends State<EditBudgetScreen> {
  final _form = GlobalKey<FormState>();
  final _categoryCtrl = TextEditingController();
  final _limitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _categoryCtrl.text = widget.budget!.category;
      _limitCtrl.text = widget.budget!.limit.toString();
    }
  }

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final budget = Budget(
      id: widget.budget?.id,
      category: _categoryCtrl.text.trim(),
      limit: double.parse(_limitCtrl.text),
      monthYear: monthKey,
    );
    await data.setBudget(budget);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _categoryCtrl,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _limitCtrl,
                decoration: const InputDecoration(labelText: 'Limit'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _save,
                child: const Text('SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}