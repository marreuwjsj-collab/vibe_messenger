class AppFailure implements Exception {
  final String message;
  final Object? cause;
  const AppFailure(this.message, {this.cause});
  @override String toString() => message;
}

class NetworkFailure extends AppFailure { const NetworkFailure(super.message, {super.cause}); }
class StorageFailure extends AppFailure { const StorageFailure(super.message, {super.cause}); }
class AuthFailure extends AppFailure { const AuthFailure(super.message, {super.cause}); }
