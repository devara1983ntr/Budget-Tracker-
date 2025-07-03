import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../viewmodel/transaction_provider.dart';
import '../../utils/formatters.dart';
import '../../ui/theme/app_theme.dart';

class ExpenseChart extends StatefulWidget {
  const ExpenseChart({
    super.key,
    required this.provider,
  });

  final TransactionProvider provider;

  @override
  State<ExpenseChart> createState() => _ExpenseChartState();
}

class _ExpenseChartState extends State<ExpenseChart> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final expenseTransactions = widget.provider.transactions
        .where((t) => t.type == 'expense')
        .toList();

    if (expenseTransactions.isEmpty) {
      return _buildEmptyChart();
    }

    // Group expenses by category
    final categoryExpenses = <int, double>{};
    for (final transaction in expenseTransactions) {
      categoryExpenses[transaction.categoryId] = 
          (categoryExpenses[transaction.categoryId] ?? 0) + transaction.amount;
    }

    final totalExpense = categoryExpenses.values.fold(0.0, (a, b) => a + b);
    if (totalExpense == 0) {
      return _buildEmptyChart();
    }

    final chartData = categoryExpenses.entries
        .map((entry) {
          final category = widget.provider.getCategoryById(entry.key);
          return ChartData(
            name: category?.name ?? 'Unknown',
            value: entry.value,
            color: category != null 
                ? AppTheme.getCategoryColor(category.color)
                : Colors.grey,
            percentage: (entry.value / totalExpense) * 100,
          );
        })
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedIndex = -1;
                      return;
                    }
                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _buildPieChartSections(chartData),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 3,
          child: _buildLegend(chartData),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<ChartData> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '${item.percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(List<ChartData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: data.take(5).map((item) => _buildLegendItem(item)).toList(),
    );
  }

  Widget _buildLegendItem(ChartData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  CurrencyFormatter.formatAmount(item.value),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No expense data',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding expenses to see the breakdown',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String name;
  final double value;
  final Color color;
  final double percentage;

  ChartData({
    required this.name,
    required this.value,
    required this.color,
    required this.percentage,
  });
}