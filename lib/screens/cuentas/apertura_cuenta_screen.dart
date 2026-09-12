import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:coop_campooste/providers/account_provider.dart';
import 'package:coop_campooste/utils/theme.dart';

class AperturaCuentaScreen extends StatefulWidget {
  final int socioId;
  const AperturaCuentaScreen({super.key, required this.socioId});

  @override
  State<AperturaCuentaScreen> createState() => _AperturaCuentaScreenState();
}

class _AperturaCuentaScreenState extends State<AperturaCuentaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _montoController = TextEditingController();
  String _tipoCuenta = 'AHORRO_RETIRABLE';

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apertura de Libreta / Cuenta'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _tipoCuenta,
                decoration: const InputDecoration(labelText: 'Tipo de Libreta'),
                items: const [
                  DropdownMenuItem(value: 'AHORRO_RETIRABLE', child: Text('Ahorro Retirable')),
                  DropdownMenuItem(value: 'AHORRO_INVERSION', child: Text('Ahorro Inversión')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _tipoCuenta = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _montoController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Monto Apertura (RD\$)',
                  prefixText: 'RD\$ ',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Ingrese el monto inicial';
                  }
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed < 0) {
                    return 'Ingrese un monto válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              accountProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final monto = double.parse(_montoController.text);

                    // Capturar las referencias antes del 'await' para cumplir con la regla del linter
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);

                    final ok = await accountProvider.crearCuenta(
                      socioId: widget.socioId,
                      tipoCuenta: _tipoCuenta,
                      saldoInicial: monto,
                    );

                    if (!mounted) return;

                    if (ok) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Libreta creada exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      navigator.pop();
                    } else if (accountProvider.error != null) {
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(accountProvider.error!),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                child: const Text('Crear Libreta', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}