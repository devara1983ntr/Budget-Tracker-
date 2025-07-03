class Transaction {
  final int? id;
  final String description;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String category;
  final String account;
  final String? notes;
  final String? receiptImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.account,
    this.notes,
    this.receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.millisecondsSinceEpoch,
      'category': category,
      'account': account,
      'notes': notes,
      'receiptImagePath': receiptImagePath,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id']?.toInt(),
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      category: map['category'] ?? '',
      account: map['account'] ?? '',
      notes: map['notes'],
      receiptImagePath: map['receiptImagePath'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Transaction copyWith({
    int? id,
    String? description,
    double? amount,
    String? type,
    DateTime? date,
    String? category,
    String? account,
    String? notes,
    String? receiptImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      category: category ?? this.category,
      account: account ?? this.account,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, type: $type, date: $date, category: $category, account: $account)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.date == date &&
        other.category == category &&
        other.account == account &&
        other.notes == notes &&
        other.receiptImagePath == receiptImagePath;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        date.hashCode ^
        category.hashCode ^
        account.hashCode ^
        notes.hashCode ^
        receiptImagePath.hashCode;
  }
}