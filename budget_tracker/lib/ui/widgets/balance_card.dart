import 'package:flutter/material.dart';
import '../../utils/formatters.dart';
import '../../utils/app_constants.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    this.isLarge = false,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: AppConstants.cardElevation,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isLarge ? 24 : 20,
                  ),
                ),
              ],
            ),
            SizedBox(height: isLarge ? 12 : 8),
            Text(
              CurrencyFormatter.formatAmount(amount),
              style: isLarge 
                  ? theme.textTheme.headlineMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    )
                  : theme.textTheme.titleLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
            ),
            if (isLarge) ...[
              const SizedBox(height: 8),
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: amount >= 0 ? 1.0 : 0.3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}