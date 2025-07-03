import 'package:flutter/material.dart';

class AddTransactionScreen extends StatelessWidget {
  final int? transactionId;
  
  const AddTransactionScreen({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transactionId == null ? 'Add Transaction' : 'Edit Transaction'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Add/Edit Transaction Screen - Coming Soon'),
      ),
    );
  }
}