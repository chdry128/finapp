class Note {
  final String? id;
  final String text;
  final String category; // 'today' or 'monthly'
  final DateTime createdAt;

  Note({
    this.id,
    required this.text,
    required this.category,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'text': text,
    'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Note.fromMap(String id, Map<String, dynamic> map) => Note(
    id: id,
    text: map['text'],
    category: map['category'],
    createdAt: DateTime.parse(map['createdAt']),
  );
}