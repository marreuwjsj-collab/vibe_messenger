sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

final class StorageException extends AppException {
  const StorageException(super.message);
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}
