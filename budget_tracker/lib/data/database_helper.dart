import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../utils/app_constants.dart';
import 'models/transaction.dart' as transaction_model;
import 'models/category.dart' as category_model;
import 'models/account.dart' as account_model;
import 'models/budget.dart' as budget_model;
import 'models/savings_goal.dart' as savings_goal_model;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        type TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE accounts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        balance REAL DEFAULT 0.0,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        receipt_image_path TEXT,
        note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        amount REAL NOT NULL,
        spent REAL DEFAULT 0.0,
        category_id INTEGER,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        period TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    // Create savings_goals table
    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0.0,
        target_date TEXT NOT NULL,
        icon TEXT NOT NULL,
        color INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create recurring_transactions table
    await db.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        type TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        frequency TEXT NOT NULL,
        next_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  Future<void> _insertDefaultData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Insert default categories
    for (final categoryData in AppConstants.defaultCategories) {
      await db.insert('categories', {
        'name': categoryData['name'],
        'icon': categoryData['icon'],
        'color': categoryData['color'],
        'type': categoryData['type'],
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }

    // Insert default accounts
    for (final accountData in AppConstants.defaultAccounts) {
      await db.insert('accounts', {
        'name': accountData['name'],
        'icon': accountData['icon'],
        'color': accountData['color'],
        'balance': accountData['balance'],
        'is_default': 1,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  // Transaction operations
  Future<int> insertTransaction(transaction_model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<transaction_model.Transaction>> getTransactions({
    int? limit,
    int? offset,
    String? type,
    int? categoryId,
    int? accountId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (type != null) {
      whereClause += 'type = ?';
      whereArgs.add(type);
    }

    if (categoryId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'category_id = ?';
      whereArgs.add(categoryId);
    }

    if (accountId != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'account_id = ?';
      whereArgs.add(accountId);
    }

    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'transactions',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC, created_at DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) => transaction_model.Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(transaction_model.Transaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<int> insertCategory(category_model.Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
  }

  Future<List<category_model.Category>> getCategories({String? type}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: type != null ? 'type = ?' : null,
      whereArgs: type != null ? [type] : null,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => category_model.Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(category_model.Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  // Account operations
  Future<int> insertAccount(account_model.Account account) async {
    final db = await database;
    return await db.insert('accounts', account.toMap());
  }

  Future<List<account_model.Account>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'accounts',
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => account_model.Account.fromMap(maps[i]));
  }

  Future<int> updateAccount(account_model.Account account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    final db = await database;
    return await db.delete(
      'accounts',
      where: 'id = ? AND is_default = 0',
      whereArgs: [id],
    );
  }

  // Budget operations
  Future<int> insertBudget(budget_model.Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<budget_model.Budget>> getBudgets({bool? isActive}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: isActive != null ? 'is_active = ?' : null,
      whereArgs: isActive != null ? [isActive ? 1 : 0] : null,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => budget_model.Budget.fromMap(maps[i]));
  }

  Future<int> updateBudget(budget_model.Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Savings Goal operations
  Future<int> insertSavingsGoal(savings_goal_model.SavingsGoal goal) async {
    final db = await database;
    return await db.insert('savings_goals', goal.toMap());
  }

  Future<List<savings_goal_model.SavingsGoal>> getSavingsGoals({bool? isCompleted}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'savings_goals',
      where: isCompleted != null ? 'is_completed = ?' : null,
      whereArgs: isCompleted != null ? [isCompleted ? 1 : 0] : null,
      orderBy: 'target_date ASC',
    );
    return List.generate(maps.length, (i) => savings_goal_model.SavingsGoal.fromMap(maps[i]));
  }

  Future<int> updateSavingsGoal(savings_goal_model.SavingsGoal goal) async {
    final db = await database;
    return await db.update(
      'savings_goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    final db = await database;
    return await db.delete(
      'savings_goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics methods
  Future<Map<String, double>> getMonthlyTotals(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);

    final result = await db.rawQuery('''
      SELECT type, SUM(amount) as total
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY type
    ''', [startOfMonth.toIso8601String(), endOfMonth.toIso8601String()]);

    final totals = {'income': 0.0, 'expense': 0.0};
    for (final row in result) {
      totals[row['type'] as String] = row['total'] as double;
    }
    return totals;
  }

  Future<List<Map<String, dynamic>>> getCategoryExpenses(DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    final result = await db.rawQuery('''
      SELECT c.name, c.color, SUM(t.amount) as total
      FROM transactions t
      JOIN categories c ON t.category_id = c.id
      WHERE t.type = 'expense' AND t.date >= ? AND t.date <= ?
      GROUP BY c.id, c.name, c.color
      ORDER BY total DESC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrends(int months) async {
    final db = await database;
    final endDate = DateTime.now();
    final startDate = DateTime(endDate.year, endDate.month - months, 1);

    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        type,
        SUM(amount) as total
      FROM transactions
      WHERE date >= ? AND date <= ?
      GROUP BY strftime('%Y-%m', date), type
      ORDER BY month ASC
    ''', [startDate.toIso8601String(), endDate.toIso8601String()]);

    return result;
  }

  Future<double> getTotalBalance() async {
    final db = await database;
    final result = await db.rawQuery('SELECT SUM(balance) as total FROM accounts');
    return result.first['total'] as double? ?? 0.0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}