import 'package:flutter/material.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  
  List<Budget> _budgets = [];
  Map<String, double> _budgetSpent = {};
  bool _isLoading = false;
  String? _error;
  
  BudgetProvider(this._repository) {
    loadBudgets();
  }
  
  // Getters
  List<Budget> get budgets => _budgets;
  List<Budget> get activeBudgets => _budgets.where((b) => b.isActive).toList();
  Map<String, double> get budgetSpent => _budgetSpent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Methods
  Future<void> loadBudgets() async {
    _setLoading(true);
    _clearError();
    
    try {
      _budgets = await _repository.getAllBudgets();
      await _loadBudgetSpent();
    } catch (e) {
      _setError('Failed to load budgets: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadBudgetSpent() async {
    for (final budget in _budgets) {
      if (budget.isActive) {
        try {
          final spent = await _repository.getBudgetSpent(
            budget.categoryName,
            budget.startDate,
            budget.endDate,
          );
          _budgetSpent[budget.categoryName] = spent;
        } catch (e) {
          _budgetSpent[budget.categoryName] = 0.0;
        }
      }
    }
    notifyListeners();
  }
  
  Future<bool> addBudget(Budget budget) async {
    try {
      final id = await _repository.addBudget(budget);
      if (id > 0) {
        await loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add budget: $e');
      return false;
    }
  }
  
  Future<bool> updateBudget(Budget budget) async {
    try {
      final result = await _repository.updateBudget(budget);
      if (result > 0) {
        await loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update budget: $e');
      return false;
    }
  }
  
  Future<bool> deleteBudget(int id) async {
    try {
      final result = await _repository.deleteBudget(id);
      if (result > 0) {
        await loadBudgets();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete budget: $e');
      return false;
    }
  }
  
  Budget? getBudgetById(int id) {
    try {
      return _budgets.firstWhere((budget) => budget.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Budget? getBudgetByCategory(String categoryName) {
    try {
      return _budgets.firstWhere((budget) => budget.categoryName == categoryName && budget.isActive);
    } catch (e) {
      return null;
    }
  }
  
  double getBudgetSpent(String categoryName) {
    return _budgetSpent[categoryName] ?? 0.0;
  }
  
  double getBudgetProgress(String categoryName) {
    final budget = getBudgetByCategory(categoryName);
    if (budget == null) return 0.0;
    
    final spent = getBudgetSpent(categoryName);
    return budget.amount > 0 ? (spent / budget.amount).clamp(0.0, 1.0) : 0.0;
  }
  
  bool isBudgetExceeded(String categoryName) {
    final budget = getBudgetByCategory(categoryName);
    if (budget == null) return false;
    
    final spent = getBudgetSpent(categoryName);
    return spent > budget.amount;
  }
  
  double getBudgetRemaining(String categoryName) {
    final budget = getBudgetByCategory(categoryName);
    if (budget == null) return 0.0;
    
    final spent = getBudgetSpent(categoryName);
    return (budget.amount - spent).clamp(0.0, double.infinity);
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
    await loadBudgets();
  }
}