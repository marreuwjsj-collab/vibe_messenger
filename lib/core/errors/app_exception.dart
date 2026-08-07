sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  const AppException(this.message, {this.cause});
  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode, super.cause});
}

final class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.cause});
}

final class StorageException extends AppException {
  const StorageException(super.message, {super.cause});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause});
}
