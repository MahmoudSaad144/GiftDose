import 'dart:convert';

import 'dart:ui';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController1 extends GetxController {
  var isLoading = false.obs;
  var name = "".obs;
  var username = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var photo = "".obs;
  var country = "".obs;
  var profileImagePath = ''.obs;
  var notificationsCount = 0.obs;
  var messageCount = 0.obs;

  ApiService _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    loadUserData(); // تحميل البيانات من التخزين المحلي أولاً
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString("user_data");

    if (userDataJson != null) {
      Map<String, dynamic> userData = jsonDecode(userDataJson);
      name.value = userData["name"] ?? "";
      username.value = userData["username"] ?? "";
      phone.value = userData["phone"] ?? "";
      email.value = userData["email"] ?? "";
      photo.value = userData["photo"] ?? "";
      country.value = userData["country"] ?? "";

      // تحميل القيم الجديدة
      notificationsCount.value = prefs.getInt("notifications_count") ?? 0;
      messageCount.value = prefs.getInt("message_count") ?? 0;

      update();
    } else {
      getData();
    }
  }

  /// حفظ بيانات المستخدم في التخزين المحلي
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userDataJson = jsonEncode(userData);
    await prefs.setString("user_data", userDataJson);
  }

  /// جلب البيانات من الـ API في حالة عدم توفرها محليًا
  Future<void> getData() async {
    isLoading.value = true;

    try {
      // جلب البيانات المخزنة محليًا
      final prefs = await SharedPreferences.getInstance();
      final storedName = prefs.getString('name');
      final storedUsername = prefs.getString('username');
      final storedPhone = prefs.getString('phone');
      final storedEmail = prefs.getString('email');
      final storedPhoto = prefs.getString('photo');
      final storedCountry = prefs.getString('country');
      final storedmessageCount = prefs.getInt('message_count');

      // تحقق من أن كل الحقول الأساسية موجودة
      if (storedName != null &&
          storedUsername != null &&
          storedPhone != null &&
          storedEmail != null &&
          storedmessageCount != null &&
          storedPhoto != null &&
          storedCountry != null) {
        // إذا كانت البيانات مكتملة، استخدمها مباشرة
        name.value = storedName;
        username.value = storedUsername;
        phone.value = storedPhone;
        email.value = storedEmail;
        photo.value = storedPhoto;
        country.value = storedCountry;
        messageCount.value = storedmessageCount;

        update();
      } else {
        // إذا لم تكن البيانات مكتملة، استدعي API
        await fetchDataFromApi();
      }
    } catch (e) {
      print("Error loading stored data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchDataFromApi() async {
    String? token = await TokenService.getToken();
    if (token == null) {
      print("Token is null");
      return;
    }

    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    };

    try {
      var response =
          await _api.getrequst(linkuserprofile, "data", headers: headers);
      if (response != null && response is Map && response.containsKey("data")) {
        var data = response["data"];
        name.value = data["name"] ?? "";
        username.value = data["username"] ?? "";
        phone.value = data["phone"] ?? "";
        email.value = data["email"] ?? "";
        photo.value =
            data["photo"] != null ? "$linkservername/${data["photo"]}" : "";
        country.value = data["country"] ?? "";

        // جلب وحفظ القيم الجديدة
        notificationsCount.value = data["notifications_count"] ?? 0;
        messageCount.value = data["message_count"] ?? 0;

        // حفظ البيانات في التخزين المحلي
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name.value);
        await prefs.setString('username', username.value);
        await prefs.setString('phone', phone.value);
        await prefs.setString('email', email.value);
        await prefs.setString('photo', photo.value);
        await prefs.setString('country', country.value);
        await prefs.setInt('notifications_count', notificationsCount.value);
        await prefs.setInt('message_count', messageCount.value);

        update();
      }
    } catch (e) {
      print("Error fetching data from API: $e");
    }
  }
}
