import 'package:flutter/material.dart';

class TransactionDetailScreen extends StatelessWidget {
  final int transactionId;
  
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Transaction Detail Screen for ID: $transactionId - Coming Soon'),
      ),
    );
  }
}