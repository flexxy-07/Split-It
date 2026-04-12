abstract class Failure {
  final String message;
  const Failure({required this.message});

  String get userMessage => message;
}

class ValidationFailure extends Failure {
  final String field;
  const ValidationFailure({required String message, required this.field})
      : super(message: message);
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class AuthFailure extends Failure {
  final String? code;
  const AuthFailure({required String message, this.code})
      : super(message: message);
}

class UnexpectedFailure extends Failure {
  final StackTrace? stackTrace;
  const UnexpectedFailure({required String message, this.stackTrace})
      : super(message: message);
}
