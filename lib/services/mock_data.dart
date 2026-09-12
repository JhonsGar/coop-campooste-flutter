import '../models/account.dart';
import '../models/movement.dart';
import '../models/loan.dart';
import '../models/producto.dart';
import '../models/user_model.dart';

class MockData {
  static User mockUser = User(
    id: 1,
    cedula: '001-1234567-8',
    nombreCompleto: 'Juan Pérez',
    email: 'juan@correo.com',
    telefono: '809-555-1234',
    direccion: 'Calle Principal #123, Santo Domingo',
    fechaIngreso: DateTime(2024, 1, 15),
    estado: 'activo',
  );

  static List<Account> mockAccounts = [
    Account(
      id: 1,
      numeroCuenta: '100001',
      tipoCuenta: 'ahorro_retirable',
      saldo: 25000.50,
      tasaInteres: 4.0,
      fechaApertura: DateTime(2024, 1, 15),
      estado: 'activa',
    ),
    Account(
      id: 2,
      numeroCuenta: '100002',
      tipoCuenta: 'ahorro_inversion',
      saldo: 120000.00,
      tasaInteres: 6.5,
      fechaApertura: DateTime(2024, 3, 20),
      estado: 'activa',
    ),
    Account(
      id: 3,
      numeroCuenta: '100003',
      tipoCuenta: 'aportacion',
      saldo: 5000.00,
      tasaInteres: 0.0,
      fechaApertura: DateTime(2024, 1, 15),
      estado: 'activa',
    ),
  ];

  static List<Movement> mockMovements = [
    Movement(
      id: 1,
      cuentaId: 1,
      tipoMovimiento: 'deposito',
      monto: 5000.00,
      saldoAnterior: 20000.50,
      saldoNuevo: 25000.50,
      descripcion: 'Depósito en efectivo',
      referencia: 'DEP-001',
      fechaTransaccion: DateTime(2025, 8, 28, 10, 30),
    ),
    Movement(
      id: 2,
      cuentaId: 1,
      tipoMovimiento: 'retiro',
      monto: 3000.00,
      saldoAnterior: 25000.50,
      saldoNuevo: 22000.50,
      descripcion: 'Retiro ATM',
      referencia: 'RET-002',
      fechaTransaccion: DateTime(2025, 8, 27, 15, 45),
    ),
    Movement(
      id: 3,
      cuentaId: 2,
      tipoMovimiento: 'interes',
      monto: 650.00,
      saldoAnterior: 119350.00,
      saldoNuevo: 120000.00,
      descripcion: 'Interés mensual',
      referencia: 'INT-003',
      fechaTransaccion: DateTime(2025, 8, 26, 9, 0),
    ),
  ];

  static List<Loan> mockLoans = [
    Loan(
      id: 1,
      montoAprobado: 50000.00,
      tasaInteres: 12.0,
      plazoMeses: 24,
      cuotaMensual: 2353.00,
      saldoPendiente: 35000.00,
      fechaAprobacion: DateTime(2025, 6, 10),
      fechaDesembolso: DateTime(2025, 6, 15),
      estado: 'desembolsado',
      tipoPrestamo: 'personal',
    ),
    Loan(
      id: 2,
      montoAprobado: 15000.00,
      tasaInteres: 8.0,
      plazoMeses: 12,
      cuotaMensual: 1304.00,
      saldoPendiente: 13040.00,
      fechaAprobacion: DateTime(2025, 8, 1),
      fechaDesembolso: DateTime(2025, 8, 5),
      estado: 'desembolsado',
      tipoPrestamo: 'electrodomesticos',
    ),
  ];

  static List<Producto> mockProducts = [
    Producto(
      id: 1,
      nombre: 'Refrigeradora Samsung 18 pies',
      descripcion: 'Refrigeradora de acero avoidable',
      categoria: 'electrodomesticos',
      precio: 45000.00,
      stock: 5,
      imagenUrl: '',
      proveedor: 'Importadora ABC',
      estado: 'activo', // ✅ Agregado
    ),
    Producto(
      id: 2,
      nombre: 'Kit de útiles escolares',
      descripcion: 'Set completo para estudiante',
      categoria: 'utiles_escolares',
      precio: 3500.00,
      stock: 20,
      imagenUrl: '',
      proveedor: 'Papelería Central',
      estado: 'activo', // ✅ Agregado
    ),
    Producto(
      id: 3,
      nombre: 'Laptop Lenovo ThinkPad',
      descripcion: 'Intel i7, 16GB RAM, SSD 512GB',
      categoria: 'tecnologia',
      precio: 85000.00,
      stock: 2,
      imagenUrl: '',
      proveedor: 'Tech Import',
      estado: 'activo', // ✅ Agregado
    ),
  ];
}