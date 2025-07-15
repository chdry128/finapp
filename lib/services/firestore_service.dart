import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:personal_finance_lite/models/budget.dart';
import 'package:personal_finance_lite/models/expense.dart';
import 'package:personal_finance_lite/models/income.dart';
import 'package:personal_finance_lite/models/loan.dart';
import 'package:personal_finance_lite/models/note.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Income
  Future<void> addIncome(String uid, Income income) =>
      _db.collection('users').doc(uid).collection('income').add(income.toMap());

  Stream<List<Income>> incomeStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('income')
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => Income.fromMap(d.id, d.data())).toList());

  Future<void> updateIncome(String uid, Income income) => _db
      .collection('users')
      .doc(uid)
      .collection('income')
      .doc(income.id)
      .update(income.toMap());

  Future<void> deleteIncome(String uid, String id) => _db
      .collection('users')
      .doc(uid)
      .collection('income')
      .doc(id)
      .delete();

  // Expense
  Future<void> addExpense(String uid, Expense expense) =>
      _db.collection('users').doc(uid).collection('expense').add(expense.toMap());

  Stream<List<Expense>> expenseStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('expense')
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => Expense.fromMap(d.id, d.data())).toList());

  Future<void> updateExpense(String uid, Expense expense) => _db
      .collection('users')
      .doc(uid)
      .collection('expense')
      .doc(expense.id)
      .update(expense.toMap());

  Future<void> deleteExpense(String uid, String id) => _db
      .collection('users')
      .doc(uid)
      .collection('expense')
      .doc(id)
      .delete();

  // Budget
  Future<void> setBudget(String uid, Budget budget) =>
      _db.collection('users').doc(uid).collection('budgets').doc(budget.category).set(budget.toMap());

  Stream<List<Budget>> budgetStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('budgets')
      .snapshots()
      .map((snap) =>
      snap.docs.map((d) => Budget.fromMap(d.id, d.data())).toList());

  // Loan
  Future<void> addLoan(String uid, Loan loan) =>
      _db.collection('users').doc(uid).collection('loans').add(loan.toMap());

  Stream<List<Loan>> loanStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('loans')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Loan.fromMap(d.id, d.data())).toList());

  Future<void> updateLoan(String uid, Loan loan) => _db
      .collection('users')
      .doc(uid)
      .collection('loans')
      .doc(loan.id)
      .update(loan.toMap());

  // Note
  Future<void> addNote(String uid, Note note) =>
      _db.collection('users').doc(uid).collection('notes').add(note.toMap());

  Stream<List<Note>> noteStream(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('notes')
      .snapshots()
      .map((snap) => snap.docs.map((d) => Note.fromMap(d.id, d.data())).toList());

  Future<void> updateNote(String uid, Note note) => _db
      .collection('users')
      .doc(uid)
      .collection('notes')
      .doc(note.id)
      .update(note.toMap());

  Future<void> deleteNote(String uid, String id) => _db
      .collection('users')
      .doc(uid)
      .collection('notes')
      .doc(id)
      .delete();

  // Backup
  Future<Map<String, dynamic>> exportAll(String uid) async {
    final income = await _db.collection('users').doc(uid).collection('income').get();
    final expense = await _db.collection('users').doc(uid).collection('expense').get();
    final budgets = await _db.collection('users').doc(uid).collection('budgets').get();
    final loans = await _db.collection('users').doc(uid).collection('loans').get();
    final notes = await _db.collection('users').doc(uid).collection('notes').get();

    return {
      'income': income.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'expense': expense.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'budgets': budgets.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'loans': loans.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      'notes': notes.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
    };
  }

  Future<void> importFromJson(String uid, Map<String, dynamic> data) async {
    final batch = _db.batch();
    for (String collection in data.keys) {
      for (var item in data[collection]) {
        final doc = _db
            .collection('users')
            .doc(uid)
            .collection(collection)
            .doc(item['id']);
        batch.set(doc, item..remove('id'));
      }
    }
    await batch.commit();
  }
}