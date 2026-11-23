import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/core/constants/app_spacing.dart';
import 'package:spend_wise/core/widgets/app_state_view.dart';
import 'package:spend_wise/core/widgets/base_screen.dart';
import 'package:spend_wise/core/widgets/expense_tile.dart';
import 'package:spend_wise/core/widgets/monthly_summary_card.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';
import 'package:spend_wise/features/expenses/presentation/add_expense_screen.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_provider.dart';


/// The main dashboard screen showing summary metrics and transaction history.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseState = ref.watch(expenseListProvider);

    return BaseScreen(
      appBar: AppBar(
        title: const Text(
          'SpendWise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () async {
              await ref.read(expenseListProvider.notifier).loadExpenses();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const AddExpenseScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MonthlySummaryCard(),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: AppStateView<List<ExpenseModel>>(
              state: expenseState,
              emptyMessage: 'No expenses recorded yet.\nTap + to add one!',
              dataBuilder: (context, expenses) {
                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: expenses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ExpenseTile(
                      expense: expense,
                      onDelete: () async {
                        await ref
                            .read(expenseListProvider.notifier)
                            .deleteExpense(expense.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Deleted "${expense.title}"'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
