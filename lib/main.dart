import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/core/theme/app_theme.dart';
import 'package:spend_wise/features/expenses/presentation/dashboard_screen.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Tier 1: Catch Flutter framework UI errors
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('UI Error Caught: ${details.exception}');
      };

      // Tier 2: Catch uncaught asynchronous Dart errors
      PlatformDispatcher.instance.onError = (error, stack) {
        debugPrint('Async Error Caught: $error');
        return true;
      };

      // Wrap root widget in Riverpod's ProviderScope
      runApp(
        const ProviderScope(
          child: SpendWiseApp(),
        ),
      );
    },
    (error, stack) {
      // Tier 3: Catch root zone errors
      debugPrint('Root Zone Error Caught: $error');
    },
  );
}

class SpendWiseApp extends StatelessWidget {
  const SpendWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}
