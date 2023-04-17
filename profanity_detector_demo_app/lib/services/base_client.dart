import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'app_exceptions.dart';

class BaseClient {
  final String rapidApiKey =
      '93e5c2d1b4mshadbd5cf664e05e7p10ecd5jsn8df525febdb2';
  final String rapidApiHost =
      'profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com';

  Uri url = Uri.parse(
      'https://profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com/');

  var baseUrl =
      "https://profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com/";

  final Map<String, String> headers=  {
  'content-type': 'application/x-www-form-urlencoded',
  'X-RapidAPI-Key': '93e5c2d1b4mshadbd5cf664e05e7p10ecd5jsn8df525febdb2',
  'X-RapidAPI-Host': 'profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com',
};

  static const int TIME_OUT_DURATION = 20;
  //GET
  Future<dynamic> get(String baseUrl, String api) async {
    var uri = Uri.parse(baseUrl + api);
    try {
      var response =
          await http.get(uri).timeout(Duration(seconds: TIME_OUT_DURATION));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //POST
  Future<dynamic> post( dynamic payloadObj) async {
    var uri = Uri.parse(baseUrl);

     final Map<String, String> body = {'text': 'You idiot! I will find where you live and kick your ass!'};
  final encodedParams = Uri(queryParameters: body).query;
    var payload = json.encode(payloadObj);
    try {
      var response = await http
          .post(
            uri,
            body: encodedParams,
            headers: headers,
          )
          .timeout(Duration(seconds: TIME_OUT_DURATION));
      return _processResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection', uri.toString());
    } on TimeoutException {
      throw ApiNotRespondingException(
          'API not responded in time', uri.toString());
    }
  }

  //DELETE
  //OTHER

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
        break;
      case 201:
        var responseJson = utf8.decode(response.bodyBytes);
        return responseJson;
        break;
      case 400:
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 401:
      case 403:
        throw UnAuthorizedException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 422:
        throw BadRequestException(
            utf8.decode(response.bodyBytes), response.request!.url.toString());
      case 500:
      default:
        throw FetchDataException(
            'Error occured with code : ${response.statusCode}',
            response.request!.url.toString());
    }
  }
}
