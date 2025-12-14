
import 'package:dartz/dartz.dart';
import 'package:inkbattle_frontend/constants/api_end_points.dart';
import 'package:inkbattle_frontend/utils/api/api_exceptions.dart';
import 'package:inkbattle_frontend/utils/api/api_manager.dart';
import 'package:inkbattle_frontend/utils/api/failure.dart';

class AgoraRepository {

  final ApiManager _apiManager = ApiManager();


  Future<Either<Failure, String>> getAgoraToken(String channel, String uid)async{
    try {
      final response = await _apiManager.get("${ApiEndPoints.agoraToken}?channel=$channel&uid=$uid",isTokenMandatory: true );
    /*
            token: token,
            appId: AGORA_APP_ID,
            channelName: channelName,
            uid: userId
    */
    
    
    return right(response['token']);
      
    } on AppException catch (e) {
          print(e.message);

      return left(ApiFailure(message: e.message));
    } catch (e) {
      print(e);
      return left(ApiFailure(message: e.toString()));
    }
  }
}