import 'dart:convert';
import 'dart:ui';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:get/get.dart';

class Messagenftication extends GetxController {
  @override
  void onInit() {
    super.onInit();
    fetchUnreadMessages();
  }

  ApiService _api = ApiService();
  var messageCount = "".obs;
  Future<void> fetchUnreadMessages() async {
    try {
      String? token = await TokenService.getToken();
      if (token == null) return;

      Locale savedLocale = await LanguageService.getSavedLanguage();
      Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token",
      };

      var response =
          await _api.getrequst(linkuserprofile, headers: headers, "");
      final responseData = jsonDecode(response!.body);

      if (response.statusCode == 200) {
        messageCount.value = responseData['data']['message_count'];
        print("==================================${messageCount.value}");
      }
    } catch (e) {
      print("Error fetching messages: $e");
    }
  }
}
