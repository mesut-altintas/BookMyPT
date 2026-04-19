abstract class AppError implements Exception {
  final String message;
  const AppError(this.message);

  @override
  String toString() => message;
}

class AuthError extends AppError {
  const AuthError(super.message);
}

class FirestoreError extends AppError {
  const FirestoreError(super.message);
}

class ValidationError extends AppError {
  const ValidationError(super.message);
}

class NotFoundError extends AppError {
  const NotFoundError(super.message);
}

class PermissionError extends AppError {
  const PermissionError(super.message);
}
