import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class AccountDetailScreen extends StatefulWidget {
  final int accountId;
  const AccountDetailScreen({super.key, required this.accountId});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountProvider>().loadMovements(widget.accountId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    final account = provider.getAccountById(widget.accountId);

    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de Cuenta')),
        body: const Center(child: Text('Cuenta no encontrada')),
      );
    }

    // 🔹 Se obtiene la lista de movimientos filtrada por la cuenta actual
    final movements = provider.getMovementsForAccount(widget.accountId);

    return Scaffold(
      appBar: AppBar(
        title: Text(account.tipoLabel),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            child: Column(
              children: [
                const Text('Saldo disponible', style: TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 8),
                Text(
                  Formatters.formatCurrency(account.saldo),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cuenta Nº ${account.numeroCuenta}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : movements.isEmpty
                ? const Center(child: Text('No hay movimientos'))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final movement = movements[index];
                return ListTile(
                  leading: Icon(movement.icon, color: movement.color),
                  title: Text(movement.tipoLabel),
                  subtitle: Text(movement.descripcion),
                  trailing: Text(
                    Formatters.formatCurrency(movement.monto),
                    style: TextStyle(color: movement.color),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}