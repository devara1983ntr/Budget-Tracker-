class Transaction {
  final int? id;
  final double amount;
  final String description;
  final String type; // 'income' or 'expense'
  final int categoryId;
  final int accountId;
  final DateTime date;
  final String? receiptImagePath;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Transaction({
    this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.receiptImagePath,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      amount: map['amount']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      categoryId: map['category_id']?.toInt() ?? 0,
      accountId: map['account_id']?.toInt() ?? 0,
      date: DateTime.parse(map['date']),
      receiptImagePath: map['receipt_image_path'],
      note: map['note'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type,
      'category_id': categoryId,
      'account_id': accountId,
      'date': date.toIso8601String(),
      'receipt_image_path': receiptImagePath,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Transaction copyWith({
    int? id,
    double? amount,
    String? description,
    String? type,
    int? categoryId,
    int? accountId,
    DateTime? date,
    String? receiptImagePath,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, amount: $amount, description: $description, type: $type, categoryId: $categoryId, accountId: $accountId, date: $date, receiptImagePath: $receiptImagePath, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.type == type &&
        other.categoryId == categoryId &&
        other.accountId == accountId &&
        other.date == date &&
        other.receiptImagePath == receiptImagePath &&
        other.note == note;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        amount.hashCode ^
        description.hashCode ^
        type.hashCode ^
        categoryId.hashCode ^
        accountId.hashCode ^
        date.hashCode ^
        receiptImagePath.hashCode ^
        note.hashCode;
  }
}