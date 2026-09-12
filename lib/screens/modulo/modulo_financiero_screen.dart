import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coop_campooste/providers/auth_provider.dart';
import 'package:coop_campooste/providers/financial_provider.dart';

class ModuloFinancieroScreen extends StatefulWidget {
  const ModuloFinancieroScreen({super.key});

  @override
  State<ModuloFinancieroScreen> createState() => _ModuloFinancieroScreenState();
}

class _ModuloFinancieroScreenState extends State<ModuloFinancieroScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();

  String _tipoOperacion = 'APORTE'; // 'APORTE' o 'RETIRO'

  // Saldo simulado o devuelto por la API local
  double _saldoActual = 25000.00;

  double get _montoIngresado {
    final textoLimpio = _montoController.text.replaceAll(',', '').trim();
    return double.tryParse(textoLimpio) ?? 0.0;
  }

  Future<void> _ejecutarTransaccion() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final financialProvider =
    Provider.of<FinancialProvider>(context, listen: false);

    final socioId = authProvider.currentUser?.id ?? 1;
    final nombreSocio = authProvider.usuarioNombre;
    final cedula = authProvider.currentUser?.cedula ?? '000-0000000-0';
    final concepto = _conceptoController.text.trim();

    // Validar fondos suficientes para retiros
    if (_tipoOperacion == 'RETIRO' && _montoIngresado > _saldoActual) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Fondos insuficientes para realizar este retiro.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Registrar en provider
    final exito = await financialProvider.registrarOperacion(
      socioId: socioId,
      tipoOperacion: _tipoOperacion,
      monto: _montoIngresado,
      concepto: concepto.isEmpty ? 'Operación de Caja' : concepto,
    );

    if (!mounted) return;

    if (exito) {
      setState(() {
        if (_tipoOperacion == 'APORTE') {
          _saldoActual += _montoIngresado;
        } else {
          _saldoActual -= _montoIngresado;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ ${_tipoOperacion == 'APORTE' ? 'Depósito' : 'Retiro'} procesado con éxito.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _mostrarDialogoImpresionTicket(
        nombreSocio: nombreSocio,
        cedula: cedula,
        tipoOperacion: _tipoOperacion,
        monto: _montoIngresado,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            financialProvider.error ?? 'Error al procesar la operación.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoImpresionTicket({
    required String nombreSocio,
    required String cedula,
    required String tipoOperacion,
    required double monto,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Transacción Registrada'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Socio: $nombreSocio'),
            Text('Cédula: $cedula'),
            Text('Tipo: ${tipoOperacion == 'APORTE' ? 'DEPÓSITO' : 'RETIRO'}'),
            Text('Monto: RD\$ ${monto.toStringAsFixed(2)}'),
            Text('Nuevo Saldo: RD\$ ${_saldoActual.toStringAsFixed(2)}'),
            const SizedBox(height: 12),
            const Text('¿Desea imprimir el ticket de caja térmico?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _limpiarFormulario();
            },
            child: const Text('Omitir'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.print),
            label: const Text('Imprimir Ticket (80mm)'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final financialProvider =
              Provider.of<FinancialProvider>(context, listen: false);

              await financialProvider.imprimirTicket(
                titulo: tipoOperacion == 'APORTE'
                    ? 'COMPROBANTE DEPÓSITO'
                    : 'COMPROBANTE RETIRO',
                nombreSocio: nombreSocio,
                cedula: cedula,
                tipoOperacion: tipoOperacion,
                monto: monto,
              );

              if (mounted) {
                _limpiarFormulario();
              }
            },
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _montoController.clear();
    _conceptoController.clear();
    _formKey.currentState?.reset();
    setState(() {
      _tipoOperacion = 'APORTE';
    });
  }

  @override
  void dispose() {
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final financialProvider = Provider.of<FinancialProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo Financiero / Caja'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TARJETA RESUMEN DE SALDO
              Card(
                color: Colors.teal.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.teal.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saldo Disponible',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RD\$ ${_saldoActual.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        radius: 24,
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: Colors.teal.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // SELECCIÓN DE TIPO DE OPERACIÓN
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipo de Operación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Depósito / Aporte'),
                              ),
                              selected: _tipoOperacion == 'APORTE',
                              selectedColor: Colors.green.shade100,
                              avatar: Icon(
                                Icons.arrow_downward,
                                color: _tipoOperacion == 'APORTE'
                                    ? Colors.green.shade800
                                    : Colors.grey,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _tipoOperacion = 'APORTE');
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ChoiceChip(
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Retiro de Caja'),
                              ),
                              selected: _tipoOperacion == 'RETIRO',
                              selectedColor: Colors.red.shade100,
                              avatar: Icon(
                                Icons.arrow_upward,
                                color: _tipoOperacion == 'RETIRO'
                                    ? Colors.red.shade800
                                    : Colors.grey,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _tipoOperacion = 'RETIRO');
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Monto
                      TextFormField(
                        controller: _montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Monto a Transaccionar (RD\$)',
                          prefixIcon: Icon(
                            _tipoOperacion == 'APORTE'
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: _tipoOperacion == 'APORTE'
                                ? Colors.green
                                : Colors.red,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingrese el monto de la transacción';
                          }
                          final parsed = double.tryParse(
                            value.replaceAll(',', '').trim(),
                          );
                          if (parsed == null || parsed <= 0) {
                            return 'El monto debe ser un valor numérico positivo';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Concepto
                      TextFormField(
                        controller: _conceptoController,
                        decoration: const InputDecoration(
                          labelText: 'Concepto / Descripción (Opcional)',
                          prefixIcon: Icon(Icons.notes),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // BOTÓN PROCESAR
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tipoOperacion == 'APORTE'
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: financialProvider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Icon(
                    _tipoOperacion == 'APORTE'
                        ? Icons.download_done
                        : Icons.upload,
                  ),
                  label: Text(
                    financialProvider.isLoading
                        ? 'Procesando...'
                        : 'Procesar ${_tipoOperacion == 'APORTE' ? 'Depósito' : 'Retiro'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: financialProvider.isLoading
                      ? null
                      : _ejecutarTransaccion,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}