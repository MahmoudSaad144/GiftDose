import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId'); // يجب أن يكون المفتاح مطابقًا للقيمة المخزنة
  }

  static Future<void> setUserId(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', id);
  }

  // حفظ التوكن مع التحقق من القيمة
  static Future<bool> saveToken(dynamic token) async {
    try {
      if (token == null) {
        print("Token is null, cannot save");
        return false;
      }

      String tokenStr = token.toString();
      if (tokenStr.isEmpty) {
        print("Token is empty, cannot save");
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, tokenStr);
      print("Token saved successfully: $tokenStr");
      return true;
    } catch (e) {
      print("Error saving token: $e");
      return false;
    }
  }

  // استرجاع التوكن
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }

  // حذف التوكن (تسجيل خروج)
  static Future<bool> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool result = await prefs.remove(_tokenKey);
      if (result) {
        print("Token removed successfully");
      } else {
        print("No token found to remove");
      }
      return result;
    } catch (e) {
      print("Error removing token: $e");
      return false;
    }
  }

  // التحقق من حالة المصادقة عند فتح التطبيق
  static Future<void> checkAuthStatus() async {
    String? token = await getToken();
    if (token != null && token.isNotEmpty) {
      print("User is authenticated, navigating to Home Page");
      Get.offAllNamed('/4'); // لو التوكن موجود، يروح لصفحة الهوم
    } else {
      print("User is not authenticated, navigating to Login Page");
      Get.offAllNamed('/1'); // لو التوكن مش موجود، يروح لصفحة تسجيل الدخول
    }
  }
}
