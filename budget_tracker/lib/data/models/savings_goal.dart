class SavingsGoal {
  final int? id;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final String icon;
  final int color;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavingsGoal({
    this.id,
    required this.name,
    required this.description,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.targetDate,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      targetAmount: map['target_amount']?.toDouble() ?? 0.0,
      currentAmount: map['current_amount']?.toDouble() ?? 0.0,
      targetDate: DateTime.parse(map['target_date']),
      icon: map['icon'] ?? '',
      color: map['color']?.toInt() ?? 0,
      isCompleted: map['is_completed'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'target_date': targetDate.toIso8601String(),
      'icon': icon,
      'color': color,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  double get remaining => targetAmount - currentAmount;
  double get progressPercentage => targetAmount > 0 ? (currentAmount / targetAmount) * 100 : 0;
  int get daysLeft => targetDate.difference(DateTime.now()).inDays;
  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  SavingsGoal copyWith({
    int? id,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
    int? color,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'SavingsGoal(id: $id, name: $name, targetAmount: $targetAmount, currentAmount: $currentAmount, targetDate: $targetDate, isCompleted: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.targetAmount == targetAmount &&
        other.currentAmount == currentAmount &&
        other.targetDate == targetDate &&
        other.icon == icon &&
        other.color == color &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        targetAmount.hashCode ^
        currentAmount.hashCode ^
        targetDate.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        isCompleted.hashCode;
  }
}