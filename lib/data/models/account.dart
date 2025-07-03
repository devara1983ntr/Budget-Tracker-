class Account {
  final int? id;
  final String name;
  final double initialBalance;
  final DateTime createdAt;
  final DateTime updatedAt;

  Account({
    this.id,
    required this.name,
    required this.initialBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initialBalance': initialBalance,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      initialBalance: map['initialBalance']?.toDouble() ?? 0.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Account copyWith({
    int? id,
    String? name,
    double? initialBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, name: $name, initialBalance: $initialBalance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.name == name &&
        other.initialBalance == initialBalance;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ initialBalance.hashCode;
  }

  // Default accounts
  static List<Account> getDefaultAccounts() {
    return [
      Account(name: 'Cash', initialBalance: 0.0),
      Account(name: 'Checking Account', initialBalance: 0.0),
      Account(name: 'Savings Account', initialBalance: 0.0),
      Account(name: 'Credit Card', initialBalance: 0.0),
    ];
  }
}