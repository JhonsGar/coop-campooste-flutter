import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers y Utils
import '../../providers/auth_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../utils/theme.dart';

// Screens desde lib/screens/
import '../cuentas/financiero_screen.dart';
import '../tienda/tienda_screen.dart';
import '../tienda/carrito_screen.dart';
import '../tienda/mis_compras_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomePage(),
      const FinancieroScreen(),
      const TiendaScreen(),
      const CarritoScreen(),
      const MisComprasScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: navProvider.selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        currentIndex: navProvider.selectedIndex,
        onTap: (index) {
          navProvider.setIndex(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Financiero'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Tienda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Mis Compras'),
        ],
      ),
    );
  }
}

// ============================================
// PÁGINA DE INICIO (HOME)
// ============================================
class _HomePage extends StatelessWidget {
  const _HomePage();

  void _mostrarDialogoOperacion(BuildContext context, String tipoOperacion) {
    final montoController = TextEditingController();
    final conceptoController = TextEditingController();
    String tipoCuenta = 'Ahorro Retirable';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Registrar $tipoOperacion'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: tipoCuenta,
                decoration: const InputDecoration(labelText: 'Tipo de Cuenta'),
                items: const [
                  DropdownMenuItem(value: 'Ahorro Retirable', child: Text('Ahorro Retirable')),
                  DropdownMenuItem(value: 'Ahorro Inversión', child: Text('Ahorro Inversión')),
                ],
                onChanged: (val) {
                  if (val != null) tipoCuenta = val;
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto (RD\$)',
                  prefixText: 'RD\$ ',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: conceptoController,
                decoration: const InputDecoration(labelText: 'Concepto / Nota'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final monto = double.tryParse(montoController.text) ?? 0.0;
              if (monto <= 0) return;

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$tipoOperacion de RD\$ ${monto.toStringAsFixed(2)} registrado exitosamente.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Procesar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final user = authProvider.currentUser;

    // Obtención del rol dinámico desde el usuario activo
    final String userRol = user?.rol ?? 'Socio';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_circle, size: 80, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'Bienvenido, ${user?.nombreCompleto ?? 'Socio'}',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Chip(
                label: Text(
                  'Rol: $userRol',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text('Cédula: ${user?.cedula ?? '---'}'),
              Text('Email: ${user?.email ?? '---'}'),
              Text('Teléfono: ${user?.telefono ?? '---'}'),
              const SizedBox(height: 20),

              // RESUMEN DE CUENTAS
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Resumen de cuentas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.savings, color: Colors.green),
                        title: Text('Ahorro retirable'),
                        trailing: Text('RD\$ 0.00', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      ListTile(
                        leading: Icon(Icons.trending_up, color: Colors.blue),
                        title: Text('Ahorro inversión'),
                        trailing: Text('RD\$ 0.00', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ACCIONES RÁPIDAS DEL MÓDULO FINANCIERO (SOLO ADMINISTRADOR, CAJERO O SECRETARIO)
              if (['Administrador', 'Cajero', 'Secretario'].contains(userRol)) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_card),
                        label: const Text('Aporte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _mostrarDialogoOperacion(context, 'Aporte'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.money_off),
                        label: const Text('Retiro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _mostrarDialogoOperacion(context, 'Retiro'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.request_quote),
                        label: const Text('Préstamo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => _mostrarDialogoOperacion(context, 'Préstamo'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // REPORTE DE GANANCIAS (SOLO ADMINISTRADOR)
              if (userRol == 'Administrador') ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.analytics),
                    label: const Text('Ver Reporte de Ganancias y Capital'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => navProvider.setIndex(1),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              // BOTÓN DE GESTIÓN DE USUARIOS (SOLO ADMINISTRADOR)
              if (userRol == 'Administrador') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.people_alt),
                    label: const Text('Gestión de Usuarios y Socios'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/admin-usuarios'),
                  ),
                ),
              ],

              // BOTÓN DE ADMINISTRAR PRODUCTOS (SOLO ADMINISTRADOR Y EMPLEADO)
              if (['Administrador', 'Empleado'].contains(userRol))
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Administrar Productos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/admin-productos'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}