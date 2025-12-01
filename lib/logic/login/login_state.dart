part of 'login_cubit.dart';

abstract class LoginState {
  LoginModel? model;
  LoginState({this.model});
}

final class LoginInitial extends LoginState {
  LoginInitial({super.model});
}

final class LoginLoadingState extends LoginState {
  LoginLoadingState({super.model});
}

final class LoginLoadedState extends LoginState {
  LoginLoadedState({super.model});
}

final class LoginErrorState extends LoginState {
  final String? error;
  LoginErrorState({this.error, super.model});
}
