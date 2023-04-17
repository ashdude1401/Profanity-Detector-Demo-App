import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ImageUrlController extends GetxController {
  static const rapidApiKey =
      '93e5c2d1b4mshadbd5cf664e05e7p10ecd5jsn8df525febdb2';
  static const rapidApiHost = 'nsfw-image-classification1.p.rapidapi.com';

  final Uri url = Uri.parse('https://$rapidApiHost/img/nsfw');

  final Map<String, String> headers = {
    'content-type': 'application/json',
    'X-RapidAPI-Key': rapidApiKey,
    'X-RapidAPI-Host': rapidApiHost,
  };

  Future<void> classifyImage(String imageUrl) async {
    final body = jsonEncode({
      'url': imageUrl,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      final jsonResponse = jsonDecode(response.body);

      print(jsonResponse.toString());

      Get.snackbar(
        'Api Error',
        jsonResponse['message'],
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
      );
      // do something with jsonResponse
    } catch (error) {
      print(error);
    }
  }
}
