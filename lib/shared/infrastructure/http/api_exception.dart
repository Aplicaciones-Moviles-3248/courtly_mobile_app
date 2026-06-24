/// ApiException
///
/// Excepcion tipada para los errores del cliente HTTP. Permite a la capa de
/// presentacion distinguir un problema de conectividad (servidor caido o
/// "despertando" en Render) de un error de negocio (credenciales invalidas,
/// recurso no encontrado, etc.).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// true cuando el fallo es de red, timeout o el servidor respondio 5xx
  /// (tipico del cold start de Render) tras agotar los reintentos.
  final bool isConnectivity;

  const ApiException(
    this.message, {
    this.statusCode,
    this.isConnectivity = false,
  });

  bool get isUnauthorized => statusCode == 401;

  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode, connectivity=$isConnectivity): $message';
}
