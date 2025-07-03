class Account {
  final int? id;
  final String name;
  final String icon;
  final int color;
  final double balance;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Account({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.balance,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color']?.toInt() ?? 0,
      balance: map['balance']?.toDouble() ?? 0.0,
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
      'balance': balance,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Account copyWith({
    int? id,
    String? name,
    String? icon,
    int? color,
    double? balance,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      balance: balance ?? this.balance,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, name: $name, icon: $icon, color: $color, balance: $balance, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.name == name &&
        other.icon == icon &&
        other.color == color &&
        other.balance == balance &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        icon.hashCode ^
        color.hashCode ^
        balance.hashCode ^
        isDefault.hashCode;
  }
}