import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtener el usuario autenticado para cargar sus cuentas por su ID
      final auth = context.read<AuthProvider>();
      if (auth.currentUser != null) {
        context.read<AccountProvider>().loadAccountsBySocio(auth.currentUser!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Cuentas'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            provider.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : provider.accounts.isEmpty
          ? const Center(child: Text('No tienes cuentas activas'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.accounts.length,
        itemBuilder: (context, index) {
          final account = provider.accounts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(account.icon, color: AppTheme.primaryColor),
              title: Text(account.tipoLabel),
              subtitle: Text('Nº ${account.numeroCuenta}'),
              trailing: Text(
                Formatters.formatCurrency(account.saldo),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/cuenta-detalle',
                  arguments: account.id,
                );
              },
            ),
          );
        },
      ),
    );
  }
}