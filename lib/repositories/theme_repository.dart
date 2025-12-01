import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/constants/api_end_points.dart';
import 'package:inkbattle_frontend/models/theme_model.dart';
import 'package:inkbattle_frontend/utils/api/api_exceptions.dart';
import 'package:inkbattle_frontend/utils/api/api_manager.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';

class ThemeRepository {
  final ApiManager _apiManager = ApiManager();

  // Get all themes
  Future<Either<Failure, ThemeListResponse>> getThemes() async {
    try {
      var jsonResponse = await _apiManager.get(
        ApiEndPoints.getThemes,
        isTokenMandatory: true,
      );

      var themeListResponse = ThemeListResponse.fromJson(jsonResponse);
      return right(themeListResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Get random word from theme
  Future<Either<Failure, RandomWordResponse>> getRandomWord({
    required String themeId,
  }) async {
    try {
      var jsonResponse = await _apiManager.get(
        ApiEndPoints.getRandomWord(themeId),
        isTokenMandatory: true,
      );

      var randomWordResponse = RandomWordResponse.fromJson(jsonResponse);
      return right(randomWordResponse);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }

  // Get all categories (themes)
  Future<Either<Failure, List<Map<String, dynamic>>>> getCategories() async {
    try {
      var jsonResponse = await _apiManager.get(
        ApiEndPoints.getCategories,
        isTokenMandatory: true,
      );

      List<dynamic> categoriesList = jsonResponse['categories'] ?? [];
      List<Map<String, dynamic>> categories = categoriesList
          .map((cat) => cat as Map<String, dynamic>)
          .toList();

      return right(categories);
    } on AppException catch (e) {
      return left(ApiFailure(message: e.message));
    } catch (e) {
      return left(ApiFailure(message: e.toString()));
    }
  }
}
