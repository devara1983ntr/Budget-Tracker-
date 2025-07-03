import 'package:flutter/material.dart';
import '../data/repositories/budget_repository.dart';
import '../data/models/category.dart';

class CategoryProvider extends ChangeNotifier {
  final BudgetRepository _repository;
  
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  
  CategoryProvider(this._repository) {
    loadCategories();
  }
  
  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<Category> get incomeCategories {
    return _categories.where((cat) => cat.type == 'income' || cat.type == 'both').toList();
  }
  
  List<Category> get expenseCategories {
    return _categories.where((cat) => cat.type == 'expense' || cat.type == 'both').toList();
  }
  
  // Methods
  Future<void> loadCategories() async {
    _setLoading(true);
    _clearError();
    
    try {
      _categories = await _repository.getAllCategories();
    } catch (e) {
      _setError('Failed to load categories: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<bool> addCategory(Category category) async {
    try {
      final id = await _repository.addCategory(category);
      if (id > 0) {
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to add category: $e');
      return false;
    }
  }
  
  Future<bool> updateCategory(Category category) async {
    try {
      final result = await _repository.updateCategory(category);
      if (result > 0) {
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to update category: $e');
      return false;
    }
  }
  
  Future<bool> deleteCategory(int id) async {
    try {
      final result = await _repository.deleteCategory(id);
      if (result > 0) {
        await loadCategories();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Failed to delete category: $e');
      return false;
    }
  }
  
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
  
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name == name);
    } catch (e) {
      return null;
    }
  }
  
  List<Category> getCategoriesByType(String type) {
    return _categories.where((cat) => cat.type == type || cat.type == 'both').toList();
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
    await loadCategories();
  }
}