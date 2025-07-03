class RecurringTransaction {
  final int? id;
  final String description;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String account;
  final String frequency; // 'daily', 'weekly', 'monthly', 'yearly'
  final int interval; // e.g., every 2 weeks = interval: 2, frequency: 'weekly'
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? lastProcessed;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurringTransaction({
    this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.account,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.lastProcessed,
    this.isActive = true,
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
      'category': category,
      'account': account,
      'frequency': frequency,
      'interval': interval,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate?.millisecondsSinceEpoch,
      'lastProcessed': lastProcessed?.millisecondsSinceEpoch,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id']?.toInt(),
      description: map['description'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      account: map['account'] ?? '',
      frequency: map['frequency'] ?? 'monthly',
      interval: map['interval']?.toInt() ?? 1,
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) : null,
      lastProcessed: map['lastProcessed'] != null ? DateTime.fromMillisecondsSinceEpoch(map['lastProcessed']) : null,
      isActive: (map['isActive'] ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  RecurringTransaction copyWith({
    int? id,
    String? description,
    double? amount,
    String? type,
    String? category,
    String? account,
    String? frequency,
    int? interval,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? lastProcessed,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringTransaction(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      account: account ?? this.account,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      lastProcessed: lastProcessed ?? this.lastProcessed,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  DateTime? getNextDueDate() {
    if (!isActive) return null;
    
    final baseDate = lastProcessed ?? startDate;
    
    switch (frequency) {
      case 'daily':
        return baseDate.add(Duration(days: interval));
      case 'weekly':
        return baseDate.add(Duration(days: 7 * interval));
      case 'monthly':
        return DateTime(baseDate.year, baseDate.month + interval, baseDate.day);
      case 'yearly':
        return DateTime(baseDate.year + interval, baseDate.month, baseDate.day);
      default:
        return null;
    }
  }

  bool isDue() {
    final nextDue = getNextDueDate();
    if (nextDue == null) return false;
    
    final now = DateTime.now();
    return now.isAfter(nextDue) || now.isAtSameMomentAs(nextDue);
  }

  @override
  String toString() {
    return 'RecurringTransaction(id: $id, description: $description, amount: $amount, frequency: $frequency)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecurringTransaction &&
        other.id == id &&
        other.description == description &&
        other.amount == amount &&
        other.type == type &&
        other.category == category &&
        other.account == account &&
        other.frequency == frequency &&
        other.interval == interval &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        description.hashCode ^
        amount.hashCode ^
        type.hashCode ^
        category.hashCode ^
        account.hashCode ^
        frequency.hashCode ^
        interval.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isActive.hashCode;
  }
}