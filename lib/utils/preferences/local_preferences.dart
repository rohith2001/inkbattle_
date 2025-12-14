import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageUtils {
  static late final SharedPreferences instance;

  static Future<SharedPreferences> init() async =>
      instance = await SharedPreferences.getInstance();

//  static JwtTokeResponseModel get tokenResponseModel => userData();

  static Future<void> saveUserDetails(String token) async {
    await instance.setString("token", token);
    log("Token saved!");
  }

  static Future<void> saveGeoLocation(double lat, double lon) async {
    await instance.setDouble("latitude", lat);
    await instance.setDouble("longitude", lon);
    log("Geo Location Saved");
  }

  static double? getLatitude() {
    final latitude = instance.getDouble('latitude');
    return latitude;
  }

  static Future<void> setDistance(double distance) async {
    await instance.setDouble("distance", distance);
    log("Distace Saved $distance");
  }

  static double? getDistance() {
    final distance = instance.getDouble('distance');
    final meter = (distance ?? 40) * 1000;
    return meter;
  }

  static double? getLongitude() {
    final latitude = instance.getDouble('longitude');
    return latitude;
  }

  static Future<String?> fetchToken() async {
    try {
      final token = instance.getString('token');

      if (token == null || token.isEmpty) {
        return null;
      }
      print(token);
      return token;
    } catch (e) {
      log('Error fetching token: $e');
      return null;
    }
  }

  static Future<void> clear() async {
    instance.remove('token');
    await instance.clear();
  }

  static Future<bool> showTutorial() async {
    return instance.getBool('tutorialShown') ?? false;
  }

  static Future<void> setTutorialShown(bool shown) async {
    print('Tutorial shown status updated to $shown');
    await instance.setBool('tutorialShown', shown);
  }

  static Future<double> setVolume(double vol) async {
    await instance.setDouble('volume', vol);
    return vol;
  }

  static Future<double> getVolume() async {
    final vol = instance.getDouble('volume') ?? 1;
    return vol;
  }

  // Language storage
  static Future<void> saveLanguage(String languageCode) async {
    await instance.setString('app_language', languageCode);
    log('Language saved: $languageCode');
  }

  static String getLanguage() {
    return instance.getString('app_language') ?? 'en';
  }

  // static JwtTokeResponseModel userData() {
  //   final token = instance.getString('token') ?? '';
  //   var userData = JwtDecoder.decode(token);
  //   var userDecoded = JwtTokeResponseModel.fromJson(userData);
  //   return userDecoded;
  // }
}
