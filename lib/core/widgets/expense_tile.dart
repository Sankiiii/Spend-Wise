import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spend_wise/core/constants/app_spacing.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';

/// Reusable expense tile with swipe-to-delete action.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    required this.expense,
    required this.onDelete,
    super.key,
  });

  final ExpenseModel expense;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );
    final dateFormat = DateFormat.yMMMd();
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: AppSpacing.radiusMd,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          color: colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            child: Icon(expense.category.icon),
          ),
          title: Text(
            expense.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${expense.category.displayName} • ${dateFormat.format(expense.date)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
          ),
          trailing: Text(
            currencyFormat.format(expense.amount),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
          ),
        ),
      ),
    );
  }
}
