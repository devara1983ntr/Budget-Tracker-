import 'package:flutter/material.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/savings_goal.dart';

class SavingsGoalProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  
  List<SavingsGoal> _savingsGoals = [];
  bool _isLoading = false;
  String? _error;
  
  SavingsGoalProvider(this._repository) {
    loadSavingsGoals();
  }
  
  // Getters
  List<SavingsGoal> get savingsGoals => _savingsGoals;
  List<SavingsGoal> get activeSavingsGoals => _savingsGoals.where((g) => !g.isCompleted).toList();
  List<SavingsGoal> get completedSavingsGoals => _savingsGoals.where((g) => g.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  double get totalTargetAmount {
    return _savingsGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
  }
  
  double get totalCurrentAmount {
    return _savingsGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
  }
  
  double get totalProgress {
    if (totalTargetAmount == 0) return 0.0;
    return (totalCurrentAmount / totalTargetAmount).clamp(0.0, 1.0);
  }
  
  // Methods
  Future<void> loadSavingsGoals() async {
    _setLoading(true);
    _clearError();
    
    try {
      _savingsGoals = await _repository.getAllSavingsGoals();
    } catch (e) {
      _setError('Failed to load savings goals: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> addSavingsGoal(SavingsGoal goal) async {
    try {
      final id = await _repository.addSavingsGoal(goal);
      if (id > 0) {
        await loadSavingsGoals();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add savings goal: $e');
      return false;
    }
  }
  
  Future<bool> updateSavingsGoal(SavingsGoal goal) async {
    try {
      final result = await _repository.updateSavingsGoal(goal);
      if (result > 0) {
        await loadSavingsGoals();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update savings goal: $e');
      return false;
    }
  }
  
  Future<bool> deleteSavingsGoal(int id) async {
    try {
      final result = await _repository.deleteSavingsGoal(id);
      if (result > 0) {
        await loadSavingsGoals();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete savings goal: $e');
      return false;
    }
  }
  
  Future<bool> addToSavingsGoal(int goalId, double amount) async {
    final goal = getSavingsGoalById(goalId);
    if (goal == null) return false;
    
    final newCurrentAmount = goal.currentAmount + amount;
    final isCompleted = newCurrentAmount >= goal.targetAmount;
    
    final updatedGoal = goal.copyWith(
      currentAmount: newCurrentAmount,
      isCompleted: isCompleted,
    );
    
    return await updateSavingsGoal(updatedGoal);
  }
  
  Future<bool> withdrawFromSavingsGoal(int goalId, double amount) async {
    final goal = getSavingsGoalById(goalId);
    if (goal == null) return false;
    
    final newCurrentAmount = (goal.currentAmount - amount).clamp(0.0, goal.targetAmount);
    final isCompleted = newCurrentAmount >= goal.targetAmount;
    
    final updatedGoal = goal.copyWith(
      currentAmount: newCurrentAmount,
      isCompleted: isCompleted,
    );
    
    return await updateSavingsGoal(updatedGoal);
  }
  
  Future<bool> markAsCompleted(int goalId) async {
    final goal = getSavingsGoalById(goalId);
    if (goal == null) return false;
    
    final updatedGoal = goal.copyWith(
      currentAmount: goal.targetAmount,
      isCompleted: true,
    );
    
    return await updateSavingsGoal(updatedGoal);
  }
  
  SavingsGoal? getSavingsGoalById(int id) {
    try {
      return _savingsGoals.firstWhere((goal) => goal.id == id);
    } catch (e) {
      return null;
    }
  }
  
  SavingsGoal? getSavingsGoalByName(String name) {
    try {
      return _savingsGoals.firstWhere((goal) => goal.name == name);
    } catch (e) {
      return null;
    }
  }
  
  List<SavingsGoal> getGoalsDueSoon({int daysAhead = 30}) {
    final now = DateTime.now();
    final futureDate = now.add(Duration(days: daysAhead));
    
    return _savingsGoals.where((goal) {
      return !goal.isCompleted && 
             goal.targetDate.isAfter(now) &&
             goal.targetDate.isBefore(futureDate);
    }).toList();
  }
  
  List<SavingsGoal> getOverdueGoals() {
    final now = DateTime.now();
    
    return _savingsGoals.where((goal) {
      return !goal.isCompleted && goal.targetDate.isBefore(now);
    }).toList();
  }
  
  double calculateMonthlySavingsNeeded(int goalId) {
    final goal = getSavingsGoalById(goalId);
    if (goal == null || goal.isCompleted) return 0.0;
    
    final now = DateTime.now();
    final remainingAmount = goal.targetAmount - goal.currentAmount;
    final remainingDays = goal.targetDate.difference(now).inDays;
    
    if (remainingDays <= 0) return remainingAmount;
    
    final remainingMonths = (remainingDays / 30.44).ceil(); // Average days per month
    return remainingMonths > 0 ? remainingAmount / remainingMonths : remainingAmount;
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
    await loadSavingsGoals();
  }
}