import '../local/database_helper.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../models/budget.dart';
import '../models/savings_goal.dart';
import '../models/recurring_transaction.dart';

class BudgetRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Transaction operations
  Future<int> addTransaction(Transaction transaction) async {
    return await _databaseHelper.insertTransaction(transaction);
  }

  Future<List<Transaction>> getAllTransactions() async {
    return await _databaseHelper.getAllTransactions();
  }

  Future<List<Transaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    return await _databaseHelper.getTransactionsByDateRange(startDate, endDate);
  }

  Future<List<Transaction>> getTransactionsByType(String type) async {
    return await _databaseHelper.getTransactionsByType(type);
  }

  Future<List<Transaction>> searchTransactions(String query) async {
    return await _databaseHelper.searchTransactions(query);
  }

  Future<int> updateTransaction(Transaction transaction) async {
    return await _databaseHelper.updateTransaction(transaction);
  }

  Future<int> deleteTransaction(int id) async {
    return await _databaseHelper.deleteTransaction(id);
  }

  // Category operations
  Future<int> addCategory(Category category) async {
    return await _databaseHelper.insertCategory(category);
  }

  Future<List<Category>> getAllCategories() async {
    return await _databaseHelper.getAllCategories();
  }

  Future<List<Category>> getCategoriesByType(String type) async {
    return await _databaseHelper.getCategoriesByType(type);
  }

  Future<int> updateCategory(Category category) async {
    return await _databaseHelper.updateCategory(category);
  }

  Future<int> deleteCategory(int id) async {
    return await _databaseHelper.deleteCategory(id);
  }

  // Account operations
  Future<int> addAccount(Account account) async {
    return await _databaseHelper.insertAccount(account);
  }

  Future<List<Account>> getAllAccounts() async {
    return await _databaseHelper.getAllAccounts();
  }

  Future<int> updateAccount(Account account) async {
    return await _databaseHelper.updateAccount(account);
  }

  Future<int> deleteAccount(int id) async {
    return await _databaseHelper.deleteAccount(id);
  }

  Future<double> getAccountBalance(String accountName) async {
    final transactions = await _databaseHelper.getAllTransactions();
    final accountTransactions = transactions.where((t) => t.account == accountName).toList();
    
    double balance = 0.0;
    final account = (await getAllAccounts()).firstWhere(
      (a) => a.name == accountName,
      orElse: () => Account(name: accountName, initialBalance: 0.0),
    );
    
    balance += account.initialBalance;
    
    for (final transaction in accountTransactions) {
      if (transaction.type == 'income') {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    
    return balance;
  }

  // Budget operations
  Future<int> addBudget(Budget budget) async {
    return await _databaseHelper.insertBudget(budget);
  }

  Future<List<Budget>> getAllBudgets() async {
    return await _databaseHelper.getAllBudgets();
  }

  Future<List<Budget>> getActiveBudgets() async {
    return await _databaseHelper.getActiveBudgets();
  }

  Future<int> updateBudget(Budget budget) async {
    return await _databaseHelper.updateBudget(budget);
  }

  Future<int> deleteBudget(int id) async {
    return await _databaseHelper.deleteBudget(id);
  }

  Future<double> getBudgetSpent(String categoryName, DateTime startDate, DateTime endDate) async {
    final transactions = await getTransactionsByDateRange(startDate, endDate);
    final categoryTransactions = transactions.where(
      (t) => t.category == categoryName && t.type == 'expense',
    ).toList();
    
    return categoryTransactions.fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  // Savings goals operations
  Future<int> addSavingsGoal(SavingsGoal goal) async {
    return await _databaseHelper.insertSavingsGoal(goal);
  }

  Future<List<SavingsGoal>> getAllSavingsGoals() async {
    return await _databaseHelper.getAllSavingsGoals();
  }

  Future<int> updateSavingsGoal(SavingsGoal goal) async {
    return await _databaseHelper.updateSavingsGoal(goal);
  }

  Future<int> deleteSavingsGoal(int id) async {
    return await _databaseHelper.deleteSavingsGoal(id);
  }

  // Recurring transactions operations
  Future<int> addRecurringTransaction(RecurringTransaction transaction) async {
    return await _databaseHelper.insertRecurringTransaction(transaction);
  }

  Future<List<RecurringTransaction>> getAllRecurringTransactions() async {
    return await _databaseHelper.getAllRecurringTransactions();
  }

  Future<List<RecurringTransaction>> getActiveRecurringTransactions() async {
    return await _databaseHelper.getActiveRecurringTransactions();
  }

  Future<int> updateRecurringTransaction(RecurringTransaction transaction) async {
    return await _databaseHelper.updateRecurringTransaction(transaction);
  }

  Future<int> deleteRecurringTransaction(int id) async {
    return await _databaseHelper.deleteRecurringTransaction(id);
  }

  Future<List<RecurringTransaction>> getDueRecurringTransactions() async {
    final activeTransactions = await getActiveRecurringTransactions();
    return activeTransactions.where((t) => t.isDue()).toList();
  }

  Future<void> processRecurringTransaction(RecurringTransaction recurringTransaction) async {
    // Create a new transaction from the recurring transaction
    final transaction = Transaction(
      description: recurringTransaction.description,
      amount: recurringTransaction.amount,
      type: recurringTransaction.type,
      date: DateTime.now(),
      category: recurringTransaction.category,
      account: recurringTransaction.account,
      notes: 'Auto-generated from recurring transaction',
    );

    // Add the transaction
    await addTransaction(transaction);

    // Update the recurring transaction's last processed date
    final updatedRecurring = recurringTransaction.copyWith(
      lastProcessed: DateTime.now(),
    );
    await updateRecurringTransaction(updatedRecurring);
  }

  // Analytics operations
  Future<double> getTotalBalance() async {
    return await _databaseHelper.getTotalBalance();
  }

  Future<double> getTotalIncome() async {
    return await _databaseHelper.getTotalIncome();
  }

  Future<double> getTotalExpense() async {
    return await _databaseHelper.getTotalExpense();
  }

  Future<Map<String, double>> getExpensesByCategory() async {
    return await _databaseHelper.getExpensesByCategory();
  }

  Future<List<Map<String, dynamic>>> getMonthlyIncomeExpense() async {
    return await _databaseHelper.getMonthlyIncomeExpense();
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 10}) async {
    final allTransactions = await getAllTransactions();
    return allTransactions.take(limit).toList();
  }

  // Data export operations
  Future<String> exportToCsv() async {
    final transactions = await getAllTransactions();
    
    String csv = 'Date,Description,Category,Account,Type,Amount,Notes\n';
    
    for (final transaction in transactions) {
      final dateStr = transaction.date.toIso8601String().split('T')[0];
      final notes = transaction.notes?.replaceAll(',', ';') ?? '';
      csv += '$dateStr,"${transaction.description}","${transaction.category}","${transaction.account}","${transaction.type}",${transaction.amount},"$notes"\n';
    }
    
    return csv;
  }

  // Utility operations
  Future<void> clearAllData() async {
    await _databaseHelper.clearAllData();
  }

  Future<List<Transaction>> getTransactionsForCurrentMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return await getTransactionsByDateRange(startOfMonth, endOfMonth);
  }

  Future<Map<String, double>> getCurrentMonthSummary() async {
    final transactions = await getTransactionsForCurrentMonth();
    
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else {
        totalExpense += transaction.amount;
      }
    }
    
    return {
      'income': totalIncome,
      'expense': totalExpense,
      'balance': totalIncome - totalExpense,
    };
  }
}