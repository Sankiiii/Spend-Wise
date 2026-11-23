import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:spend_wise/core/constants/app_spacing.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_provider.dart';

/// Summary card displaying monthly and daily totals side-by-side.
class MonthlySummaryCard extends ConsumerWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watches only the totals; does not rebuild when individual list items reorder
    final monthlyTotal = ref.watch(monthlyTotalProvider);
    final todayTotal = ref.watch(todayTotalProvider);

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 2,
    );

    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Row(
          children: [
            Expanded(
              child: _MetricItem(
                label: 'This Month',
                amount: currencyFormat.format(monthlyTotal),
                amountColor: colorScheme.onPrimaryContainer,
              ),
            ),
            Container(
              height: 48,
              width: 1,
              color: colorScheme.outlineVariant,
            ),
            Expanded(
              child: _MetricItem(
                label: 'Today',
                amount: currencyFormat.format(todayTotal),
                amountColor: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.amount,
    required this.amountColor,
  });

  final String label;
  final String amount;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ),
      ],
    );
  }
}
