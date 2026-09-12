import 'package:flutter/material.dart';
import '../../../utils/theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Acciones rápidas', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Cambié Icons.send_money por Icons.send (más común y soportado)
                _buildActionItem(Icons.send, 'Transferir', AppTheme.primaryColor, () {}),
                _buildActionItem(Icons.credit_card, 'Préstamo', AppTheme.secondaryColor, () {
                  Navigator.pushNamed(context, '/prestamos');
                }),
                _buildActionItem(Icons.shopping_bag, 'Comprar', AppTheme.accentColor, () {
                  Navigator.pushNamed(context, '/tienda');
                }),
                _buildActionItem(Icons.payments, 'Pagar', Colors.green, () {
                  Navigator.pushNamed(context, '/pagos');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                // ✅ Reemplazo de withOpacity(0.1) por withAlpha(25) (equivalente a 10% de opacidad)
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}