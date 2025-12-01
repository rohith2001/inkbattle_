import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:inkbattle_frontend/utils/preferences/local_preferences.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'api_exceptions.dart';
import 'error_model.dart';

const String jsonContentType = 'application/json';
String? token = "";

class ApiManager {
  Future _getToken() async {
    token = await LocalStorageUtils.fetchToken();
    print("TOKEN:: $token");
  }

  var httpClient = http.Client();
  final Dio _client = Dio();

  Future<dynamic> get(
    String? url, {
    String? contentType,
    bool isTokenMandatory = false,
  }) async {
    await _getToken();
    try {
      Map<String, String> headers = {
        'Content-Type': contentType ?? jsonContentType,
      };
      if (isTokenMandatory && token != null && token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      log("\x1B[32m${"URL -> $url"}\x1B[0m");
      final response = await http.get(
        Uri.parse(url ?? ""),
        headers: headers,
      );
      var responseJson = _returnResponse(response);
      return responseJson;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> post(
    String? url,
    var parameters, {
    String contentType = jsonContentType,
    bool isTokenMandatory = false,
    Map<String, String>? headersParams,
  }) async {
    await _getToken();
    try {
      Map<String, String> headers = {
        'Content-Type': contentType,
      };
      if (headersParams != null) {
        headers.addAll(headersParams);
      }
      if (isTokenMandatory && token != null && token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.post(
        Uri.parse(url ?? ""),
        headers: headers,
        body: jsonEncode(parameters),
      );

      log("\x1B[35m${"Payload -> $parameters"}\x1B[0m");
      log('\x1B[32m${"URL -> ${response.request?.url}"}\x1B[0m');
      // log("\x1B[35m${'Response body -> ${response.body}'}\x1B[0m");
      log("URL -> ${response.request?.url}");

      var responseJson = _returnResponse(response);
      return responseJson;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> put(
    String? url,
    var parameters, {
    String contentType = jsonContentType,
    bool isTokenMandatory = false,
  }) async {
    await _getToken();
    try {
      Map<String, String> headers = {
        'Content-Type': contentType,
      };

      if (isTokenMandatory && token != null && token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      final response = await http.put(
        Uri.parse(url ?? ""),
        headers: headers,
        body: jsonEncode(parameters),
      );
      log("\x1B[35m${"Payload -> $parameters"}\x1B[0m");
      log('\x1B[32m${"URL -> ${response.request?.url}"}\x1B[0m');
      // log("\x1B[35m${'Response body -> ${response.body}'}\x1B[0m");
      log("URL -> ${response.request?.url}");

      var responseJson = _returnResponse(response);
      return responseJson;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future<dynamic> delete(
    String? url, {
    String contentType = jsonContentType,
    bool isTokenMandatory = true,
  }) async {
    await _getToken();
    try {
      Map<String, String> headers = {
        'Content-Type': contentType,
      };

      if (isTokenMandatory && token != null && token!.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.delete(
        Uri.parse(url ?? ""),
        headers: headers,
      );

      log('\x1B[32m${"URL -> ${response.request?.url}"}\x1B[0m');
      log("\x1B[31m${'Response body -> ${response.body}'}\x1B[0m");

      var responseJson = _returnResponse(response);
      return responseJson;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  Future dioPutFile(
      {required String? url,
      XFile? uploadFile,
      required int fileLength,
      dynamic data,
      String? contentType}) async {
    Options options = Options(
        contentType: contentType ?? lookupMimeType(uploadFile?.path ?? ""),
        headers: {
          'Accept': "*/*",
          'Content-Length': fileLength,
          'Connection': 'keep-alive',
        });

    final response = await _client.put(url ?? "",
        data: data ?? uploadFile?.openRead(),
        options: options, onSendProgress: (val1, val2) {
      log("${val1 / val2 * 100}");
    });
    log("Res ${response.statusCode}");
    if (response.statusCode == 200) {
      log("file upload successfully");
    }
  }

  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body);
        log("Response Json ${response.statusCode} -> ${responseJson.toString()}");

        if (responseJson['url'] != '') {
          return responseJson;
        }
        if (responseJson['status'] != "Success") {
          throw BadRequestException(
            '${responseJson['message']}',
            responseJson,
          );
        }
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body);
        log("Response Json ${response.statusCode} -> ${responseJson.toString()}");

        if (responseJson['status'] == false) {
          throw BadRequestException(
            '${responseJson['message']}',
            responseJson,
          );
        }
        return responseJson;
      case 400:
        ErrorModel errorModel = ErrorModel.fromJson(json.decode(response.body));
        log("\x1B[31m${"ErrorModel ${response.statusCode} -> ${errorModel.message}"}\x1B[0m");
        throw BadRequestException(
          '${errorModel.message}',
          errorModel.toJson(),
        );
      case 401:
        ErrorModel errorModel = ErrorModel.fromJson(json.decode(response.body));
        log("\x1B[31m${"ErrorModel ${response.statusCode} -> ${errorModel.message}"}\x1B[0m");

        throw UnauthorisedException(
          'Err:${response.statusCode} ${errorModel.message}',
          errorModel.toJson(),
        );

      case 403:
      case 404:
        ErrorModel errorModel = ErrorModel.fromJson(json.decode(response.body));
        log("\x1B[31m${"ErrorModel ${response.statusCode} -> ${errorModel.message}"}\x1B[0m");
        throw UnauthorisedException(
          '${errorModel.message}',
          errorModel.toJson(),
        );
      case 500:
        ErrorModel errorModel = ErrorModel.fromJson(json.decode(response.body));
        log("\x1B[31m${"ErrorModel ${response.statusCode} -> ${errorModel.message}"}\x1B[0m");
        var decodedJson = json.decode(response.body);
        String error = decodedJson["message"];
        throw FetchDataException(
          ' $error',
          errorModel.toJson(),
        );
      default:
        ErrorModel errorModel = ErrorModel.fromJson(json.decode(response.body));
        log("\x1B[31m${"ErrorModel ${response.statusCode} -> ${errorModel.message}"}\x1B[0m");
        throw FetchDataException(
          '${errorModel.message}',
          errorModel.toJson(),
        );
    }
  }
}
