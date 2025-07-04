import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';
import '../widgets/app_logo.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            const AppLogo(
              size: 100,
              showBackground: true,
            ),
            
            const SizedBox(height: 32),
            
            // App Name
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Version
            Text(
              'Version ${AppConstants.appVersion}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Description
            Text(
              'A comprehensive personal finance management app that helps you track your income and expenses with ease.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Created by credit
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Created with ❤️ by',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.createdBy,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Features
            Text(
              'Features:',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('Transaction Tracking')),
                Chip(label: Text('Budget Management')),
                Chip(label: Text('Expense Analytics')),
                Chip(label: Text('Savings Goals')),
                Chip(label: Text('Data Export')),
                Chip(label: Text('Dark/Light Theme')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}