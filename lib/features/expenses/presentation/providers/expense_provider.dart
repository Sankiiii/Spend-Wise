import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/core/widgets/app_state_view.dart';
import 'package:spend_wise/features/expenses/data/expense_local_repository.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';

/// Notifier that manages the list of expenses and its 4 UI states.
class ExpenseListNotifier extends Notifier<AppState<List<ExpenseModel>>> {
  @override
  AppState<List<ExpenseModel>> build() {
    unawaited(loadExpenses());
    return const AppLoading<List<ExpenseModel>>();
  }

  ExpenseLocalRepository get _repository => ref.read(expenseRepositoryProvider);

  /// Loads all expenses from local storage and maps to AppEmpty or AppData.
  Future<void> loadExpenses() async {
    state = const AppLoading<List<ExpenseModel>>();
    try {
      final expenses = await _repository.getExpenses();
      if (expenses.isEmpty) {
        state = const AppEmpty<List<ExpenseModel>>(
          message: 'No expenses yet. Tap + to record your first expense!',
        );
      } else {
        state = AppData<List<ExpenseModel>>(expenses);
      }
    } on Exception catch (e) {
      state = AppError<List<ExpenseModel>>(
        message: 'Failed to load expenses ($e). Please try again.',
        onRetry: loadExpenses,
      );
    }
  }

  /// Adds a new expense, updates storage, and refreshes the state.
  Future<void> addExpense(ExpenseModel expense) async {
    await _repository.saveExpense(expense);
    // Reload to ensure sorted order and persistence
    await loadExpenses();
  }

  /// Deletes an expense by ID and refreshes the state.
  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    await loadExpenses();
  }
}

/// Global provider for managing the expense list state.
final expenseListProvider =
    NotifierProvider<ExpenseListNotifier, AppState<List<ExpenseModel>>>(
      ExpenseListNotifier.new,
    );

/// Computed provider that calculates total spent in the current month.
final monthlyTotalProvider = Provider<double>((ref) {
  final expenseState = ref.watch(expenseListProvider);
  if (expenseState is AppData<List<ExpenseModel>>) {
    final now = DateTime.now();
    return expenseState.data
        .where(
          (item) => item.date.year == now.year && item.date.month == now.month,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }
  return 0;
});

/// Computed provider that calculates total spent today.
final todayTotalProvider = Provider<double>((ref) {
  final expenseState = ref.watch(expenseListProvider);
  if (expenseState is AppData<List<ExpenseModel>>) {
    final now = DateTime.now();
    return expenseState.data
        .where(
          (item) =>
              item.date.year == now.year &&
              item.date.month == now.month &&
              item.date.day == now.day,
        )
        .fold(0, (sum, item) => sum + item.amount);
  }
  return 0;
});
