import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/recurring_transaction.dart';

class DatabaseHelper {
  static const _databaseName = "budget_tracker.db";
  static const _databaseVersion = 1;

  // Table names
  static const transactionsTable = 'transactions';
  static const categoriesTable = 'categories';
  static const accountsTable = 'accounts';
  static const budgetsTable = 'budgets';
  static const savingsGoalsTable = 'savings_goals';
  static const recurringTransactionsTable = 'recurring_transactions';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create transactions table
    await db.execute('''
      CREATE TABLE $transactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        date INTEGER NOT NULL,
        category TEXT NOT NULL,
        account TEXT NOT NULL,
        notes TEXT,
        receiptImagePath TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE $categoriesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL,
        type TEXT NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create accounts table
    await db.execute('''
      CREATE TABLE $accountsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        initialBalance REAL NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE $budgetsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        categoryName TEXT NOT NULL,
        amount REAL NOT NULL,
        period TEXT NOT NULL,
        startDate INTEGER NOT NULL,
        endDate INTEGER NOT NULL,
        isActive INTEGER NOT NULL,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create savings goals table
    await db.execute('''
      CREATE TABLE $savingsGoalsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        targetAmount REAL NOT NULL,
        currentAmount REAL NOT NULL DEFAULT 0,
        targetDate INTEGER NOT NULL,
        description TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Create recurring transactions table
    await db.execute('''
      CREATE TABLE $recurringTransactionsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        account TEXT NOT NULL,
        frequency TEXT NOT NULL,
        interval INTEGER NOT NULL DEFAULT 1,
        startDate INTEGER NOT NULL,
        endDate INTEGER,
        lastProcessed INTEGER,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database schema upgrades here
  }

  Future _insertDefaultData(Database db) async {
    // Insert default categories
    final defaultCategories = Category.getDefaultCategories();
    for (final category in defaultCategories) {
      await db.insert(categoriesTable, category.toMap());
    }

    // Insert default accounts
    final defaultAccounts = Account.getDefaultAccounts();
    for (final account in defaultAccounts) {
      await db.insert(accountsTable, account.toMap());
    }
  }

  // Transaction operations
  Future<int> insertTransaction(Transaction transaction) async {
    Database db = await database;
    return await db.insert(transactionsTable, transaction.toMap());
  }

  Future<List<Transaction>> getAllTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      transactionsTable,
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      transactionsTable,
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      transactionsTable,
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      transactionsTable,
      where: 'description LIKE ? OR category LIKE ? OR account LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => Transaction.fromMap(maps[i]));
  }

  Future<int> updateTransaction(Transaction transaction) async {
    Database db = await database;
    return await db.update(
      transactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    Database db = await database;
    return await db.delete(
      transactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Category operations
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert(categoriesTable, category.toMap());
  }

  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(categoriesTable);
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      categoriesTable,
      where: 'type = ? OR type = ?',
      whereArgs: [type, 'both'],
    );
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> updateCategory(Category category) async {
    Database db = await database;
    return await db.update(
      categoriesTable,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete(
      categoriesTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Account operations
  Future<int> insertAccount(Account account) async {
    Database db = await database;
    return await db.insert(accountsTable, account.toMap());
  }

  Future<List<Account>> getAllAccounts() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(accountsTable);
    return List.generate(maps.length, (i) => Account.fromMap(maps[i]));
  }

  Future<int> updateAccount(Account account) async {
    Database db = await database;
    return await db.update(
      accountsTable,
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<int> deleteAccount(int id) async {
    Database db = await database;
    return await db.delete(
      accountsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    Database db = await database;
    return await db.insert(budgetsTable, budget.toMap());
  }

  Future<List<Budget>> getAllBudgets() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(budgetsTable);
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<List<Budget>> getActiveBudgets() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      budgetsTable,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }

  Future<int> updateBudget(Budget budget) async {
    Database db = await database;
    return await db.update(
      budgetsTable,
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    Database db = await database;
    return await db.delete(
      budgetsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Savings goals operations
  Future<int> insertSavingsGoal(SavingsGoal goal) async {
    Database db = await database;
    return await db.insert(savingsGoalsTable, goal.toMap());
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(savingsGoalsTable);
    return List.generate(maps.length, (i) => SavingsGoal.fromMap(maps[i]));
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    Database db = await database;
    return await db.update(
      savingsGoalsTable,
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteSavingsGoal(int id) async {
    Database db = await database;
    return await db.delete(
      savingsGoalsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Recurring transactions operations
  Future<int> insertRecurringTransaction(RecurringTransaction transaction) async {
    Database db = await database;
    return await db.insert(recurringTransactionsTable, transaction.toMap());
  }

  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(recurringTransactionsTable);
    return List.generate(maps.length, (i) => RecurringTransaction.fromMap(maps[i]));
  }

  Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      recurringTransactionsTable,
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => RecurringTransaction.fromMap(maps[i]));
  }

  Future<int> updateRecurringTransaction(RecurringTransaction transaction) async {
    Database db = await database;
    return await db.update(
      recurringTransactionsTable,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteRecurringTransaction(int id) async {
    Database db = await database;
    return await db.delete(
      recurringTransactionsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Analytics and reports
  Future<double> getTotalBalance() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT 
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as total_income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as total_expense
      FROM $transactionsTable
    ''');
    
    if (result.isNotEmpty) {
      final totalIncome = result[0]['total_income'] as double? ?? 0.0;
      final totalExpense = result[0]['total_expense'] as double? ?? 0.0;
      return totalIncome - totalExpense;
    }
    return 0.0;
  }

  Future<double> getTotalIncome() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $transactionsTable WHERE type = 'income'
    ''');
    return result.isNotEmpty ? (result[0]['total'] as double? ?? 0.0) : 0.0;
  }

  Future<double> getTotalExpense() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM $transactionsTable WHERE type = 'expense'
    ''');
    return result.isNotEmpty ? (result[0]['total'] as double? ?? 0.0) : 0.0;
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total 
      FROM $transactionsTable 
      WHERE type = 'expense' 
      GROUP BY category
    ''');
    
    Map<String, double> expenses = {};
    for (var row in result) {
      expenses[row['category'] as String] = row['total'] as double;
    }
    return expenses;
  }

  Future<List<Map<String, dynamic>>> getMonthlyIncomeExpense() async {
    Database db = await database;
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', datetime(date/1000, 'unixepoch')) as month,
        SUM(CASE WHEN type = 'income' THEN amount ELSE 0 END) as income,
        SUM(CASE WHEN type = 'expense' THEN amount ELSE 0 END) as expense
      FROM $transactionsTable
      GROUP BY month
      ORDER BY month DESC
      LIMIT 12
    ''');
    
    return result;
  }

  // Utility methods
  Future<void> clearAllData() async {
    Database db = await database;
    await db.delete(transactionsTable);
    await db.delete(categoriesTable);
    await db.delete(accountsTable);
    await db.delete(budgetsTable);
    await db.delete(savingsGoalsTable);
    await db.delete(recurringTransactionsTable);
    await _insertDefaultData(db);
  }

  Future<void> close() async {
    Database db = await database;
    db.close();
  }
}