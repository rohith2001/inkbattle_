import 'package:bloc/bloc.dart';
import 'package:inkbattle_frontend/models/auth/login_model.dart';
import 'package:inkbattle_frontend/repositories/auth_repo.dart';
part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  final AuthRepo _authRepo = AuthRepo();

  void login() async {
    try {
      emit(LoginLoadingState());
      var data = await _authRepo.login({});
      data.fold((error) {
        emit(LoginErrorState(error: error.message));
      }, (data) {
        emit(
          LoginLoadedState(
            model: data,
          ),
        );
      });
    } catch (e) {
      emit(LoginErrorState(error: e.toString()));
    }
  }
}
