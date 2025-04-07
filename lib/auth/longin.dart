import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';

import 'package:giftdose/fanction/textfild.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:pinput/pinput.dart';

class Longinpage extends StatefulWidget {
  const Longinpage({super.key});

  @override
  State<Longinpage> createState() => _LonginpageState();
}

class _LonginpageState extends State<Longinpage> {
  GlobalKey<FormState> formstate = GlobalKey();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController pinController = TextEditingController();

  bool _isLoading = false;
  bool isPasswordVisible = false;
  Future<String> getDeviceName() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name;
    }
    return "Unknown Device";
  }

  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return await messaging.getToken();
  }

  Future<void> opt() async {
    if (!formstate.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    String? fcmToken = await getFCMToken();
    String email = _emailController.text;
    String pin = pinController.text;
    String apiUrl = linkopt;
    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "lang": "$savedLocale",
    };

    Map<String, dynamic> body = {
      "email": email,
      "code": pin,
      "fcm_token": fcmToken
    };
    print(fcmToken);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      print("00000000000000000Response Status: ${response.statusCode}");
      print("000000000000000000000000Response Data: $responseData");
      if (response.statusCode == 200) {
        if (responseData["status_code"] == 406 ||
            responseData["status_code"] == 407 ||
            responseData["status_code"] == 401) {
          Get.snackbar("", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else if (responseData["status_code"] == 422) {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.snackbar("", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.green, colorText: Colors.white);
          var token = responseData["data"]?["token"] ?? responseData["token"];
          var userId = responseData["data"]?["id"] ?? responseData["id"];

          bool tokenSaved = await TokenService.saveToken(token);
          await TokenService.setUserId(userId); // حفظ الـ id
          if (tokenSaved) {
            print("Token saved successfully");
            Get.find<ProfileController>().getData();
            Get.offAllNamed("/4");
          } else {
            print("Failed to save token");
            Get.snackbar("خطأ", " ${responseData["message"].toString().tr}",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
          Get.back();
        }
      } else {
        Get.snackbar("خطأ", " ${responseData["message"].toString().tr}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> login() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        String deviceName = await getDeviceName();
        String? fcmToken = await getFCMToken();
        Locale savedLocale = await LanguageService.getSavedLanguage();
        final response = await http.post(
          Uri.parse(linklogin),
          headers: {"Content-Type": "application/json", "lang": "$savedLocale"},
          body: jsonEncode({
            "login_id": _emailController.text,
            "password": _passwordController.text,
            "device_name": deviceName,
            "fcm_token": fcmToken
          }),
        );
        print("000000000000$fcmToken");
        final responseData = jsonDecode(response.body);
        print("Decoded Response: $responseData");

        if (response.statusCode == 200) {
          if (responseData["status_code"] == 406 ||
              responseData["status_code"] == 407 ||
              responseData["status_code"] == 401) {
            Get.snackbar("Error", " ${responseData["message"].toString().tr}",
                backgroundColor: Colors.red, colorText: Colors.white);

            if (responseData["status_code"] == 407) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 20),
                        Pinput(
                          controller: pinController,
                          length: 6,
                          defaultPinTheme: PinTheme(
                            width: 40,
                            height: 40,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.blue,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onCompleted: (pin) {},
                        ),
                      ],
                    ),
                    onPressed1: () {
                      _isLoading ? null : opt();
                    },
                    onResend: login,
                    textDirection: TextDirection.ltr,
                    dilogiconcolor: Colors.blue,
                    titledilog: "OTP!".tr,
                    fontsize: 50,
                    Colortitle: Colors.blue,
                    contentdilog: "Enter the special code sent".tr,
                    namebottomdilog1: "Send".tr,
                  );
                },
              );
            }
          } else {
            var token = responseData["data"]?["token"] ?? responseData["token"];
            var userId = responseData["data"]?["id"] ?? responseData["id"];

            bool tokenSaved = await TokenService.saveToken(token);
            await TokenService.setUserId(userId); // حفظ الـ id
            if (tokenSaved) {
              print("Token saved successfully");
              Get.find<ProfileController>().getData();
              Get.offAllNamed("/4");
            } else {
              print("Failed to save token");
              Get.snackbar("", " ${responseData["message"].toString().tr}",
                  backgroundColor: Colors.green, colorText: Colors.white);
            }
          }
        } else {
          Get.snackbar("خطأ", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        print("Login Error: $e");
        Get.snackbar("خطأ", "حدث خطأ أثناء تسجيل الدخول",
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget languageTile(double iconSize, double fontSize) {
    return MaterialButton(
      onPressed: () async {
        Locale newLocale =
            (Get.locale?.languageCode == 'en') ? Locale('ar') : Locale('en');

        await LanguageService.changeLanguage(newLocale);
        await LanguageService.saveLanguage(newLocale);
        setState(() {});
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language_rounded, size: iconSize, color: Colors.blue),
          SizedBox(width: 10),
          Text("Arabic".tr,
              style: TextStyle(
                  fontSize: fontSize,
                  color: const Color.fromARGB(255, 93, 92, 92))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
            color: Color(0xFFF9EFC7),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100000),
                bottomRight: Radius.circular(0))),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formstate,
              child: Column(
                children: [
                  SizedBox(height: height * 0.05),
                  Image.asset("images/logo.png",
                      height: height * 0.1, width: height * 0.1),
                  const Text("Gift Dose",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          fontFamily: "Caveat",
                          color: Colors.blue)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.05, horizontal: width * 0.1),
                    child: Column(
                      children: [
                        // لازم تكون معرف المتغير ده فوق
                        castumtextfil(
                          obscureText: false,
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.blue),
                          Bool: false,
                          hint: "Enter Email".tr,
                          mytextcontroller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "البريد الإلكتروني مطلوب";
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: height * 0.03),
                        castumtextfil(
                          prefixIcon:
                              const Icon(Icons.key_sharp, color: Colors.blue),
                          Bool:
                              !isPasswordVisible, // بيخلي النص مش ظاهر لو isPasswordVisible = false
                          suffixIcon: IconButton(
                            icon: Icon(isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          hint: "Enter Password".tr,
                          mytextcontroller: _passwordController,
                          obscureText:
                              !isPasswordVisible, // يخفي النص إذا isPasswordVisible = false
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "الرقم السري مطلوب";
                            } else if (value.length < 6) {
                              return "الرقم السري يجب أن يحتوي على 6 خانات على الأقل";
                            }
                            return null; // إذا الرقم السري صحيح
                          },
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: languageTile(25, 15)),
                            SizedBox(
                              width: width * .15,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => Get.toNamed("3"),
                                child: Text(
                                  "Forgot Password".tr,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: height * 0.01),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  if (formstate.currentState!.validate()) {
                                    login();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.001,
                                horizontal: width * 0.15),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text("Login".tr,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white)),
                        ),
                        SizedBox(height: height * 0.01),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't Have Account?".tr,
                                style: TextStyle(fontSize: 15)),
                            TextButton(
                              onPressed: () => Get.toNamed("2"),
                              child: Text("Sign Up".tr,
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 20)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomDialog extends StatefulWidget {
  final String titledilog;
  final double? fontsize;
  final Color? Colortitle;
  final String? contentdilog;
  final String? namebottomdilog1;
  final Color? dilogiconcolor;
  final IconData? dilogicon;
  final VoidCallback? onPressed1;
  final VoidCallback? onResend; // ⬅️ دالة إعادة الإرسال
  final Widget? content;

  const CustomDialog({
    required this.titledilog,
    this.fontsize,
    this.Colortitle,
    this.contentdilog,
    this.namebottomdilog1,
    this.dilogiconcolor,
    this.dilogicon,
    this.onPressed1,
    this.onResend, // ⬅️ استلام الدالة هنا
    this.content,
    Key? key,
    required textDirection,
  }) : super(key: key);

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  Timer? _timer;
  int _remainingTime = 60;
  bool _isButtonEnabled = false;
  bool _isLoading = false; // 🔴 متغير اللودينج

  @override
  void initState() {
    super.initState();
    _startTimer(); // تشغيل المؤقت عند فتح الديالوج
  }

  @override
  void dispose() {
    _timer?.cancel(); // التأكد من إيقاف التايمر عند الخروج
    super.dispose();
  }

  /// دالة بدء المؤقت
  void _startTimer() {
    setState(() {
      _remainingTime = 60;
      _isButtonEnabled = false; // تعطيل زر إعادة الإرسال
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel(); // إيقاف المؤقت
        setState(() {
          _isButtonEnabled = true; // تفعيل زر إعادة الإرسال
        });
      }
    });
  }

  /// تنفيذ إرسال الكود مع اللودينج
  void _handleSend() async {
    setState(() {
      _isLoading = true; // ✅ تفعيل اللودينج
    });

    await Future.delayed(Duration(seconds: 5)); // محاكاة تأخير الإرسال

    widget.onPressed1?.call(); // استدعاء الدالة الأصلية

    setState(() {
      _isLoading = false; // ❌ إيقاف اللودينج بعد انتهاء العملية
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: Text(
          widget.titledilog,
          style: TextStyle(
            fontSize: widget.fontsize ?? 18,
            color: widget.Colortitle ?? Colors.black,
          ),
        ),
      ),
      content: widget.content ??
          (widget.contentdilog != null
              ? Text(widget.contentdilog!, style: TextStyle(fontSize: 16))
              : null),
      actions: [
        Column(
          children: [
            Text(
              '$_remainingTime ثانية',
              style: TextStyle(fontSize: 15, color: Colors.red),
            ),
            MaterialButton(
              color: Color.fromARGB(255, 245, 115, 115),
              onPressed: _isButtonEnabled
                  ? () {
                      Navigator.pop(context); // إغلاق الديالوج
                      widget.onResend?.call(); // تنفيذ إعادة الإرسال
                    }
                  : null,
              child:
                  Text("إعادة الإرسال", style: TextStyle(color: Colors.white)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : _handleSend, // ✅ تعطيل الزر أثناء اللودينج
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 43, 119, 182),
                          Color.fromARGB(255, 86, 155, 211),
                          Color.fromARGB(255, 121, 195, 255),
                        ],
                      ),
                    ),
                    child: Center(
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white) // ✅ إظهار اللودينج
                          : Text(widget.namebottomdilog1 ?? "",
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      icon: widget.dilogicon != null
          ? Icon(widget.dilogicon,
              color: widget.dilogiconcolor ?? Colors.black, size: 100)
          : null,
    );
  }
}
