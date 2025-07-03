import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodel/budget_provider.dart';
import '../../viewmodel/transaction_provider.dart';
import '../../data/models/budget.dart';
import '../../utils/formatters.dart';
import '../../utils/app_constants.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BudgetProvider>().loadBudgets();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active Budgets'),
            Tab(text: 'Budget Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveBudgetsTab(),
          _buildBudgetOverviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBudgetDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Budget'),
      ),
    );
  }

  Widget _buildActiveBudgetsTab() {
    return Consumer<BudgetProvider>(
      builder: (context, budgetProvider, child) {
        if (budgetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (budgetProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load budgets',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  budgetProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => budgetProvider.loadBudgets(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final activeBudgets = budgetProvider.activeBudgets;

        if (activeBudgets.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => budgetProvider.loadBudgets(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeBudgets.length,
            itemBuilder: (context, index) {
              final budget = activeBudgets[index];
              return _buildBudgetCard(budget);
            },
          ),
        );
      },
    );
  }

  Widget _buildBudgetOverviewTab() {
    return Consumer2<BudgetProvider, TransactionProvider>(
      builder: (context, budgetProvider, transactionProvider, child) {
        if (budgetProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewSummary(budgetProvider),
              const SizedBox(height: 24),
              _buildBudgetChart(budgetProvider),
              const SizedBox(height: 24),
              _buildTopCategories(budgetProvider, transactionProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        budget.categoryName ?? 'All Categories',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleBudgetAction(value, budget),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Budget Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Spent: ${CurrencyFormatter.formatAmount(budget.spent)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Budget: ${CurrencyFormatter.formatAmount(budget.amount)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            LinearProgressIndicator(
              value: budget.progressPercentage / 100,
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                budget.progressPercentage > 90
                    ? Colors.red
                    : budget.progressPercentage > 75
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budget.progressPercentage.toStringAsFixed(1)}% used',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Remaining: ${CurrencyFormatter.formatAmount(budget.remainingAmount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: budget.remainingAmount < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Budget Period
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${budget.period.toUpperCase()} • ${DateFormatter.formatDate(budget.startDate)} - ${DateFormatter.formatDate(budget.endDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSummary(BudgetProvider budgetProvider) {
    final totalBudget = budgetProvider.totalBudgetAmount;
    final totalSpent = budgetProvider.totalSpentAmount;
    final overallProgress = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Budget',
                    CurrencyFormatter.formatAmount(totalBudget),
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Spent',
                    CurrencyFormatter.formatAmount(totalSpent),
                    Icons.shopping_cart,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Overall Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                overallProgress > 90
                    ? Colors.red
                    : overallProgress > 75
                        ? Colors.orange
                        : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${overallProgress.toStringAsFixed(1)}% of total budget used',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChart(BudgetProvider budgetProvider) {
    final budgets = budgetProvider.activeBudgets;
    
    if (budgets.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          child: const Center(
            child: Text('No budget data available'),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget vs Spent',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: budgets.map((b) => b.amount).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < budgets.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                budgets[value.toInt()].name.length > 8
                                    ? '${budgets[value.toInt()].name.substring(0, 8)}...'
                                    : budgets[value.toInt()].name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            );
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            CurrencyFormatter.formatAmountCompact(value),
                            style: Theme.of(context).textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: budgets.map((b) => b.amount).reduce((a, b) => a > b ? a : b) / 5,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: budgets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final budget = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: budget.amount,
                          color: Colors.blue.withOpacity(0.3),
                          width: 20,
                        ),
                        BarChartRodData(
                          toY: budget.spent,
                          color: budget.spent > budget.amount ? Colors.red : Colors.green,
                          width: 20,
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCategories(BudgetProvider budgetProvider, TransactionProvider transactionProvider) {
    final budgets = budgetProvider.activeBudgets;
    
    if (budgets.isEmpty) return const SizedBox.shrink();

    // Sort budgets by spending percentage
    final sortedBudgets = List<Budget>.from(budgets)
      ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Budget Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedBudgets.take(5).map((budget) => _buildCategoryPerformanceItem(budget)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPerformanceItem(Budget budget) {
    final isOverBudget = budget.spent > budget.amount;
    final color = isOverBudget ? Colors.red : 
                  budget.progressPercentage > 75 ? Colors.orange : Colors.green;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  budget.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${CurrencyFormatter.formatAmount(budget.spent)} of ${CurrencyFormatter.formatAmount(budget.amount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${budget.progressPercentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Budgets',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first budget to start\ntracking your spending',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddBudgetDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Budget'),
          ),
        ],
      ),
    );
  }

  void _handleBudgetAction(String action, Budget budget) {
    switch (action) {
      case 'edit':
        _showAddBudgetDialog(budget: budget);
        break;
      case 'delete':
        _showDeleteConfirmation(budget);
        break;
    }
  }

  void _showDeleteConfirmation(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete "${budget.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetProvider>().deleteBudget(budget.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog({Budget? budget}) {
    showDialog(
      context: context,
      builder: (context) => BudgetFormDialog(budget: budget),
    );
  }
}

class BudgetFormDialog extends StatefulWidget {
  final Budget? budget;

  const BudgetFormDialog({super.key, this.budget});

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedPeriod = 'monthly';
  String? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _nameController.text = widget.budget!.name;
      _amountController.text = widget.budget!.amount.toString();
      _selectedPeriod = widget.budget!.period;
      _selectedCategory = widget.budget!.categoryName;
      _startDate = widget.budget!.startDate;
      _endDate = widget.budget!.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Create Budget' : 'Edit Budget'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Budget Name',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedPeriod,
                decoration: const InputDecoration(
                  labelText: 'Period',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'quarterly', child: Text('Quarterly')),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedPeriod = value!;
                    _updateEndDate();
                  });
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectStartDate(),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormatter.formatDate(_startDate),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectEndDate(),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          DateFormatter.formatDate(_endDate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveBudget,
          child: Text(widget.budget == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  void _updateEndDate() {
    switch (_selectedPeriod) {
      case 'weekly':
        _endDate = _startDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        _endDate = DateTime(_startDate.year, _startDate.month + 1, _startDate.day);
        break;
      case 'quarterly':
        _endDate = DateTime(_startDate.year, _startDate.month + 3, _startDate.day);
        break;
      case 'yearly':
        _endDate = DateTime(_startDate.year + 1, _startDate.month, _startDate.day);
        break;
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _updateEndDate();
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    final budget = Budget(
      id: widget.budget?.id,
      name: _nameController.text,
      amount: double.parse(_amountController.text),
      spent: widget.budget?.spent ?? 0.0,
      categoryName: _selectedCategory,
      startDate: _startDate,
      endDate: _endDate,
      isActive: true,
      period: _selectedPeriod,
      createdAt: widget.budget?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final budgetProvider = context.read<BudgetProvider>();
    bool success;

    if (widget.budget == null) {
      success = await budgetProvider.addBudget(budget);
    } else {
      success = await budgetProvider.updateBudget(budget);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? widget.budget == null 
              ? 'Budget created successfully' 
              : 'Budget updated successfully'
            : 'Failed to save budget'),
        ),
      );
    }
  }
}