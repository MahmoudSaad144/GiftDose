import 'dart:async';
import 'dart:convert';

import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/translation/language_service.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:http/http.dart' as http;

// استبدل هذه القيمة برابط API الخاص بك

class Forgetpasswordpage extends StatefulWidget {
  const Forgetpasswordpage({super.key});

  @override
  State<Forgetpasswordpage> createState() => _ForgetpasswordpageState();
}

class _ForgetpasswordpageState extends State<Forgetpasswordpage> {
  final GlobalKey<FormState> formstate = GlobalKey<FormState>();

  final TextEditingController pinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

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
    Locale savedLocale = await LanguageService.getSavedLanguage();
    String? fcmToken = await getFCMToken();
    String email = _emailController.text;
    String pin = pinController.text;
    String apiUrl = linkopt;

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $fcmToken",
      "lang": "$savedLocale",
    };

    Map<String, dynamic> body = {
      "email": email,
      "code": pin,
      "fcm_token": fcmToken
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);
      print(responseData);
      if (response.statusCode == 200) {
        if (responseData["status_code"] == 406 ||
            responseData["status_code"] == 407 ||
            responseData["status_code"] == 401) {
          // خطأ من السيرفر، عرض الرسالة
          Get.snackbar("Error",
              " ${responseData["message"].toString().tr}", // إذا كانت الرسالة غير موجودة، ضع رسالة افتراضية
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else if (responseData["status_code"] == 422) {
          // حالة خطأ في الحقول
          Get.snackbar("Error", "${responseData['message']}",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          // محاولة حفظ التوكن
          var token = responseData["data"]?["token"] ?? responseData["token"];
          var userData = responseData["data"];

          bool tokenSaved = await TokenService.saveToken(token);
          if (tokenSaved) {
            Get.find<ProfileController>().getData();
            print("Token saved successfully");
            Get.offAllNamed("/4");
          } else {
            print("Failed to save token");
            Get.snackbar("خطأ", " ${responseData["message"].toString().tr}",
                backgroundColor: Colors.red, colorText: Colors.white);
          }
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

  Future<void> forgetPassword() async {
    // التحقق من صحة النموذج
    if (formstate.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final String email = _emailController.text;
      String apiUrl = linkforgetpassword;

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "lang": "ar"
      };

      Map<String, dynamic> body = {"email": email};

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          headers: headers,
          body: jsonEncode(body),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          if (responseData["status_code"] == 406 ||
              responseData["status_code"] == 407 ||
              responseData["status_code"] == 401) {
            // خطأ من السيرفر
            Get.snackbar(
              "Error",
              responseData["message"]?.toString() ??
                  "An unknown error occurred.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else if (responseData["status_code"] == 422) {
            // خطأ في الحقول
            Get.snackbar(
              "Error",
              responseData["message"]?.toString() ??
                  "Field error. Please check your input.",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            // نجاح
            print("Login Successful: ${responseData['message']}");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  content: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "the activation code has been sent to the email, please check the email"
                                .tr,
                            style: TextStyle(
                                color:
                                    const Color.fromARGB(255, 128, 128, 128)),
                          ),
                          SizedBox(
                            height: 10,
                          ),
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
                      )),
                  onPressed1: () {
                    _isLoading ? null : opt();
                  },
                  onResend: forgetPassword,
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
          // فشل في الاتصال
          Get.snackbar(
            "Error",
            responseData["message"]?.toString() ??
                "An error occurred while connecting to the server.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print("Error: $e");
        Get.snackbar(
          "Error",
          "An error occurred while connecting to the server.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        height: height,
        width: width,
        decoration: const BoxDecoration(
          color: Color(0xFFF9EFC7),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(100000),
            bottomRight: Radius.circular(0),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: TweenAnimationBuilder(
              duration: const Duration(seconds: 1),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: height * 0.05),
                      Column(
                        children: [
                          Image.asset(
                            "images/logo.png",
                            height: height * 0.1,
                            width: height * 0.1,
                            fit: BoxFit.cover,
                          ),
                          const Text(
                            "Gift Dose",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                              fontFamily: "Caveat",
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: height * 0.05,
                          horizontal: width * 0.1,
                        ),
                        child: Form(
                          key: formstate,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1)),
                                  prefixIcon: const Icon(Icons.email,
                                      color: Colors.blue),
                                  hintText: "Enter Email".tr,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "البريد الإلكتروني مطلوب";
                                  } else if (!RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value)) {
                                    return "أدخل بريد إلكتروني صحيح";
                                  }
                                  return null;
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: height * 0.05),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: MaterialButton(
                                    onPressed:
                                        _isLoading ? null : forgetPassword,
                                    child: Container(
                                      height: 50,
                                      width: width * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(25),
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          colors: [
                                            const Color.fromARGB(
                                                    255, 43, 119, 182)
                                                .withOpacity(1),
                                            const Color.fromARGB(
                                                    255, 86, 155, 211)
                                                .withOpacity(1),
                                            const Color.fromARGB(
                                                    255, 121, 195, 255)
                                                .withOpacity(1),
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Text(
                                                "Send".tr,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class TimerController extends GetxController {
  RxInt secondsRemaining = 60.obs;
  Timer? _timer;

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    secondsRemaining.value = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
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
