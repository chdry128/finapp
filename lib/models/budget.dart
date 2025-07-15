class Budget {
  final String? id;
  final String category;
  final double limit;
  final String monthYear; // yyyy-MM

  Budget({
    this.id,
    required this.category,
    required this.limit,
    required this.monthYear,
  });

  Map<String, dynamic> toMap() => {
    'category': category,
    'limit': limit,
    'monthYear': monthYear,
  };

  factory Budget.fromMap(String id, Map<String, dynamic> map) => Budget(
    id: id,
    category: map['category'],
    limit: map['limit'],
    monthYear: map['monthYear'],
  );
}