sealed class AppException implements Exception {
  const AppException();
}

class ServerException extends AppException {
  const ServerException({this.statusCode});

  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException();
}

class TimeoutException extends AppException {
  const TimeoutException();
}

class CancelledException extends AppException {
  const CancelledException();
}

class CacheException extends AppException {
  const CacheException();
}
