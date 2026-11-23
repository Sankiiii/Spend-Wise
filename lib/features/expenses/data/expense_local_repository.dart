import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spend_wise/features/expenses/domain/expense_model.dart';

/// Riverpod provider to inject the repository across the application.
final expenseRepositoryProvider = Provider<ExpenseLocalRepository>((ref) {
  return ExpenseLocalRepository();
});

/// Handles reading and writing expenses to local device storage.
class ExpenseLocalRepository {
  static const String _storageKey = 'spendwise_expenses_v1';

  /// Fetches all stored expenses, sorted by date (newest first).
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawList = prefs.getStringList(_storageKey) ?? [];

      final expenses = rawList.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return ExpenseModel.fromJson(map);
      }).toList()

      // Sort descending (latest expense at the top)
      ..sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    // Fallback to empty list if reading or deserialization fails.
    // ignore: avoid_catches_without_on_clauses
    } catch (e, stack) {
      debugPrint('Error loading expenses from local storage: $e\n$stack');
      return [];
    }
  }

  /// Saves or updates an expense in local storage.
  Future<void> saveExpense(ExpenseModel expense) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentExpenses = await getExpenses();

      // Check if updating an existing expense or inserting a new one
      final index = currentExpenses.indexWhere((item) => item.id == expense.id);
      if (index >= 0) {
        currentExpenses[index] = expense;
      } else {
        currentExpenses.add(expense);
      }

      final encodedList = currentExpenses
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, encodedList);
    } catch (e, stack) {
      debugPrint('Error saving expense to local storage: $e\n$stack');
      rethrow;
    }
  }

  /// Deletes an expense by its unique ID.
  Future<void> deleteExpense(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentExpenses = await getExpenses();

      currentExpenses.removeWhere((item) => item.id == id);

      final encodedList = currentExpenses
          .map((item) => jsonEncode(item.toJson()))
          .toList();

      await prefs.setStringList(_storageKey, encodedList);
    } catch (e, stack) {
      debugPrint('Error deleting expense from local storage: $e\n$stack');
      rethrow;
    }
  }
}
