import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothScanService {
  static const List<String> _prefijosImpresoras = [
    'POS',
    'PRINTER',
    'THERMAL',
    'MTP',
    'RPP',
    'MPT',
    'MINIPRINT',
    'INNERPRINTER',
    'BLUEPRINTER',
  ];

  /// Solicita los permisos necesarios según la versión de Android
  static Future<bool> solicitarPermisos() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    final scanConcedido = statuses[Permission.bluetoothScan]?.isGranted ?? true;
    final connectConcedido = statuses[Permission.bluetoothConnect]?.isGranted ?? true;
    final locationConcedido = statuses[Permission.locationWhenInUse]?.isGranted ?? true;

    return scanConcedido && connectConcedido && locationConcedido;
  }

  /// Verifica si el adaptador Bluetooth está encendido
  static Future<bool> estaBluetoothEncendido() async {
    final state = await FlutterBluePlus.adapterState.first;
    return state == BluetoothAdapterState.on;
  }

  /// Evalúa si el nombre del dispositivo coincide con una impresora térmica
  static bool esImpresoraTermica(String nombreDispositivo) {
    if (nombreDispositivo.trim().isEmpty) return false;
    final nombreUpper = nombreDispositivo.toUpperCase();
    return _prefijosImpresoras.any((prefijo) => nombreUpper.contains(prefijo));
  }

  /// Inicia el escaneo de dispositivos cercanos
  static Future<void> iniciarEscaneo({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
    await FlutterBluePlus.startScan(timeout: timeout);
  }

  /// Detiene el escaneo activo
  static Future<void> detenerEscaneo() async {
    if (FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }
}