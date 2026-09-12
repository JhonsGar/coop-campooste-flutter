import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagos'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payments, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Próximamente...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}