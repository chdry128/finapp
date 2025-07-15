import 'package:flutter/material.dart';
import 'package:personal_finance_lite/models/budget.dart';
import 'package:personal_finance_lite/models/expense.dart';
import 'package:personal_finance_lite/models/income.dart';
import 'package:personal_finance_lite/models/loan.dart';
import 'package:personal_finance_lite/models/note.dart';
import 'package:personal_finance_lite/services/firestore_service.dart';

class DataProvider with ChangeNotifier {
  final String uid;
  final FirestoreService _db = FirestoreService();

  DataProvider(this.uid) {
    _initStreams();
  }

  // Streams
  late final Stream<List<Income>> incomeStream;
  late final Stream<List<Expense>> expenseStream;
  late final Stream<List<Budget>> budgetStream;
  late final Stream<List<Loan>> loanStream;
  late final Stream<List<Note>> noteStream;

  void _initStreams() {
    incomeStream = _db.incomeStream(uid);
    expenseStream = _db.expenseStream(uid);
    budgetStream = _db.budgetStream(uid);
    loanStream = _db.loanStream(uid);
    noteStream = _db.noteStream(uid);
  }

  // CRUD helpers
  Future<void> addIncome(Income income) async {
    await _db.addIncome(uid, income);
  }

  Future<void> updateIncome(Income income) async {
    await _db.updateIncome(uid, income);
  }

  Future<void> deleteIncome(String id) async {
    await _db.deleteIncome(uid, id);
  }

  Future<void> addExpense(Expense expense) async {
    await _db.addExpense(uid, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.updateExpense(uid, expense);
  }

  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(uid, id);
  }

  Future<void> setBudget(Budget budget) async {
    await _db.setBudget(uid, budget);
  }

  Future<void> addLoan(Loan loan) async {
    await _db.addLoan(uid, loan);
  }

  Future<void> updateLoan(Loan loan) async {
    await _db.updateLoan(uid, loan);
  }

  Future<void> addNote(Note note) async {
    await _db.addNote(uid, note);
  }

  Future<void> updateNote(Note note) async {
    await _db.updateNote(uid, note);
  }

  Future<void> deleteNote(String id) async {
    await _db.deleteNote(uid, id);
  }

  Future<Map<String, dynamic>> exportAll() => _db.exportAll(uid);

  Future<void> importFromJson(Map<String, dynamic> data) =>
      _db.importFromJson(uid, data);
}