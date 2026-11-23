import 'package:flutter/material.dart';

/// Categories for expenses with built-in display names and Material icons.
enum ExpenseCategory {
  food('Food & Dining', Icons.restaurant_rounded),
  transport('Transportation', Icons.directions_bus_rounded),
  shopping('Shopping', Icons.shopping_bag_rounded),
  entertainment('Entertainment', Icons.movie_rounded),
  bills('Bills & Utilities', Icons.receipt_long_rounded),
  other('Other', Icons.category_rounded);

  const ExpenseCategory(this.displayName, this.icon);

  final String displayName;
  final IconData icon;

  /// Helper to parse string to enum safely without crashing.
  static ExpenseCategory fromString(String? value) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => ExpenseCategory.other,
    );
  }
}

/// Immutable data model representing an individual expense entry.
@immutable
class ExpenseModel {
  const ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  });

  /// Factory constructor to deserialize JSON into an ExpenseModel.
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.fromString(json['category'] as String?),
    );
  }

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;

  /// Creates a copy of this ExpenseModel with updated fields.
  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
    );
  }

  /// Serializes this model into a JSON-compatible map for persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.name,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExpenseModel &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.date == date &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, amount, date, category);
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $amount, category: ${category.name})';
  }
}
