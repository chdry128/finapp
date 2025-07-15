class Loan {
  final String? id;
  final String name;
  final double amount;
  final DateTime dueDate;
  final String notes;
  final bool isLent; // true = I lent, false = I owe
  final bool isPaid;

  Loan({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.notes,
    required this.isLent,
    this.isPaid = false,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'amount': amount,
    'dueDate': dueDate.toIso8601String(),
    'notes': notes,
    'isLent': isLent,
    'isPaid': isPaid,
  };

  factory Loan.fromMap(String id, Map<String, dynamic> map) => Loan(
    id: id,
    name: map['name'],
    amount: map['amount'],
    dueDate: DateTime.parse(map['dueDate']),
    notes: map['notes'],
    isLent: map['isLent'],
    isPaid: map['isPaid'],
  );
}