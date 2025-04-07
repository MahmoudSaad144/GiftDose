import 'dart:ui';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';

  /// حفظ اللغة المختارة في التخزين المحلي
  static Future<void> saveLanguage(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();

    // طباعة القيم قبل الحفظ للتحقق من البيانات
    print("💾 قبل الحفظ: ${locale.languageCode} ");

    // محاولة حفظ البيانات
    bool languageSaved =
        await prefs.setString(_languageKey, locale.languageCode);

    // تأكد من أن البيانات تم حفظها بنجاح
    if (languageSaved) {
      print("✅ تم حفظ اللغة والدولة بنجاح!");
    } else {
      print("⚠️ فشل في حفظ اللغة أو الدولة.");
    }

    // التحقق من البيانات المخزنة بعد الحفظ
    String? storedLanguage = prefs.getString(_languageKey);

    print("✅ بعد الحفظ: $storedLanguage");
  }

  static Future<Locale> getSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // استرجاع القيم المخزنة
    String? languageCode = prefs.getString(_languageKey);

    // طباعة القيم المسترجعة للتحقق
    print("🔍 القيم المسترجعة من SharedPreferences: $languageCode ");

    // التحقق من القيم المسترجعة
    if (languageCode != null && languageCode.isNotEmpty) {
      // التأكد من وجود رمز الدولة أو استخدام القيمة الافتراضية (US)
      return Locale(languageCode);
    }

    // في حال كانت القيم غير صحيحة، العودة إلى اللغة الافتراضية
    print("⚠️ لم يتم العثور على اللغة المخزنة، سيتم استخدام اللغة الافتراضية.");
    return const Locale('en'); // اللغة الافتراضية
  }

  /// تحديث اللغة في التطبيق
  static Future<void> changeLanguage(Locale locale) async {
    print("🌍 تغيير اللغة إلى: ${locale.languageCode}");

    // تأكد من أن اللغة تُخزن
    await saveLanguage(locale);

    // تحديث اللغة في GetX
    Get.updateLocale(locale);
  }
}
