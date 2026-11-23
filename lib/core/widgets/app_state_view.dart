import 'package:flutter/material.dart';
import 'package:spend_wise/core/constants/app_spacing.dart';

/// Dart 3 sealed class representing the 4 mandatory UI states.
sealed class AppState<T> {
  const AppState();
}

/// Active data loading state.
final class AppLoading<T> extends AppState<T> {
  const AppLoading();
}

/// Successful state with an empty dataset.
final class AppEmpty<T> extends AppState<T> {
  const AppEmpty({this.message = 'No data available.'});
  final String message;
}

/// Failure state with an error message and optional retry callback.
final class AppError<T> extends AppState<T> {
  const AppError({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;
}

/// Successful state with non-empty populated data.
final class AppData<T> extends AppState<T> {
  const AppData(this.data);
  final T data;
}

/// A universal widget that guarantees exhaustive rendering of all 4 UI states.
class AppStateView<T> extends StatelessWidget {
  const AppStateView({
    required this.state,
    required this.dataBuilder,
    this.emptyMessage = 'No expenses found.',
    this.emptyAction,
    super.key,
  });

  final AppState<T> state;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final String emptyMessage;
  final Widget? emptyAction;

  @override
  Widget build(BuildContext context) {
    // Dart 3 switch expression guarantees exhaustive handling of all sealed states
    return switch (state) {
      AppLoading() => const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
      AppEmpty(:final message) => Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message.isNotEmpty ? message : emptyMessage,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              if (emptyAction != null) ...[
                const SizedBox(height: AppSpacing.md),
                emptyAction!,
              ],
            ],
          ),
        ),
      ),
      AppError(:final message, :final onRetry) => Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
      AppData(:final data) => dataBuilder(context, data),
    };
  }
}
