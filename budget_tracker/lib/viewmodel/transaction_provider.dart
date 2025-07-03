import 'package:flutter/foundation.dart';
import '../data/database_helper.dart';
import '../data/models/transaction.dart' as transaction_model;
import '../data/models/category.dart' as category_model;
import '../data/models/account.dart' as account_model;
import '../services/image_service.dart';
import '../utils/formatters.dart';

class TransactionProvider extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ImageService _imageService = ImageService();

  List<transaction_model.Transaction> _transactions = [];
  List<category_model.Category> _categories = [];
  List<account_model.Account> _accounts = [];
  bool _isLoading = false;
  String? _error;
  
  // Filters
  String? _selectedType;
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  // Pagination
  int _currentPage = 0;
  static const int _pageSize = 20;
  bool _hasMoreData = true;

  // Getters
  List<transaction_model.Transaction> get transactions => _transactions;
  List<category_model.Category> get categories => _categories;
  List<account_model.Account> get accounts => _accounts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMoreData => _hasMoreData;

  String? get selectedType => _selectedType;
  int? get selectedCategoryId => _selectedCategoryId;
  int? get selectedAccountId => _selectedAccountId;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  String get searchQuery => _searchQuery;

  // Computed properties
  List<transaction_model.Transaction> get filteredTransactions {
    var filtered = _transactions.where((transaction) {
      if (_searchQuery.isNotEmpty) {
        return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.note?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      }
      return true;
    }).toList();

    return filtered;
  }

  double get totalIncome {
    return filteredTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return filteredTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get netBalance => totalIncome - totalExpense;

  // Initialize data
  Future<void> initialize() async {
    await loadCategories();
    await loadAccounts();
    await loadTransactions();
  }

  // Load transactions with pagination and filters
  Future<void> loadTransactions({bool refresh = false}) async {
    if (_isLoading && !refresh) return;

    if (refresh) {
      _currentPage = 0;
      _hasMoreData = true;
      _transactions.clear();
    }

    _setLoading(true);
    _setError(null);

    try {
      final transactions = await _databaseHelper.getTransactions(
        limit: _pageSize,
        offset: _currentPage * _pageSize,
        type: _selectedType,
        categoryId: _selectedCategoryId,
        accountId: _selectedAccountId,
        startDate: _startDate,
        endDate: _endDate,
      );

      if (refresh) {
        _transactions = transactions;
      } else {
        _transactions.addAll(transactions);
      }

      _hasMoreData = transactions.length == _pageSize;
      _currentPage++;
    } catch (e) {
      _setError('Failed to load transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _databaseHelper.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load categories: $e');
    }
  }

  // Load accounts
  Future<void> loadAccounts() async {
    try {
      _accounts = await _databaseHelper.getAccounts();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load accounts: $e');
    }
  }

  // Add transaction
  Future<bool> addTransaction({
    required double amount,
    required String description,
    required String type,
    required int categoryId,
    required int accountId,
    required DateTime date,
    String? receiptImagePath,
    String? note,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final now = DateTime.now();
      final transaction = transaction_model.Transaction(
        amount: amount,
        description: description,
        type: type,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        receiptImagePath: receiptImagePath,
        note: note,
        createdAt: now,
        updatedAt: now,
      );

      await _databaseHelper.insertTransaction(transaction);
      await _updateAccountBalance(accountId, amount, type);
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update transaction
  Future<bool> updateTransaction({
    required int id,
    required double amount,
    required String description,
    required String type,
    required int categoryId,
    required int accountId,
    required DateTime date,
    String? receiptImagePath,
    String? note,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final existingTransaction = _transactions.firstWhere((t) => t.id == id);
      
      // Revert old transaction from account balance
      await _updateAccountBalance(
        existingTransaction.accountId, 
        existingTransaction.amount, 
        existingTransaction.type == 'income' ? 'expense' : 'income'
      );

      final transaction = existingTransaction.copyWith(
        amount: amount,
        description: description,
        type: type,
        categoryId: categoryId,
        accountId: accountId,
        date: date,
        receiptImagePath: receiptImagePath,
        note: note,
        updatedAt: DateTime.now(),
      );

      await _databaseHelper.updateTransaction(transaction);
      await _updateAccountBalance(accountId, amount, type);
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete transaction
  Future<bool> deleteTransaction(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      final transaction = _transactions.firstWhere((t) => t.id == id);
      
      // Remove transaction amount from account balance
      await _updateAccountBalance(
        transaction.accountId, 
        transaction.amount, 
        transaction.type == 'income' ? 'expense' : 'income'
      );

      // Delete receipt image if exists
      if (transaction.receiptImagePath != null) {
        await _imageService.deleteImage(transaction.receiptImagePath!);
      }

      await _databaseHelper.deleteTransaction(id);
      await loadTransactions(refresh: true);
      return true;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update account balance
  Future<void> _updateAccountBalance(int accountId, double amount, String type) async {
    final accountIndex = _accounts.indexWhere((a) => a.id == accountId);
    if (accountIndex != -1) {
      final account = _accounts[accountIndex];
      final newBalance = type == 'income' 
          ? account.balance + amount 
          : account.balance - amount;
      
      final updatedAccount = account.copyWith(
        balance: newBalance,
        updatedAt: DateTime.now(),
      );
      
      await _databaseHelper.updateAccount(updatedAccount);
      _accounts[accountIndex] = updatedAccount;
      notifyListeners();
    }
  }

  // Filters
  void setTypeFilter(String? type) {
    _selectedType = type;
    loadTransactions(refresh: true);
  }

  void setCategoryFilter(int? categoryId) {
    _selectedCategoryId = categoryId;
    loadTransactions(refresh: true);
  }

  void setAccountFilter(int? accountId) {
    _selectedAccountId = accountId;
    loadTransactions(refresh: true);
  }

  void setDateRange(DateTime? startDate, DateTime? endDate) {
    _startDate = startDate;
    _endDate = endDate;
    loadTransactions(refresh: true);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedType = null;
    _selectedCategoryId = null;
    _selectedAccountId = null;
    _startDate = null;
    _endDate = null;
    _searchQuery = '';
    loadTransactions(refresh: true);
  }

  // Image handling
  Future<String?> addReceiptImage() async {
    try {
      // This will be implemented in the UI layer to show picker dialog
      return null;
    } catch (e) {
      _setError('Failed to add image: $e');
      return null;
    }
  }

  // Analytics
  Future<Map<String, double>> getMonthlyTotals(DateTime month) async {
    try {
      return await _databaseHelper.getMonthlyTotals(month);
    } catch (e) {
      _setError('Failed to get monthly totals: $e');
      return {'income': 0.0, 'expense': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getCategoryExpenses(DateTime startDate, DateTime endDate) async {
    try {
      return await _databaseHelper.getCategoryExpenses(startDate, endDate);
    } catch (e) {
      _setError('Failed to get category expenses: $e');
      return [];
    }
  }

  // Export data
  Future<String?> exportToCsv() async {
    try {
      final csvData = _generateCsvData();
      // CSV export implementation would go here
      return csvData;
    } catch (e) {
      _setError('Failed to export data: $e');
      return null;
    }
  }

  String _generateCsvData() {
    final buffer = StringBuffer();
    buffer.writeln('Date,Description,Category,Account,Type,Amount,Note');
    
    for (final transaction in _transactions) {
      final category = _categories.firstWhere((c) => c.id == transaction.categoryId);
      final account = _accounts.firstWhere((a) => a.id == transaction.accountId);
      
      buffer.writeln([
        DateFormatter.formatDate(transaction.date),
        '"${transaction.description}"',
        '"${category.name}"',
        '"${account.name}"',
        transaction.type,
        transaction.amount,
        '"${transaction.note ?? ''}"',
      ].join(','));
    }
    
    return buffer.toString();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  category_model.Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  account_model.Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<category_model.Category> getCategoriesByType(String type) {
    return _categories.where((c) => c.type == type).toList();
  }

  // Load more data for pagination
  Future<void> loadMore() async {
    if (!_hasMoreData || _isLoading) return;
    await loadTransactions();
  }
}