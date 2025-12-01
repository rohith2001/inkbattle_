import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/models/auth/login_model.dart';
import 'package:inkbattle_frontend/utils/api/api_exceptions.dart';
import 'package:inkbattle_frontend/utils/api/api_manager.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';

class AuthRepo {
  final ApiManager _apiManager = ApiManager();

  Future<Either<Failure, LoginModel>> login(payload) async {
    try {
      var jsonResponse = await _apiManager.post(
        "",
        payload,
        isTokenMandatory: true,
      );
      var json = LoginModel.fromJson(jsonResponse);
      return right(json);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }
}
