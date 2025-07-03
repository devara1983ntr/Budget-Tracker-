import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final String type; // 'income' or 'expense' or 'both'
  final DateTime createdAt;
  final DateTime updatedAt;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'type': type,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: IconData(map['iconCodePoint'] ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue'] ?? Colors.blue.value),
      type: map['type'] ?? 'both',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Category copyWith({
    int? id,
    String? name,
    IconData? icon,
    Color? color,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        type.hashCode;
  }

  // Default categories
  static List<Category> getDefaultCategories() {
    return [
      Category(name: 'Food & Dining', icon: Icons.restaurant, color: Colors.orange, type: 'expense'),
      Category(name: 'Transportation', icon: Icons.directions_car, color: Colors.blue, type: 'expense'),
      Category(name: 'Shopping', icon: Icons.shopping_bag, color: Colors.purple, type: 'expense'),
      Category(name: 'Entertainment', icon: Icons.movie, color: Colors.red, type: 'expense'),
      Category(name: 'Bills & Utilities', icon: Icons.receipt_long, color: Colors.brown, type: 'expense'),
      Category(name: 'Healthcare', icon: Icons.local_hospital, color: Colors.green, type: 'expense'),
      Category(name: 'Education', icon: Icons.school, color: Colors.indigo, type: 'expense'),
      Category(name: 'Travel', icon: Icons.flight, color: Colors.teal, type: 'expense'),
      Category(name: 'Salary', icon: Icons.work, color: Colors.green, type: 'income'),
      Category(name: 'Business', icon: Icons.business, color: Colors.blue, type: 'income'),
      Category(name: 'Investment', icon: Icons.trending_up, color: Colors.purple, type: 'income'),
      Category(name: 'Gift', icon: Icons.card_giftcard, color: Colors.pink, type: 'income'),
      Category(name: 'Other Income', icon: Icons.attach_money, color: Colors.amber, type: 'income'),
      Category(name: 'Other Expense', icon: Icons.more_horiz, color: Colors.grey, type: 'expense'),
    ];
  }
}