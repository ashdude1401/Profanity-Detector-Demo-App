import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ContentModerationController extends GetxController {
  static const rapidApiKey =
      '93e5c2d1b4mshadbd5cf664e05e7p10ecd5jsn8df525febdb2';
  static const rapidApiHost = 'nsfw-content-detector.p.rapidapi.com';

  final Uri url = Uri.parse('https://$rapidApiHost/content-moderation');

  final Map<String, String> headers = {
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': rapidApiHost,
  };

  Future<void> sendRequest(File file) async {
    final bytes = await file.readAsBytes();

    final formData = http.MultipartRequest('POST', url)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.path.split('/').last,
        ),
      );

    try {
      final response = await http.Response.fromStream(await formData.send());
      final jsonResponse = jsonDecode(response.body);

      print(jsonResponse.toString());
      // do something with jsonResponse
    } catch (error) {
      print(error);
    }
  }
}
