import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../viewmodel/transaction_provider.dart';
import '../../viewmodel/category_provider.dart';
import '../../viewmodel/account_provider.dart';
import '../../data/models/transaction.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../utils/app_constants.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? transactionId;
  
  const AddTransactionScreen({
    super.key,
    this.transactionId,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedType = AppConstants.expenseType;
  String? _selectedCategory;
  String? _selectedAccount;
  DateTime _selectedDate = DateTime.now();
  File? _selectedImage;
  Transaction? _existingTransaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() async {
    if (widget.transactionId != null) {
      // Edit mode - load existing transaction
      setState(() => _isLoading = true);
      
      final transaction = await context.read<TransactionProvider>()
          .getTransactionById(widget.transactionId!);
      
      if (transaction != null) {
        _existingTransaction = transaction;
        _descriptionController.text = transaction.description;
        _amountController.text = transaction.amount.toString();
        _notesController.text = transaction.notes ?? '';
        _selectedType = transaction.type;
        _selectedCategory = transaction.category;
        _selectedAccount = transaction.account;
        _selectedDate = transaction.date;
        
        // Load image if exists
        if (transaction.imagePath != null && File(transaction.imagePath!).existsSync()) {
          _selectedImage = File(transaction.imagePath!);
        }
      }
      
      setState(() => _isLoading = false);
    } else {
      // Add mode - set defaults
      _setDefaults();
    }
  }

  void _setDefaults() {
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
    final isEdit = widget.transactionId != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 20),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildAccountDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 80), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectType(AppConstants.incomeType),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedType == AppConstants.incomeType
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: _selectedType == AppConstants.incomeType
                              ? Colors.green
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle,
                            color: _selectedType == AppConstants.incomeType
                                ? Colors.green
                                : Colors.grey.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Income',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedType == AppConstants.incomeType
                                  ? Colors.green
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectType(AppConstants.expenseType),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _selectedType == AppConstants.expenseType
                            ? Colors.red.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        border: Border.all(
                          color: _selectedType == AppConstants.expenseType
                              ? Colors.red
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.remove_circle,
                            color: _selectedType == AppConstants.expenseType
                                ? Colors.red
                                : Colors.grey.shade600,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Expense',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _selectedType == AppConstants.expenseType
                                  ? Colors.red
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description *',
        hintText: 'Enter transaction description',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a description';
        }
        if (value.trim().length < 3) {
          return 'Description must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: 'Amount *',
        hintText: '0.00',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: CurrencyFormatter.getCurrentCurrencySymbol(),
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an amount';
        }
        if (!CurrencyFormatter.isValidAmount(value)) {
          return 'Please enter a valid amount';
        }
        final amount = CurrencyFormatter.parseAmount(value);
        if (amount <= 0) {
          return 'Amount must be greater than 0';
        }
        return null;
      },
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
            labelText: 'Category *',
            prefixIcon: Icon(Icons.category),
            border: OutlineInputBorder(),
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
            labelText: 'Account *',
            prefixIcon: Icon(Icons.account_balance_wallet),
            border: OutlineInputBorder(),
          ),
          items: accountProvider.accounts.map((account) {
            return DropdownMenuItem(
              value: account.name,
              child: Row(
                children: [
                  Icon(account.icon, size: 20),
                  const SizedBox(width: 8),
                  Text(account.name),
                ],
              ),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(),
        ),
        child: Text(
          DateFormatter.formatDisplay(_selectedDate),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Notes (Optional)',
        hintText: 'Add any additional notes',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt),
                const SizedBox(width: 8),
                Text(
                  'Receipt Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change Photo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _removeImage,
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    style: BorderStyle.solid,
                  ),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Receipt Photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveTransaction,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.transactionId != null ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectType(String type) {
    setState(() {
      _selectedType = type;
      // Reset category when type changes
      final categoryProvider = context.read<CategoryProvider>();
      final categories = type == AppConstants.incomeType
          ? categoryProvider.incomeCategories
          : categoryProvider.expenseCategories;
      
      if (categories.isNotEmpty) {
        _selectedCategory = categories.first.name;
      }
    });
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategory == null || _selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select category and account'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    final amount = CurrencyFormatter.parseAmount(_amountController.text);
    
    final transaction = Transaction(
      id: _existingTransaction?.id,
      description: _descriptionController.text.trim(),
      amount: amount,
      type: _selectedType,
      date: _selectedDate,
      category: _selectedCategory!,
      account: _selectedAccount!,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      imagePath: _selectedImage?.path,
    );
    
    bool success;
    if (widget.transactionId != null) {
      success = await context.read<TransactionProvider>().updateTransaction(transaction);
    } else {
      success = await context.read<TransactionProvider>().addTransaction(transaction);
    }
    
    setState(() => _isLoading = false);
    
    if (success) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionId != null 
                  ? 'Transaction updated successfully'
                  : 'Transaction added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transactionId != null 
                  ? 'Failed to update transaction'
                  : 'Failed to add transaction',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _deleteTransaction() async {
    if (widget.transactionId == null) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      final success = await context.read<TransactionProvider>()
          .deleteTransaction(widget.transactionId!);
      
      setState(() => _isLoading = false);
      
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                  ? 'Transaction deleted successfully'
                  : 'Failed to delete transaction',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}