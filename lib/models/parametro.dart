class Parametro {
  final String clave;
  final String valor;
  final String? descripcion;

  Parametro({
    required this.clave,
    required this.valor,
    this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'clave': clave,
    'valor': valor,
    'descripcion': descripcion,
  };

  factory Parametro.fromJson(Map<String, dynamic> json) => Parametro(
    clave: json['clave'],
    valor: json['valor'],
    descripcion: json['descripcion'],
  );
}