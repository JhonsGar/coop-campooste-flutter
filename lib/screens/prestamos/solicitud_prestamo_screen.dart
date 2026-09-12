import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coop_campooste/providers/auth_provider.dart';
import 'package:coop_campooste/providers/financial_provider.dart';

class SolicitudPrestamoScreen extends StatefulWidget {
  const SolicitudPrestamoScreen({super.key});

  @override
  State<SolicitudPrestamoScreen> createState() =>
      _SolicitudPrestamoScreenState();
}

class _SolicitudPrestamoScreenState extends State<SolicitudPrestamoScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();

  double _tasaInteresAnual = 18.0;
  int _plazoMeses = 12;

  final List<int> _opcionesPlazos = [6, 12, 18, 24, 36, 48, 60];

  double get _montoSolicitado =>
      double.tryParse(_montoController.text.replaceAll(',', '')) ?? 0.0;

  double get _cuotaMensual {
    final p = _montoSolicitado;
    if (p <= 0) return 0.0;

    final i = (_tasaInteresAnual / 100) / 12;
    final n = _plazoMeses;

    if (i == 0) return p / n;

    return (p * i * pow(1 + i, n)) / (pow(1 + i, n) - 1);
  }

  double get _totalIntereses => (_cuotaMensual * _plazoMeses) - _montoSolicitado;
  double get _totalPagar => _cuotaMensual * _plazoMeses;

  Future<void> _procesarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final financialProvider =
    Provider.of<FinancialProvider>(context, listen: false);

    // Se extrae y utiliza la variable socioId
    final socioId = authProvider.currentUser?.id ?? 1;
    final nombreSocio = authProvider.usuarioNombre;
    final cedula = authProvider.currentUser?.cedula ?? '000-0000000-0';

    final exito = await financialProvider.gestionarPrestamo(
      prestamoId: socioId, // socioId utilizado en el parámetro
      accion: 'SOLICITAR',
    );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Solicitud de préstamo enviada exitosamente.'),
          backgroundColor: Colors.green,
        ),
      );

      _mostrarDialogoImpresion(
        nombreSocio: nombreSocio,
        cedula: cedula,
        monto: _montoSolicitado,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            financialProvider.error ?? 'Error al procesar la solicitud.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoImpresion({
    required String nombreSocio,
    required String cedula,
    required double monto,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Solicitud Registrada'),
        content: const Text(
          '¿Desea imprimir el comprobante térmico de la solicitud?',
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
            icon: const Icon(Icons.print),
            label: const Text('Imprimir Ticket'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final financialProvider =
              Provider.of<FinancialProvider>(context, listen: false);

              await financialProvider.imprimirTicket(
                titulo: 'SOLICITUD DE PRÉSTAMO',
                nombreSocio: nombreSocio,
                cedula: cedula,
                tipoOperacion: 'PRÉSTAMO ($_plazoMeses MESES)',
                monto: monto,
              );

              _limpiarFormulario();
            },
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _montoController.clear();
    _conceptoController.clear();
    setState(() {
      _plazoMeses = 12;
      _tasaInteresAnual = 18.0;
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
        title: const Text('Solicitud de Préstamo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        'Datos del Préstamo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _montoController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Monto Solicitado (RD\$)',
                          prefixIcon: Icon(Icons.monetization_on),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un monto válido';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'El monto debe ser mayor a 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Cambio clave: 'initialValue' reemplaza al parámetro depreciado 'value'
                      DropdownButtonFormField<int>(
                        initialValue: _plazoMeses,
                        decoration: const InputDecoration(
                          labelText: 'Plazo (Meses)',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        items: _opcionesPlazos.map((meses) {
                          return DropdownMenuItem<int>(
                            value: meses,
                            child: Text('$meses Meses (${meses ~/ 12} años)'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _plazoMeses = val);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tasa de Interés Anual: ${_tasaInteresAnual.toStringAsFixed(1)}% (${(_tasaInteresAnual / 12).toStringAsFixed(2)}% mensual)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Slider(
                        value: _tasaInteresAnual,
                        min: 8.0,
                        max: 36.0,
                        divisions: 28,
                        label: '${_tasaInteresAnual.toStringAsFixed(1)}%',
                        activeColor: Colors.indigo,
                        onChanged: (val) {
                          setState(() => _tasaInteresAnual = val);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _conceptoController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Concepto / Destiny del Préstamo',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.indigo.shade50,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.indigo.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Resumen de Estimación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const Divider(height: 20),
                      _buildDetalleFila(
                        'Cuota Mensual Estimada:',
                        'RD\$ ${_cuotaMensual.toStringAsFixed(2)}',
                        isDestacado: true,
                      ),
                      const SizedBox(height: 8),
                      _buildDetalleFila(
                        'Total de Intereses:',
                        'RD\$ ${_totalIntereses.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildDetalleFila(
                        'Monto Total a Pagar:',
                        'RD\$ ${_totalPagar.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
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
                      : const Icon(Icons.send),
                  label: Text(
                    financialProvider.isLoading
                        ? 'Procesando...'
                        : 'Enviar Solicitud',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: financialProvider.isLoading
                      ? null
                      : _procesarSolicitud,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetalleFila(
      String titulo,
      String valor, {
        bool isDestacado = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: isDestacado ? 15 : 14,
            fontWeight: isDestacado ? FontWeight.bold : FontWeight.normal,
            color: isDestacado ? Colors.indigo.shade900 : Colors.black87,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: isDestacado ? 17 : 14,
            fontWeight: FontWeight.bold,
            color: isDestacado ? Colors.indigo.shade900 : Colors.black87,
          ),
        ),
      ],
    );
  }
}