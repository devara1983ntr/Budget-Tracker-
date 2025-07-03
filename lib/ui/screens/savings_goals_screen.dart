import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodel/savings_goal_provider.dart';
import '../../data/models/savings_goal.dart';
import '../../utils/formatters.dart';
import '../../utils/app_constants.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsGoalProvider>().loadSavingsGoals();
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
        title: const Text('Savings Goals'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
            Tab(text: 'Overview'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveGoalsTab(),
          _buildCompletedGoalsTab(),
          _buildOverviewTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(),
        icon: const Icon(Icons.savings),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildActiveGoalsTab() {
    return Consumer<SavingsGoalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return _buildErrorState(provider.error!, () => provider.loadSavingsGoals());
        }

        final activeGoals = provider.activeGoals;

        if (activeGoals.isEmpty) {
          return _buildEmptyState(
            'No Active Goals',
            'Set your first savings goal to start\nbuilding your financial future',
            Icons.savings_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadSavingsGoals(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeGoals.length,
            itemBuilder: (context, index) {
              final goal = activeGoals[index];
              return _buildGoalCard(goal);
            },
          ),
        );
      },
    );
  }

  Widget _buildCompletedGoalsTab() {
    return Consumer<SavingsGoalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final completedGoals = provider.completedGoals;

        if (completedGoals.isEmpty) {
          return _buildEmptyState(
            'No Completed Goals',
            'Complete your first savings goal\nto see it here',
            Icons.check_circle_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completedGoals.length,
          itemBuilder: (context, index) {
            final goal = completedGoals[index];
            return _buildCompletedGoalCard(goal);
          },
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<SavingsGoalProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOverviewSummary(provider),
              const SizedBox(height: 24),
              _buildProgressChart(provider),
              const SizedBox(height: 24),
              _buildGoalStats(provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalCard(SavingsGoal goal) {
    final progressPercentage = goal.progressPercentage;
    final isNearDeadline = goal.daysUntilDeadline <= 30 && goal.daysUntilDeadline > 0;
    final isOverdue = goal.daysUntilDeadline < 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.savings,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          goal.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleGoalAction(value, goal),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_money',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle),
                          SizedBox(width: 8),
                          Text('Add Money'),
                        ],
                      ),
                    ),
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
            const SizedBox(height: 20),

            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${progressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: progressPercentage >= 100 ? Colors.green : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progressPercentage / 100,
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage >= 100 ? Colors.green : Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Amount Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saved',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatAmount(goal.currentAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatAmount(goal.targetAmount),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Deadline Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isOverdue
                    ? Colors.red.withOpacity(0.1)
                    : isNearDeadline
                        ? Colors.orange.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isOverdue
                      ? Colors.red.withOpacity(0.3)
                      : isNearDeadline
                          ? Colors.orange.withOpacity(0.3)
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue
                        ? Icons.warning
                        : isNearDeadline
                            ? Icons.schedule
                            : Icons.calendar_today,
                    size: 20,
                    color: isOverdue
                        ? Colors.red
                        : isNearDeadline
                            ? Colors.orange
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          DateFormatter.formatDate(goal.targetDate),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isOverdue
                        ? 'Overdue'
                        : goal.daysUntilDeadline == 0
                            ? 'Today'
                            : '${goal.daysUntilDeadline} days left',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isOverdue
                          ? Colors.red
                          : isNearDeadline
                              ? Colors.orange
                              : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedGoalCard(SavingsGoal goal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Completed on ${DateFormatter.formatDate(goal.updatedAt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'COMPLETED',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount Saved',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatAmount(goal.currentAmount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Target Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      DateFormatter.formatDate(goal.targetDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSummary(SavingsGoalProvider provider) {
    final totalTargetAmount = provider.totalTargetAmount;
    final totalCurrentAmount = provider.totalCurrentAmount;
    final totalGoals = provider.allGoals.length;
    final completedGoals = provider.completedGoals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Savings Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Goals',
                    totalGoals.toString(),
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Completed',
                    completedGoals.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Saved',
                    CurrencyFormatter.formatAmountCompact(totalCurrentAmount),
                    Icons.savings,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Target',
                    CurrencyFormatter.formatAmountCompact(totalTargetAmount),
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Overall Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Overall Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${provider.overallProgressPercentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: provider.overallProgressPercentage / 100,
              backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
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
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart(SavingsGoalProvider provider) {
    final goals = provider.activeGoals;
    
    if (goals.isEmpty) {
      return Card(
        child: Container(
          height: 200,
          child: const Center(
            child: Text('No active goals to display'),
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
              'Goal Progress',
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
                  maxY: goals.map((g) => g.targetAmount).reduce((a, b) => a > b ? a : b) * 1.2,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < goals.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                goals[value.toInt()].name.length > 8
                                    ? '${goals[value.toInt()].name.substring(0, 8)}...'
                                    : goals[value.toInt()].name,
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
                    horizontalInterval: goals.map((g) => g.targetAmount).reduce((a, b) => a > b ? a : b) / 5,
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: goals.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goal = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: goal.targetAmount,
                          color: Colors.blue.withOpacity(0.3),
                          width: 15,
                        ),
                        BarChartRodData(
                          toY: goal.currentAmount,
                          color: goal.currentAmount >= goal.targetAmount ? Colors.green : Colors.blue,
                          width: 15,
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

  Widget _buildGoalStats(SavingsGoalProvider provider) {
    final goals = provider.activeGoals;
    
    if (goals.isEmpty) return const SizedBox.shrink();

    // Sort goals by progress percentage
    final sortedGoals = List<SavingsGoal>.from(goals)
      ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goal Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedGoals.take(5).map((goal) => _buildGoalStatItem(goal)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalStatItem(SavingsGoal goal) {
    final color = goal.progressPercentage >= 100 ? Colors.green :
                  goal.progressPercentage >= 75 ? Colors.blue :
                  goal.progressPercentage >= 50 ? Colors.orange : Colors.red;

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
                  goal.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${CurrencyFormatter.formatAmount(goal.currentAmount)} of ${CurrencyFormatter.formatAmount(goal.targetAmount)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${goal.progressPercentage.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddGoalDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Goal'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
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
            'Failed to load goals',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _handleGoalAction(String action, SavingsGoal goal) {
    switch (action) {
      case 'add_money':
        _showAddMoneyDialog(goal);
        break;
      case 'edit':
        _showAddGoalDialog(goal: goal);
        break;
      case 'delete':
        _showDeleteConfirmation(goal);
        break;
    }
  }

  void _showAddMoneyDialog(SavingsGoal goal) {
    final amountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Money to ${goal.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current amount: ${CurrencyFormatter.formatAmount(goal.currentAmount)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount to Add',
                prefixIcon: Icon(Icons.attach_money),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _addMoneyToGoal(goal, amountController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addMoneyToGoal(SavingsGoal goal, String amountText) async {
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.pop(context);
    
    final updatedGoal = goal.copyWith(
      currentAmount: goal.currentAmount + amount,
      updatedAt: DateTime.now(),
    );

    final success = await context.read<SavingsGoalProvider>().updateSavingsGoal(updatedGoal);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Money added successfully!' : 'Failed to add money'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(SavingsGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to delete "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<SavingsGoalProvider>().deleteSavingsGoal(goal.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Goal deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog({SavingsGoal? goal}) {
    showDialog(
      context: context,
      builder: (context) => SavingsGoalFormDialog(goal: goal),
    );
  }
}

class SavingsGoalFormDialog extends StatefulWidget {
  final SavingsGoal? goal;

  const SavingsGoalFormDialog({super.key, this.goal});

  @override
  State<SavingsGoalFormDialog> createState() => _SavingsGoalFormDialogState();
}

class _SavingsGoalFormDialogState extends State<SavingsGoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _descriptionController.text = widget.goal!.description;
      _targetAmountController.text = widget.goal!.targetAmount.toString();
      _targetDate = widget.goal!.targetDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'Create Savings Goal' : 'Edit Savings Goal'),
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
                  labelText: 'Goal Name',
                  prefixIcon: Icon(Icons.flag),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a goal name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _targetAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () => _selectTargetDate(),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Target Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormatter.formatDate(_targetDate),
                  ),
                ),
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
          onPressed: _saveGoal,
          child: Text(widget.goal == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _selectTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    final goal = SavingsGoal(
      id: widget.goal?.id,
      name: _nameController.text,
      description: _descriptionController.text,
      targetAmount: double.parse(_targetAmountController.text),
      currentAmount: widget.goal?.currentAmount ?? 0.0,
      targetDate: _targetDate,
      icon: 'savings',
      color: Theme.of(context).colorScheme.primary.value,
      isCompleted: widget.goal?.isCompleted ?? false,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final provider = context.read<SavingsGoalProvider>();
    bool success;

    if (widget.goal == null) {
      success = await provider.addSavingsGoal(goal);
    } else {
      success = await provider.updateSavingsGoal(goal);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? widget.goal == null 
              ? 'Goal created successfully' 
              : 'Goal updated successfully'
            : 'Failed to save goal'),
        ),
      );
    }
  }
}