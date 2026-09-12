import 'socio.dart';

class AuthResponse {
  final String accessToken;
  final Socio socio;

  AuthResponse({
    required this.accessToken,
    required this.socio,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Soporta tanto 'access_token' como 'accessToken'
    final token = (json['access_token'] ?? json['accessToken']) as String? ?? '';

    // Soporta si la respuesta devuelve 'socio', 'user' o los datos directamente en la raíz
    final socioData = json['socio'] ?? json['user'] ?? json;

    return AuthResponse(
      accessToken: token,
      socio: Socio.fromJson(socioData as Map<String, dynamic>),
    );
  }
}