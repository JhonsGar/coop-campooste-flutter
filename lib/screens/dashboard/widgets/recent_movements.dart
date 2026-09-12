import 'package:flutter/material.dart';
import '../../../models/movement.dart';
import '../../../utils/formatters.dart';

class RecentMovements extends StatelessWidget {
  final List<Movement> movements;
  final bool isLoading;

  const RecentMovements({super.key, required this.movements, this.isLoading = false});

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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Últimos movimientos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Ver todos', style: TextStyle(fontSize: 14, color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (movements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('No hay movimientos', style: TextStyle(color: Colors.grey))),
              )
            else
              ...movements.map((m) => _buildMovementItem(m)),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementItem(Movement movement) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: movement.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(movement.icon, color: movement.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movement.tipoLabel, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(movement.descripcion, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Formatters.formatCurrency(movement.monto), style: TextStyle(fontWeight: FontWeight.bold, color: movement.color)),
              // ✅ Convertir DateTime a String porque formatDate espera String
              Text(Formatters.formatDate(movement.fechaTransaccion.toString()), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}