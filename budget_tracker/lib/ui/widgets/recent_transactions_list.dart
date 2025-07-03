import 'package:flutter/material.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../data/models/account.dart';
import '../../utils/formatters.dart';
import '../../ui/theme/app_theme.dart';

class RecentTransactionsList extends StatelessWidget {
  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.categories,
    required this.accounts,
    this.onTap,
  });

  final List<Transaction> transactions;
  final List<Category> categories;
  final List<Account> accounts;
  final Function(Transaction)? onTap;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _TransactionListItem(
            transaction: transaction,
            category: _getCategoryById(transaction.categoryId),
            account: _getAccountById(transaction.accountId),
            onTap: onTap != null ? () => onTap!(transaction) : null,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start tracking your expenses and income',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Category? _getCategoryById(int id) {
    try {
      return categories.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Account? _getAccountById(int id) {
    try {
      return accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({
    required this.transaction,
    required this.category,
    required this.account,
    this.onTap,
  });

  final Transaction transaction;
  final Category? category;
  final Account? account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final color = isIncome ? AppTheme.getIncomeColor() : AppTheme.getExpenseColor();
    
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: category != null 
            ? AppTheme.getCategoryColor(category!.color).withOpacity(0.1)
            : color.withOpacity(0.1),
        child: Icon(
          _getCategoryIcon(),
          color: category != null 
              ? AppTheme.getCategoryColor(category!.color)
              : color,
          size: 20,
        ),
      ),
      title: Text(
        transaction.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category?.name ?? 'Unknown Category',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormatter.formatRelativeDate(transaction.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (account != null) ...[
                const SizedBox(width: 8),
                const Text('•'),
                const SizedBox(width: 8),
                Text(
                  account!.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${isIncome ? '+' : '-'}${CurrencyFormatter.formatAmount(transaction.amount)}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (transaction.receiptImagePath != null) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.attach_file,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    if (category?.icon == null) {
      return transaction.type == 'income' ? Icons.trending_up : Icons.trending_down;
    }

    // Map string icon names to IconData
    switch (category!.icon) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'receipt':
        return Icons.receipt;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'work':
        return Icons.work;
      case 'laptop':
        return Icons.laptop;
      case 'trending_up':
        return Icons.trending_up;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'account_balance':
        return Icons.account_balance;
      case 'credit_card':
        return Icons.credit_card;
      default:
        return transaction.type == 'income' ? Icons.trending_up : Icons.trending_down;
    }
  }
}