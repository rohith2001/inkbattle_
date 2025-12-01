// ignore_for_file: prefer_typing_uninitialized_variables

class AppException implements Exception {
  final message;
  final prefix;
  final extraInfo;

  AppException([
    this.message,
    this.prefix,
    this.extraInfo,
  ]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([
    String? message,
    extraInfo,
  ]) : super(
          message,
          "Error During Communication: ",
          extraInfo,
        );
}

class BadRequestException extends AppException {
  BadRequestException([
    message,
    extraInfo,
  ]) : super(
          message,
          "Invalid Request: ",
          extraInfo,
        );
}

class UnauthorisedException extends AppException {
  UnauthorisedException([
    message,
    extraInfo,
  ]) : super(
          message,
          "Unauthorised: ",
          extraInfo,
        );
}

class InvalidInputException extends AppException {
  InvalidInputException([
    String? message,
    extraInfo,
  ]) : super(
          message,
          "Invalid Input: ",
          extraInfo,
        );
}
