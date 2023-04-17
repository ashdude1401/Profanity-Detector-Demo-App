import 'dart:convert';

import 'package:get/get.dart';

import '../helper/dialog_helper.dart';
import '../services/app_exceptions.dart';
import '../services/base_client.dart';
import 'base_controller.dart';

class TestController extends GetxController with BaseController {
  var baseUrl =
      "https://profanity-toxicity-detection-for-user-generated-content.p.rapidapi.com/";

  void getData() async {
    showLoading('Fetching data');
    var response =
        await BaseClient().get(baseUrl, '/todos/1').catchError(handleError);
    if (response == null) return;
    hideLoading();
    print(response);
  }

  void postData(Map<String, dynamic> data) async {
    var request = data;
    showLoading('Posting data...');
    var response = await BaseClient().post(request).catchError((error) {
      if (error is BadRequestException) {
        var apiError = json.decode(error.message!);
        DialogHelper.showErroDialog(description: apiError["reason"]);
      } else {
        handleError(error);
      }
    });
    if (response == null) return;
    hideLoading();
    print(response);
  }
}
