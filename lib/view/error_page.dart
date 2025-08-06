import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {
  ErrorPage({super.key, required this.title, required this.id});

  final String title;
  final int id;
  final Map<int, String> messages = {
    1: 'User must be logged in and part of family to add impages',
  };

  @override
  Widget build(BuildContext context) {
    final router = AutoRouter.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Protection',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              messages[id] ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => router.back(),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
