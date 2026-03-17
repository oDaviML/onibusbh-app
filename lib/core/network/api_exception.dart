sealed class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException([super.message = 'Sem conexão com a internet']);
}

class ServerException extends ApiException {
  final int? statusCode;
  const ServerException({String message = 'Erro no servidor', this.statusCode})
    : super(message);

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class TimeoutException extends ApiException {
  const TimeoutException([super.message = 'A requisição demorou muito']);
}

class UnknownException extends ApiException {
  final Object? error;
  const UnknownException({String message = 'Erro desconhecido', this.error})
    : super(message);
}
