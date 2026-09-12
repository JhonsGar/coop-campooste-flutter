import 'package:flutter/material.dart';
import '../../../utils/theme.dart';
import '../../../utils/formatters.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final bool isLoading;

  const BalanceCard({super.key, required this.totalBalance, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Saldo Total', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Text(
                Formatters.formatCurrency(totalBalance),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildStatItem('Cuentas', '3', Icons.account_balance)),
                Expanded(child: _buildStatItem('Préstamos', '2', Icons.credit_card)),
                Expanded(child: _buildStatItem('Productos', '12', Icons.shopping_bag)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.secondaryColor, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}