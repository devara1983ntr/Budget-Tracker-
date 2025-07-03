import 'package:flutter/material.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/transaction.dart';
import '../utils/date_formatter.dart';

class TransactionProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  
  List<Transaction> _transactions = [];
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedType = 'all'; // 'all', 'income', 'expense'
  String _selectedPeriod = 'all'; // 'all', 'today', 'this_week', 'this_month', etc.
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  // Dashboard summary data
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _currentMonthSummary = {};
  
  TransactionProvider(this._repository) {
    loadTransactions();
    loadSummaryData();
  }
  
  // Getters
  List<Transaction> get transactions => _transactions;
  List<Transaction> get filteredTransactions => _filteredTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedType => _selectedType;
  String get selectedPeriod => _selectedPeriod;
  DateTime? get customStartDate => _customStartDate;
  DateTime? get customEndDate => _customEndDate;
  
  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  Map<String, double> get currentMonthSummary => _currentMonthSummary;
  
  List<Transaction> get recentTransactions {
    return _transactions.take(10).toList();
  }
  
  List<Transaction> get todayTransactions {
    final today = DateTime.now();
    return _transactions.where((transaction) {
      return DateFormatter.isSameDay(transaction.date, today);
    }).toList();
  }
  
  List<Transaction> get thisWeekTransactions {
    final now = DateTime.now();
    final startOfWeek = DateFormatter.startOfWeek(now);
    final endOfWeek = DateFormatter.endOfWeek(now);
    
    return _transactions.where((transaction) {
      return transaction.date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             transaction.date.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
  }
  
  List<Transaction> get thisMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((transaction) {
      return DateFormatter.isSameMonth(transaction.date, now);
    }).toList();
  }
  
  // Methods
  Future<void> loadTransactions() async {
    _setLoading(true);
    _clearError();
    
    try {
      _transactions = await _repository.getAllTransactions();
      _applyFilters();
    } catch (e) {
      _setError('Failed to load transactions: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadSummaryData() async {
    try {
      _totalBalance = await _repository.getTotalBalance();
      _totalIncome = await _repository.getTotalIncome();
      _totalExpense = await _repository.getTotalExpense();
      _currentMonthSummary = await _repository.getCurrentMonthSummary();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load summary data: $e');
    }
  }
  
  Future<bool> addTransaction(Transaction transaction) async {
    try {
      final id = await _repository.addTransaction(transaction);
      if (id > 0) {
        await loadTransactions();
        await loadSummaryData();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add transaction: $e');
      return false;
    }
  }
  
  Future<bool> updateTransaction(Transaction transaction) async {
    try {
      final result = await _repository.updateTransaction(transaction);
      if (result > 0) {
        await loadTransactions();
        await loadSummaryData();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update transaction: $e');
      return false;
    }
  }
  
  Future<bool> deleteTransaction(int id) async {
    try {
      final result = await _repository.deleteTransaction(id);
      if (result > 0) {
        await loadTransactions();
        await loadSummaryData();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete transaction: $e');
      return false;
    }
  }
  
  Transaction? getTransactionById(int id) {
    try {
      return _transactions.firstWhere((transaction) => transaction.id == id);
    } catch (e) {
      return null;
    }
  }
  
  void searchTransactions(String query) {
    _searchQuery = query;
    _applyFilters();
  }
  
  void filterByType(String type) {
    _selectedType = type;
    _applyFilters();
  }
  
  void filterByPeriod(String period, {DateTime? customStart, DateTime? customEnd}) {
    _selectedPeriod = period;
    _customStartDate = customStart;
    _customEndDate = customEnd;
    _applyFilters();
  }
  
  void clearFilters() {
    _searchQuery = '';
    _selectedType = 'all';
    _selectedPeriod = 'all';
    _customStartDate = null;
    _customEndDate = null;
    _applyFilters();
  }
  
  void _applyFilters() {
    List<Transaction> filtered = List.from(_transactions);
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               transaction.account.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (transaction.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    // Apply type filter
    if (_selectedType != 'all') {
      filtered = filtered.where((transaction) => transaction.type == _selectedType).toList();
    }
    
    // Apply period filter
    if (_selectedPeriod != 'all') {
      final dateRange = DateFormatter.getDateRange(_selectedPeriod, _customStartDate, _customEndDate);
      final startDate = dateRange[0];
      final endDate = dateRange[1];
      
      filtered = filtered.where((transaction) {
        return transaction.date.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               transaction.date.isBefore(endDate.add(const Duration(seconds: 1)));
      }).toList();
    }
    
    _filteredTransactions = filtered;
    notifyListeners();
  }
  
  Future<String> exportToCsv() async {
    try {
      return await _repository.exportToCsv();
    } catch (e) {
      _setError('Failed to export data: $e');
      return '';
    }
  }
  
  // Category analytics
  Map<String, double> getExpensesByCategory({String period = 'this_month'}) {
    List<Transaction> transactions;
    
    switch (period) {
      case 'today':
        transactions = todayTransactions;
        break;
      case 'this_week':
        transactions = thisWeekTransactions;
        break;
      case 'this_month':
        transactions = thisMonthTransactions;
        break;
      default:
        transactions = _transactions;
    }
    
    final expenses = <String, double>{};
    
    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        expenses[transaction.category] = (expenses[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return expenses;
  }
  
  Map<String, double> getIncomeByCategory({String period = 'this_month'}) {
    List<Transaction> transactions;
    
    switch (period) {
      case 'today':
        transactions = todayTransactions;
        break;
      case 'this_week':
        transactions = thisWeekTransactions;
        break;
      case 'this_month':
        transactions = thisMonthTransactions;
        break;
      default:
        transactions = _transactions;
    }
    
    final income = <String, double>{};
    
    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        income[transaction.category] = (income[transaction.category] ?? 0) + transaction.amount;
      }
    }
    
    return income;
  }
  
  List<Map<String, dynamic>> getMonthlyTrends() {
    final monthlyData = <String, Map<String, double>>{};
    
    for (final transaction in _transactions) {
      final monthKey = DateFormatter.formatMonthYear(transaction.date);
      
      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
      }
      
      if (transaction.type == 'income') {
        monthlyData[monthKey]!['income'] = monthlyData[monthKey]!['income']! + transaction.amount;
      } else {
        monthlyData[monthKey]!['expense'] = monthlyData[monthKey]!['expense']! + transaction.amount;
      }
    }
    
    return monthlyData.entries.map((entry) {
      return {
        'month': entry.key,
        'income': entry.value['income'],
        'expense': entry.value['expense'],
        'balance': entry.value['income']! - entry.value['expense']!,
      };
    }).toList()..sort((a, b) => b['month'].compareTo(a['month']));
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearError() {
    _clearError();
  }
  
  Future<void> refresh() async {
    await loadTransactions();
    await loadSummaryData();
  }
}