import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/producto_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class DetalleProductoScreen extends StatelessWidget {
  final int productoId;

  const DetalleProductoScreen({super.key, required this.productoId});

  @override
  Widget build(BuildContext context) {
    final productoProvider = Provider.of<ProductoProvider>(context);
    final producto = productoProvider.productos.firstWhere(
          (p) => p.id == productoId,
      orElse: () => throw Exception('Producto no encontrado'),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                _getIconForCategory(producto.categoria),
                size: 100,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              producto.nombre,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Categoría: ${producto.categoria}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(producto.precio),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            if (producto.descripcion != null)
              Text(
                producto.descripcion!,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 12),
            Text(
              'Stock disponible: ${producto.stock}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<CarritoProvider>().agregarProducto(producto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado al carrito'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text(
                  'Agregar al Carrito',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
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