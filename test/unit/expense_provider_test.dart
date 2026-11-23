import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/core/widgets/app_state_view.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';
import 'package:spend_wise/features/expenses/presentation/providers/expense_provider.dart';

/// A lightweight test notifier used to inject test data into Riverpod.
class _FakeExpenseNotifier extends ExpenseListNotifier {
  _FakeExpenseNotifier(this._initialData);

  final List<ExpenseModel> _initialData;

  @override
  AppState<List<ExpenseModel>> build() {
    return AppData<List<ExpenseModel>>(_initialData);
  }
}

void main() {
  group('Expense Provider Computed Totals Tests', () {
    test('monthlyTotalProvider sums only current month expenses', () {
      final now = DateTime.now();

      // Sample data: 2 expenses from THIS month, and 1 expense from LAST YEAR
      final testExpenses = [
        ExpenseModel(
          id: '1',
          title: 'Groceries',
          amount: 500,
          date: now,
          category: ExpenseCategory.food,
        ),
        ExpenseModel(
          id: '2',
          title: 'Metro Pass',
          amount: 300,
          date: now,
          category: ExpenseCategory.transport,
        ),
        ExpenseModel(
          id: '3',
          title: 'Old Laptop Repair',
          amount: 4000,
          date: DateTime(2020, 1, 15), // From 2020 (Should NOT be counted!)
          category: ExpenseCategory.bills,
        ),
      ];

      // Create a headless Riverpod container with our test data injected
      final container = ProviderContainer(
        overrides: [
          expenseListProvider.overrideWith(
            () => _FakeExpenseNotifier(testExpenses),
          ),
        ],
      );
      addTearDown(container.dispose);

      // Read the computed provider
      final monthlyTotal = container.read(monthlyTotalProvider);

      // 500 + 300 = 800 (The 4000 from 2020 must be ignored!)
      expect(monthlyTotal, 800.0);
    });

    test('todayTotalProvider sums only expenses from today', () {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));

      final testExpenses = [
        ExpenseModel(
          id: '1',
          title: 'Lunch',
          amount: 250,
          date: now,
          category: ExpenseCategory.food,
        ),
        ExpenseModel(
          id: '2',
          title: 'Yesterday Dinner',
          amount: 600,
          date: yesterday, // Yesterday (Should NOT be counted in today's total!)
          category: ExpenseCategory.food,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          expenseListProvider.overrideWith(
            () => _FakeExpenseNotifier(testExpenses),
          ),
        ],
      );
      addTearDown(container.dispose);

      final todayTotal = container.read(todayTotalProvider);

      expect(todayTotal, 250.0);
    });
  });
}
