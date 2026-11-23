import 'package:flutter_test/flutter_test.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';

void main() {
  group('ExpenseModel Unit Tests', () {
    final testDate = DateTime(2026, 11, 23);

    final sampleExpense = ExpenseModel(
      id: 'test_1',
      title: 'Coffee',
      amount: 150,
      date: testDate,
      category: ExpenseCategory.food,
    );

    test('toJson() converts ExpenseModel into a valid Map', () {
      final json = sampleExpense.toJson();

      expect(json['id'], 'test_1');
      expect(json['title'], 'Coffee');
      expect(json['amount'], 150.0);
      expect(json['date'], testDate.toIso8601String());
      expect(json['category'], 'food');
    });

    test('fromJson() correctly parses Map into ExpenseModel', () {
      final jsonMap = {
        'id': 'test_2',
        'title': 'Train Ticket',
        'amount': 45.0,
        'date': testDate.toIso8601String(),
        'category': 'transport',
      };

      final model = ExpenseModel.fromJson(jsonMap);

      expect(model.id, 'test_2');
      expect(model.title, 'Train Ticket');
      expect(model.amount, 45.0);
      expect(model.category, ExpenseCategory.transport);
      expect(model.date, testDate);
    });

    test(
      'copyWith() returns updated copy while keeping other fields unchanged',
      () {
        final updated = sampleExpense.copyWith(
          title: 'Starbucks Coffee',
          amount: 320,
        );

        // Changed fields
        expect(updated.title, 'Starbucks Coffee');
        expect(updated.amount, 320.0);

        // Unchanged fields preserved
        expect(updated.id, sampleExpense.id);
        expect(updated.date, sampleExpense.date);
        expect(updated.category, sampleExpense.category);
      },
    );

    test('Value equality (==) returns true for identical instances', () {
      final duplicateExpense = ExpenseModel(
        id: 'test_1',
        title: 'Coffee',
        amount: 150,
        date: testDate,
        category: ExpenseCategory.food,
      );

      // Even though they are two separate objects in memory,
      // their values are equal, so operator == must return true!
      expect(sampleExpense, equals(duplicateExpense));
      expect(sampleExpense.hashCode, equals(duplicateExpense.hashCode));
    });
  });
}
