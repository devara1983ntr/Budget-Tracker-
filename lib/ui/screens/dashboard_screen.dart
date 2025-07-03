import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/transaction_provider.dart';
import '../../viewmodel/category_provider.dart';
import '../../viewmodel/account_provider.dart';
import '../../data/models/transaction.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/app_constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedType = AppConstants.expenseType;
  String? _selectedCategory;
  String? _selectedAccount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaults();
    });
  }

  void _initializeDefaults() {
    final categoryProvider = context.read<CategoryProvider>();
    final accountProvider = context.read<AccountProvider>();
    
    if (categoryProvider.expenseCategories.isNotEmpty) {
      _selectedCategory = categoryProvider.expenseCategories.first.name;
    }
    
    if (accountProvider.accounts.isNotEmpty) {
      _selectedAccount = accountProvider.accounts.first.name;
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Tracker'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/transactions'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TransactionProvider>().refresh();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildQuickAddSection(),
              const SizedBox(height: 24),
              _buildRecentTransactionsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-transaction'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        final balance = transactionProvider.totalBalance;
        final income = transactionProvider.totalIncome;
        final expense = transactionProvider.totalExpense;
        
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'Total Balance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(balance),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSummaryItem(
                      'Income',
                      CurrencyFormatter.format(income),
                      Colors.green,
                      Icons.trending_up,
                    ),
                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    _buildSummaryItem(
                      'Expense',
                      CurrencyFormatter.format(expense),
                      Colors.red,
                      Icons.trending_down,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Quick Add Transaction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter transaction description',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.attach_money),
                  prefixText: CurrencyFormatter.getCurrentCurrencySymbol(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (!CurrencyFormatter.isValidAmount(value)) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Type, Category, Account Row
              Row(
                children: [
                  Expanded(child: _buildCategoryDropdown()),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAccountDropdown()),
                ],
              ),
              const SizedBox(height: 16),
              
              // Transaction Type Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addTransaction(AppConstants.incomeType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('INCOME'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _addTransaction(AppConstants.expenseType),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.remove),
                      label: const Text('EXPENSE'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        final categories = _selectedType == AppConstants.incomeType
            ? categoryProvider.incomeCategories
            : categoryProvider.expenseCategories;
        
        return DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Category',
            prefixIcon: Icon(Icons.category),
          ),
          items: categories.map((category) {
            return DropdownMenuItem(
              value: category.name,
              child: Row(
                children: [
                  Icon(category.icon, size: 20, color: category.color),
                  const SizedBox(width: 8),
                  Expanded(child: Text(category.name)),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, child) {
        return DropdownButtonFormField<String>(
          value: _selectedAccount,
          decoration: const InputDecoration(
            labelText: 'Account',
            prefixIcon: Icon(Icons.account_balance_wallet),
          ),
          items: accountProvider.accounts.map((account) {
            return DropdownMenuItem(
              value: account.name,
              child: Text(account.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccount = value;
            });
          },
          validator: (value) {
            if (value == null) {
              return 'Please select an account';
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/transactions'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Consumer<TransactionProvider>(
          builder: (context, transactionProvider, child) {
            if (transactionProvider.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final recentTransactions = transactionProvider.recentTransactions;
            
            if (recentTransactions.isEmpty) {
              return _buildEmptyState();
            }
            
            return Column(
              children: recentTransactions.map((transaction) {
                return _buildTransactionCard(transaction);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first transaction above',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == AppConstants.incomeType;
    final color = isIncome ? Colors.green : Colors.red;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            isIncome ? Icons.add : Icons.remove,
            color: color,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(
              DateFormatter.formatDisplay(transaction.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        trailing: Text(
          CurrencyFormatter.formatWithSign(transaction.amount, transaction.type),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        onTap: () => context.push('/transaction-detail/${transaction.id}'),
      ),
    );
  }

  void _addTransaction(String type) async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _selectedType = type;
    });
    
    // Update category selection based on type
    final categoryProvider = context.read<CategoryProvider>();
    final categories = type == AppConstants.incomeType
        ? categoryProvider.incomeCategories
        : categoryProvider.expenseCategories;
    
    if (categories.isNotEmpty && 
        !categories.any((cat) => cat.name == _selectedCategory)) {
      _selectedCategory = categories.first.name;
    }
    
    if (_selectedCategory == null || _selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select category and account')),
      );
      return;
    }
    
    final amount = CurrencyFormatter.parseAmount(_amountController.text);
    
    final transaction = Transaction(
      description: _descriptionController.text.trim(),
      amount: amount,
      type: type,
      date: DateTime.now(),
      category: _selectedCategory!,
      account: _selectedAccount!,
    );
    
    final success = await context.read<TransactionProvider>().addTransaction(transaction);
    
    if (success) {
      _clearForm();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${type == AppConstants.incomeType ? 'Income' : 'Expense'} added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add transaction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearForm() {
    _descriptionController.clear();
    _amountController.clear();
    setState(() {
      _selectedType = AppConstants.expenseType;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}