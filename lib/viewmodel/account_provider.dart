import 'package:flutter/material.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/account.dart';

class AccountProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  
  List<Account> _accounts = [];
  Map<String, double> _accountBalances = {};
  bool _isLoading = false;
  String? _error;
  
  AccountProvider(this._repository) {
    loadAccounts();
  }
  
  // Getters
  List<Account> get accounts => _accounts;
  Map<String, double> get accountBalances => _accountBalances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadAccounts() async {
    _setLoading(true);
    _clearError();
    
    try {
      _accounts = await _repository.getAllAccounts();
      await _loadAccountBalances();
    } catch (e) {
      _setError('Failed to load accounts: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadAccountBalances() async {
    for (final account in _accounts) {
      try {
        final balance = await _repository.getAccountBalance(account.name);
        _accountBalances[account.name] = balance;
      } catch (e) {
        _accountBalances[account.name] = account.initialBalance;
      }
    }
    notifyListeners();
  }
  
  Future<bool> addAccount(Account account) async {
    try {
      final id = await _repository.addAccount(account);
      if (id > 0) {
        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add account: $e');
      return false;
    }
  }
  
  Future<bool> updateAccount(Account account) async {
    try {
      final result = await _repository.updateAccount(account);
      if (result > 0) {
        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update account: $e');
      return false;
    }
  }
  
  Future<bool> deleteAccount(int id) async {
    try {
      final result = await _repository.deleteAccount(id);
      if (result > 0) {
        await loadAccounts();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete account: $e');
      return false;
    }
  }
  
  Account? getAccountById(int id) {
    try {
      return _accounts.firstWhere((account) => account.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Account? getAccountByName(String name) {
    try {
      return _accounts.firstWhere((account) => account.name == name);
    } catch (e) {
      return null;
    }
  }
  
  double getAccountBalance(String accountName) {
    return _accountBalances[accountName] ?? 0.0;
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
    await loadAccounts();
  }
}