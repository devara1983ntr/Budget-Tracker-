class Category {
  final int? id;
  final String name;
  final String icon;
  final int color;
  final String type; // 'income' or 'expense'
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color']?.toInt() ?? 0,
      type: map['type'] ?? '',
      isDefault: map['is_default'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    String? type,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, color: $color, type: $type, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.type == type &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        type.hashCode ^
        isDefault.hashCode;
  }
}