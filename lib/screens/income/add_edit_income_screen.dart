import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance_lite/models/income.dart';
import 'package:personal_finance_lite/providers/auth_provider.dart';
import 'package:personal_finance_lite/providers/data_provider.dart';
import 'package:provider/provider.dart';

class AddEditIncomeScreen extends StatefulWidget {
  final Income? income;
  const AddEditIncomeScreen({super.key, this.income});

  @override
  State<AddEditIncomeScreen> createState() => _AddEditIncomeScreenState();
}

class _AddEditIncomeScreenState extends State<AddEditIncomeScreen> {
  final _form = GlobalKey<FormState>();
  late double _amount;
  late DateTime _date;
  final _category = TextEditingController();
  final _desc = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _amount = widget.income!.amount;
      _date = widget.income!.date;
      _category.text = widget.income!.category;
      _desc.text = widget.income!.description;
    } else {
      _amount = 0;
      _date = DateTime.now();
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
    final data = DataProvider(uid);
    final inc = Income(
      id: widget.income?.id,
      amount: _amount,
      date: _date,
      category: _category.text.trim(),
      description: _desc.text.trim(),
    );
    if (widget.income == null) {
      await data.addIncome(inc);
    } else {
      await data.updateIncome(inc);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.income == null ? 'Add Income' : 'Edit Income')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                initialValue: _amount.toString(),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _amount = double.parse(v!),
              ),
              ListTile(
                title: Text('Date: ${DateFormat.yMMMd().format(_date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final dt = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100));
                  if (dt != null) setState(() => _date = dt);
                },
              ),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _desc,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const Spacer(),
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