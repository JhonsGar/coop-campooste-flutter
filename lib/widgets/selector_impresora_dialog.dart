import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:coop_campooste/services/bluetooth_scan_service.dart';

class SelectorImpresoraDialog extends StatefulWidget {
  const SelectorImpresoraDialog({super.key});

  @override
  State<SelectorImpresoraDialog> createState() =>
      _SelectorImpresoraDialogState();
}

class _SelectorImpresoraDialogState extends State<SelectorImpresoraDialog> {
  bool _cargandoPermisos = true;
  bool _permisosConcedidos = false;

  @override
  void initState() {
    super.initState();
    _inicializarEscaneo();
  }

  Future<void> _inicializarEscaneo() async {
    final tienePermisos = await BluetoothScanService.solicitarPermisos();
    final bluetoothOn = await BluetoothScanService.estaBluetoothEncendido();

    if (!mounted) return;

    if (!tienePermisos || !bluetoothOn) {
      setState(() {
        _cargandoPermisos = false;
        _permisosConcedidos = false;
      });
      return;
    }

    setState(() {
      _cargandoPermisos = false;
      _permisosConcedidos = true;
    });

    await BluetoothScanService.iniciarEscaneo();
  }

  @override
  void dispose() {
    BluetoothScanService.detenerEscaneo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.print, color: Colors.teal),
          SizedBox(width: 8),
          Text('Impresoras Disponibles'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: _cargandoPermisos
            ? const Center(child: CircularProgressIndicator())
            : !_permisosConcedidos
            ? const Center(
          child: Text(
            'Se requieren permisos de Bluetooth y Ubicación para escanear dispositivos.',
            textAlign: TextAlign.center,
          ),
        )
            : StreamBuilder<List<ScanResult>>(
          stream: FlutterBluePlus.scanResults,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Buscando impresoras cercanas...'),
                  ],
                ),
              );
            }

            final listaDispositivos = snapshot.data!;

            return ListView.builder(
              itemCount: listaDispositivos.length,
              itemBuilder: (context, index) {
                final result = listaDispositivos[index];
                final nombre = result.device.platformName.isNotEmpty
                    ? result.device.platformName
                    : 'Dispositivo sin nombre';

                final esImpresora =
                BluetoothScanService.esImpresoraTermica(nombre);

                return Card(
                  color: esImpresora ? Colors.teal.shade50 : null,
                  child: ListTile(
                    leading: Icon(
                      Icons.print,
                      color: esImpresora ? Colors.teal : Colors.grey,
                    ),
                    title: Text(
                      nombre,
                      style: TextStyle(
                        fontWeight: esImpresora
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      '${result.device.remoteId.str} | RSSI: ${result.rssi} dBm',
                    ),
                    trailing: esImpresora
                        ? const Chip(
                      label: Text(
                        'Impresora',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      backgroundColor: Colors.teal,
                    )
                        : null,
                    onTap: () async {
                      await BluetoothScanService.detenerEscaneo();
                      if (context.mounted) {
                        Navigator.of(context).pop(result.device);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await BluetoothScanService.detenerEscaneo();
            if (context.mounted) Navigator.of(context).pop(null);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}