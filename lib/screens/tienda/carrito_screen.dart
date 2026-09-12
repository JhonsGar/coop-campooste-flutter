import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/navigation_provider.dart'; // ← Opcional, para navegar a otras pestañas
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import 'checkout_screen.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CarritoProvider>(context);
    Provider.of<NavigationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          if (cartProvider.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: () {
                cartProvider.limpiarCarrito();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Carrito vaciado'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
            ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? const Center(child: Text('El carrito está vacío'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final item = cartProvider.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      _getIconForCategory(item.producto.categoria),
                      color: AppTheme.primaryColor,
                    ),
                    title: Text(item.producto.nombre),
                    subtitle: Text(
                      '${Formatters.formatCurrency(item.producto.precio)} x ${item.cantidad}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            cartProvider.actualizarCantidad(
                              item.producto.id,
                              item.cantidad - 1,
                            );
                          },
                        ),
                        Text('${item.cantidad}'),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            cartProvider.actualizarCantidad(
                              item.producto.id,
                              item.cantidad + 1,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.red),
                          onPressed: () {
                            cartProvider.removerProducto(item.producto.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.3),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    Text(
                      Formatters.formatCurrency(cartProvider.total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: cartProvider.items.isEmpty
                      ? null
                      : () {
                    // Navegar a la pantalla de checkout
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CheckoutScreen(), // ← SIN const
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Proceder al Pago',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String categoria) {
    switch (categoria) {
      case 'electrodomesticos':
        return Icons.kitchen;
      case 'utiles_escolares':
        return Icons.school;
      case 'tecnologia':
        return Icons.computer;
      case 'hogar':
        return Icons.home;
      default:
        return Icons.shopping_bag;
    }
  }
}