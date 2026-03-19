class ApiEndpoints {
  static const String baseUrl = 'https://busapi.davimartinslage.com.br/';

  static const String lines = '/api/v1/lines';
  static String lineShape(String id) => '/api/v1/lines/$id/shape';
  static String lineStops(String id) => '/api/v1/lines/$id/stops';
  static String lineVehicles(String id) => '/api/v1/lines/$id/vehicles';

  static const String stops = '/api/v1/stops';
  static String stopPredictions(String id) => '/api/v1/stops/$id/predictions';
}
