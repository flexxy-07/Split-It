abstract class Failure {
  final String message;
  const Failure({required this.message});

  String get userMessage => message;
}

class ValidationFailure extends Failure {
  final String field;
  const ValidationFailure({required super.message, required this.field});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class AuthFailure extends Failure {
  final String? code;
  const AuthFailure({required super.message, this.code});
}

class UnexpectedFailure extends Failure {
  final StackTrace? stackTrace;
  const UnexpectedFailure({required super.message, this.stackTrace});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class FirestoreFailure extends Failure {
  const FirestoreFailure({required super.message});
}
