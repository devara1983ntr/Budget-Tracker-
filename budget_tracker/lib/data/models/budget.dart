class Budget {
  final int? id;
  final String name;
  final double amount;
  final double spent;
  final int? categoryId; // null for overall budget
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String period; // 'monthly', 'weekly', 'yearly', 'custom'
  final DateTime createdAt;
  final DateTime updatedAt;

  const Budget({
    this.id,
    required this.name,
    required this.amount,
    this.spent = 0.0,
    this.categoryId,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.period,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      amount: map['amount']?.toDouble() ?? 0.0,
      spent: map['spent']?.toDouble() ?? 0.0,
      categoryId: map['category_id']?.toInt(),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: map['is_active'] == 1,
      period: map['period'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'spent': spent,
      'category_id': categoryId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'period': period,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get remaining => amount - spent;
  double get percentageUsed => amount > 0 ? (spent / amount) * 100 : 0;
  bool get isOverBudget => spent > amount;

  Budget copyWith({
    int? id,
    String? name,
    double? amount,
    double? spent,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? period,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      spent: spent ?? this.spent,
      categoryId: categoryId ?? this.categoryId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      period: period ?? this.period,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, name: $name, amount: $amount, spent: $spent, categoryId: $categoryId, startDate: $startDate, endDate: $endDate, isActive: $isActive, period: $period)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Budget &&
        other.id == id &&
        other.name == name &&
        other.amount == amount &&
        other.spent == spent &&
        other.categoryId == categoryId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.isActive == isActive &&
        other.period == period;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        amount.hashCode ^
        spent.hashCode ^
        categoryId.hashCode ^
        startDate.hashCode ^
        endDate.hashCode ^
        isActive.hashCode ^
        period.hashCode;
  }
}