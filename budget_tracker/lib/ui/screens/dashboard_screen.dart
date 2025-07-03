import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodel/transaction_provider.dart';
import '../../utils/app_constants.dart';
import '../../ui/theme/app_theme.dart';
import '../widgets/balance_card.dart';
import '../widgets/quick_transaction_form.dart';
import '../widgets/recent_transactions_list.dart';
import '../widgets/expense_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadTransactions(refresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Summary Cards
                  _buildBalanceSummary(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  _buildQuickActions(),
                  
                  const SizedBox(height: 24),
                  
                  // Expense Breakdown Chart
                  _buildExpenseChart(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Transaction Form
                  const QuickTransactionForm(),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  _buildRecentTransactions(provider),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-transaction'),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  Widget _buildBalanceSummary(TransactionProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Balance Overview',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BalanceCard(
                title: 'Total Income',
                amount: provider.totalIncome,
                color: AppTheme.getIncomeColor(),
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BalanceCard(
                title: 'Total Expense',
                amount: provider.totalExpense,
                color: AppTheme.getExpenseColor(),
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BalanceCard(
          title: 'Net Balance',
          amount: provider.netBalance,
          color: provider.netBalance >= 0 
              ? AppTheme.getIncomeColor() 
              : AppTheme.getExpenseColor(),
          icon: provider.netBalance >= 0 
              ? Icons.account_balance_wallet 
              : Icons.warning,
          isLarge: true,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.add_circle,
                label: 'Add Income',
                color: AppTheme.getIncomeColor(),
                onTap: () => _showQuickAddDialog('income'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.remove_circle,
                label: 'Add Expense',
                color: AppTheme.getExpenseColor(),
                onTap: () => _showQuickAddDialog('expense'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                label: 'View Reports',
                color: AppTheme.primaryGreen,
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpenseChart(TransactionProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Expense Breakdown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/reports'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ExpenseChart(provider: provider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
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
              onPressed: () => context.go('/transactions'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        RecentTransactionsList(
          transactions: provider.transactions.take(5).toList(),
          categories: provider.categories,
          accounts: provider.accounts,
        ),
      ],
    );
  }

  void _showQuickAddDialog(String type) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: QuickTransactionForm(
            initialType: type,
            onComplete: () {
              Navigator.of(context).pop();
              context.read<TransactionProvider>().loadTransactions(refresh: true);
            },
          ),
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}