class Expense {
  final String? id;
  final double amount;
  final DateTime date;
  final String category;
  final String description;

  Expense({
    this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.description,
  });

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'date': date.toIso8601String(),
    'category': category,
    'description': description,
  };

  factory Expense.fromMap(String id, Map<String, dynamic> map) => Expense(
    id: id,
    amount: map['amount'],
    date: DateTime.parse(map['date']),
    category: map['category'],
    description: map['description'],
  );
}