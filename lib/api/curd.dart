import 'package:giftdose/Controller/token.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  Future<dynamic> getrequst(String baseUri, String date,
      {Map<String, String>? headers}) async {
    try {
      var response = await http.get(Uri.parse(baseUri),
          headers: headers); // ✅ إصلاح الخطأ هنا

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          print("✅ API Response: $jsonResponse");
          return jsonResponse;
        } catch (e) {
          print("❌ Error parsing JSON: $e");
          return null;
        }
      } else if (response.statusCode == 401) {
        // حذف التوكن
        await TokenService.removeToken();

        // طرد المستخدم لصفحة تسجيل الدخول
        Get.offAllNamed("/1");

        Get.snackbar("Error", "تم طردك بسبب انتهاء الجلسة أو الحظر.",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        print("❌ Error: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Request Error: $e");
      return null;
    }
  }

  Future<http.Response?> postRequest(
      String baseUri, Object? body, Map<String, String>? headers,
      {String? load} // إضافة load كـ parameter اختياري
      ) async {
    try {
      // بناء الرابط مع إضافة load إذا كان موجود
      String uri = load != null ? "$baseUri?load=$load" : baseUri;
      print("Request URL: $uri"); // طباعة الرابط للتأكد

      var response = await http.post(
        Uri.parse(uri),
        headers: headers,
        body: body,
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        int statusCode = responseData["status_code"] ?? 0;
        String message =
            responseData["message"]?.toString() ?? "حدث خطأ غير معروف.";

        if ([406, 407, 401, 422].contains(statusCode)) {
          Get.snackbar(
            "خطأ",
            statusCode == 422
                ? "خطأ في الحقول. يرجى التحقق من المدخلات."
                : message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          print("الرسالة: $message");
        }
      } else if (response.statusCode == 401) {
        await TokenService.removeToken();
        Get.offAllNamed("/1");

        Get.snackbar("Error", "تم طردك بسبب انتهاء الجلسة أو الحظر.",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar(
          "خطأ",
          responseData["message"] ?? "استجابة غير متوقعة",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }

      return response;
    } catch (e) {
      print("خطأ أثناء الطلب: $e");
      Get.snackbar(
        "خطأ",
        "حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<dynamic> getrequst2(String baseUri, String load, String search,
      {required Map<String, String> headers}) async {
    try {
      String uri = '$baseUri?load=$load&search=$search';
      print("Request URL: $uri"); // طباعة الرابط للتأكد

      var response = await http.get(
        Uri.parse(uri),
        headers: headers, // ✅ إضافة الهيدرز
      );

      print("Response Status: ${response.statusCode}"); // طباعة كود الاستجابة
      print("Response Body: ${response.body}"); // طباعة بيانات الاستجابة

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          return jsonResponse;
        } catch (e) {
          print("JSON Decode Error: $e"); // التعامل مع خطأ فك التشفير
          return null;
        }
      } else if (response.statusCode == 401) {
        // حذف التوكن
        await TokenService.removeToken();

        // طرد المستخدم لصفحة تسجيل الدخول
        Get.offAllNamed("/1");

        Get.snackbar("Error", "تم طردك بسبب انتهاء الجلسة أو الحظر.",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        print("Error: Unexpected response (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("Catch Error: $e");
      return null;
    }
  }

  Future<dynamic> getrequst3(String baseUri, String query,
      {required Map<String, String> headers}) async {
    try {
      // إضافة `load` كمعامل في الرابط

      print("Request URL: $baseUri");

      var response = await http.get(
        Uri.parse(baseUri),
        headers: headers,
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          var jsonResponse = jsonDecode(response.body);
          return jsonResponse;
        } catch (e) {
          print("JSON Decode Error: $e");
          return null;
        }
      } else if (response.statusCode == 401) {
        await TokenService.removeToken();
        Get.offAllNamed("/1");

        Get.snackbar("Error", "تم طردك بسبب انتهاء الجلسة أو الحظر.",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        print("Error: Unexpected response (${response.statusCode})");
        return null;
      }
    } catch (e) {
      print("Catch Error: $e");
      return null;
    }
  }
}
