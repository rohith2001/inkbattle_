import 'package:inkbattle_frontend/config/environment.dart';

class ApiEndPoints {
  static String get baseUrl => Environment.apiBaseUrl;

  // Auth endpoints
  static String get signup => "$baseUrl/auth/signup";
  static String get logout => "$baseUrl/auth/logout";
  static String get updateProfile => "$baseUrl/auth/updateProfile";

  // User endpoints
  static String get getMe => "$baseUrl/users/me";
  static String get addCoins => "$baseUrl/users/add-coins";
  static String get claimDailyBonus => "$baseUrl/users/claim-daily-bonus";
  static String get dailyBonusStatus => "$baseUrl/users/daily-bonus-status";
  static String get claimAdReward => "$baseUrl/users/claim-ad-reward";
  static String get getLanguages => "$baseUrl/users/languages";

  // Room endpoints
  static String get rooms => "$baseUrl/rooms";
  static String get createRoom => "$baseUrl/rooms/create";
  static String get joinRoom => "$baseUrl/rooms/join";
  static String get joinRoomById => "$baseUrl/rooms/join-by-id";
  static String get playRandom => "$baseUrl/rooms/play-random";
  static String get createPublicRoom => "$baseUrl/rooms/create-public";
  static String get createTeamRoom => "$baseUrl/rooms/create-team";
  static String get listRooms => "$baseUrl/rooms/list";
  static String getRoomDetails(String roomId) => "$baseUrl/rooms/$roomId";
  static String leaveRoom(String roomId) => "$baseUrl/rooms/$roomId/leave";
  static String get report => "$baseUrl/report/";
  // Theme endpoints
  static String get getThemes => "$baseUrl/themes";
  static String get getCategories => "$baseUrl/themes/categories";
  static String getRandomWord(String themeId) =>
      "$baseUrl/themes/$themeId/random";

  // Agora Tokens
  static String get agoraToken => "$baseUrl/agora/token";
}
