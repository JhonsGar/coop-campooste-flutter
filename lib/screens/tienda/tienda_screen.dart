import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/producto_provider.dart';
import '../../providers/carrito_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import 'detalle_producto_screen.dart';

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  bool _isFirstLoad = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProductoProvider>().loadProductos();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductoProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tienda Coop_Campooste'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${provider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProductos(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tienda Coop_Campooste'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.productos.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tienda Coop_Campooste'),
              backgroundColor: AppTheme.primaryColor,
            ),
            body: const Center(child: Text('No hay productos disponibles')),
          );
        }

        // ============================================
        // DISEÑO ULTRACOMPACTO (5 columnas, 7 productos en pantalla)
        // ============================================
        return Scaffold(
          appBar: AppBar(
            title: const Text('Tienda Coop_Campooste'),
            backgroundColor: AppTheme.primaryColor,
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      context.read<NavigationProvider>().goToCarrito();
                    },
                  ),
                  Consumer<CarritoProvider>(
                    builder: (context, cart, _) {
                      if (cart.totalItems == 0) return const SizedBox.shrink();
                      return Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          body: GridView.builder(
            // Reducido el padding general a 1
            padding: const EdgeInsets.all(1),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 columnas
              // Cambiado de 0.30 a 0.85 para que las tarjetas sean más anchas
              // y bajas, permitiendo que las 7 quepan sin scroll.
              childAspectRatio: 0.85,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: provider.productos.length,
            itemBuilder: (context, index) {
              final product = provider.productos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalleProductoScreen(
                        productoId: product.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    // Padding interno reducido a 2
                    padding: const EdgeInsets.all(2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Icono aumentado de 18 a 30
                        Icon(
                          _getIconForCategory(product.categoria),
                          size: 30,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.nombre,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatCurrency(product.precio),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Stock: ${product.stock}',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
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