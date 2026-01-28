class ApiConfig {
  // TODO: Configurar la URL base de la API según tu entorno
  // Ejemplo: 'http://localhost:3000' para desarrollo local
  // Ejemplo: 'https://tu-api-produccion.com' para producción
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.24:3000',
  );
}
