import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecuritySetupScreen extends StatelessWidget {
  const SecuritySetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Setup'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 64),
            const SizedBox(height: 16),
            const Text('Security Setup'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }
}