enum FailureType {
  authFailure,
  locationFailure,
  apiFailure,
  unVerifiedUserFailure
}

class Failure {
  final String message;
  final FailureType failureType;

  Failure(this.message, this.failureType);
}

class AuthFailure extends Failure {
  AuthFailure({required String message})
      : super(message, FailureType.authFailure);
}

class LocationFailure extends Failure {
  LocationFailure({required String message})
      : super(message, FailureType.locationFailure);
}

class UnVerifiedUserFailure extends Failure {
  UnVerifiedUserFailure({required String message})
      : super(message, FailureType.unVerifiedUserFailure);
}

class ApiFailure extends Failure {
  ApiFailure({required String message})
      : super(message, FailureType.apiFailure);
}
