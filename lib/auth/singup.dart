import 'dart:async';
import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/component/country_picker_code.dart';
import 'package:giftdose/fanction/mypintnput.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Singuppage extends StatefulWidget {
  const Singuppage({super.key});

  @override
  State<Singuppage> createState() => _SinguppageState();
}

class _SinguppageState extends State<Singuppage> {
  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _ConfirmpasswordController = TextEditingController();
  TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  bool isPasswordVisible = false;
  DateTime? _selectedDate;
  String? phone_code;
  Country? selectedCountry2;
  bool showWorldWide = true;

  Future<String?> getFCMToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    return await messaging.getToken();
  }

  Future<void> opt() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();

    String? fcmToken = await getFCMToken();
    String email = _emailController.text;
    String pin = _pinController.text;
    String apiUrl = linkopt;

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $fcmToken",
      "lang": "$savedLocale"
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
          Get.snackbar(
              "Error",
              responseData["message"] != null
                  ? responseData["message"].toString().tr
                  : "An unknown error occurred.",
              backgroundColor: Colors.red,
              colorText: Colors.white);
        } else if (response.statusCode == 422) {
          // حالة خطأ في الحقول
          Get.snackbar("", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.snackbar("", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.green, colorText: Colors.white);

          var token = responseData["data"]?["token"] ?? responseData["token"];
          var userData = responseData["data"];

          bool tokenSaved = await TokenService.saveToken(token);
          if (tokenSaved) {
            Get.find<ProfileController>().getData();
            print("Token saved successfully");
            Get.offAllNamed("/4");
          }

          Get.back();
        }
      } else {
        Get.snackbar(
            "خطأ",
            responseData["message"] != null
                ? responseData["message"].toString().tr
                : "حدث خطأ أثناء الاتصال بالخادم",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signup() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String username = _usernameController.text;
      String email = _emailController.text;
      String? formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      String phoneNumber = _phoneNumberController.text;
      String password = _passwordController.text;
      String confirmpassword = _ConfirmpasswordController.text;
      String country2 = selectedCountry2?.name ?? '';

      // دمج كود الدولة مع رقم الهاتف

      String apiUrl = linksignup; // Add the correct API URL

      Map<String, String> headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer "
      };

      Map<String, dynamic> body = {
        "name": username,
        "email": email,
        "bday": formattedDate,
        "phone": phoneNumber, // إرسال رقم الهاتف مع كود الدولة
        "phone_code": phone_code, // إرسال رقم الهاتف مع كود الدولة
        "country": country2,
        "password": password,
        "confirmpassword": confirmpassword,
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
            Get.snackbar(
              "Error",
              responseData["message"].toString(),
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "",
              responseData["message"].toString(),
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return CustomDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "the activation code has been sent to the email, please check the email"
                            .tr,
                        style: TextStyle(
                            color: const Color.fromARGB(255, 128, 128, 128)),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Column(
                        children: [
                          // ⬅️ إجبار النص على الاتجاه من اليسار لليمين
                          MyPinInput(
                            mycontroller: _pinController,
                          )
                        ],
                      ),
                    ],
                  ),
                  onPressed1: () {
                    opt();
                  },
                  onResend: signup,
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
        } else if (response.statusCode == 422) {
          // حالة خطأ في الحقول
          Get.snackbar(
            "Error",
            responseData["errors"].toString(),
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } else {
          // فشل في الاتصال، عرض رسالة الخطأ من السيرفر
          Get.snackbar(
            "Error",
            responseData["message"] != null
                ? responseData["message"].toString()
                : "حدث خطأ أثناء الاتصال بالخادم",
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(children: [
        Positioned.fill(
          child: Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
                color: Color(0xFFF9EFC7),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100000),
                    bottomRight: Radius.circular(0))),
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
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Caveat",
                                    color: Colors.blue),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.05,
                                horizontal: width * 0.1),
                            child: Form(
                              key: formstate,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _usernameController,
                                    decoration: InputDecoration(
                                      labelText: 'Enter Name'.tr,
                                      prefixIcon: const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter Name'.tr;
                                      } else if (value.length < 3) {
                                        return "الاسم  يجب أن يحتوي على 3 خانات على الأقل";
                                      }
                                      return null;
                                    },
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * 0.03),
                                    child: TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                                color: Colors.black, width: 1)),
                                        prefixIcon: const Icon(Icons.email,
                                            color: Colors.blue),
                                        hintText: "Enter Email".tr,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return "Enter Email".tr;
                                        } else if (!RegExp(
                                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                            .hasMatch(value)) {
                                          return "أدخل بريد إلكتروني صحيح";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                          EdgeInsets.only(top: height * 0.03),
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          hintText: _selectedDate == null
                                              ? "Choose the date".tr
                                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"
                                                  .tr,
                                          filled: false,
                                          prefixIcon: const Icon(
                                            Icons.date_range,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        readOnly: true,
                                        onTap: () {
                                          _selectDate(context);
                                        },
                                        // validator: (value) {
                                        //   // التحقق من اختيار التاريخ
                                        //   if (_selectedDate == null) {
                                        //     return "التاريخ مطلوب";
                                        //   }
                                        //   return null;
                                        // },
                                      )),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * 0.03),
                                    child: CountryCodePickerField(
                                      controller: _phoneNumberController,
                                      label: "Enter Phone".tr,
                                      onCountryCodeChanged: (code) {
                                        setState(() {
                                          phone_code = code;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * 0.03),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !isPasswordVisible,
                                      decoration: InputDecoration(
                                        labelText: "Enter Password".tr,
                                        prefixIcon: const Icon(
                                          Icons.key_sharp,
                                          color: Colors.blue,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Password".tr;
                                        } else if (value.length < 6) {
                                          return 'Password must be bagger than 6 letters'
                                              .tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * 0.03),
                                    child: TextFormField(
                                      controller: _ConfirmpasswordController,
                                      obscureText: !isPasswordVisible,
                                      decoration: InputDecoration(
                                        labelText:
                                            "Enter Password to Confirm password"
                                                .tr,
                                        prefixIcon: const Icon(
                                          Icons.key_sharp,
                                          color: Colors.blue,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isPasswordVisible =
                                                  !isPasswordVisible;
                                            });
                                          },
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Enter Password to Confirm password"
                                              .tr;
                                        } else if (value !=
                                            _passwordController.text) {
                                          return "Confirm Password not same Password"
                                              .tr;
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: height * 0.03),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () {
                                              showCountryPicker(
                                                context: context,
                                                exclude: ['IL'],
                                                showPhoneCode: false,
                                                onSelect: (Country country) {
                                                  setState(() {
                                                    selectedCountry2 = country;
                                                  });
                                                },
                                              );
                                            },
                                            child: InputDecorator(
                                              decoration: InputDecoration(
                                                labelText: 'Select Country'.tr,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      selectedCountry2 != null
                                                          ? "${selectedCountry2!.flagEmoji}  ${selectedCountry2!.name}  "
                                                          : "Select a country"
                                                              .tr,
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.arrow_drop_down,
                                                    color: Colors.blue,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: height * 0.03,
                                        bottom: height * 0.03),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: MaterialButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () {
                                                  if (formstate.currentState!
                                                      .validate()) {
                                                    signup();
                                                  }
                                                },
                                          child: Container(
                                            height: 50,
                                            width: width * 0.8,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
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
                                                      .withOpacity(1)
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: _isLoading
                                                  ? CircularProgressIndicator(
                                                      color: Colors.white,
                                                    )
                                                  : Text(
                                                      "Sing Up".tr,
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
                                                          fontSize: 20),
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
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: Get.locale?.languageCode == 'ar' ? null : 10,
          right: Get.locale?.languageCode == 'ar' ? 10 : null,
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Get.back(),
          ),
        ),
      ]),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = _selectedDate ?? DateTime.now();
    DateTime lastDate = DateTime(2025);
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: lastDate,
    );

    if (selectedDate != null) {
      if (mounted) {
        setState(() {
          _selectedDate = selectedDate;
        });
      }
    }
  }
}

class castumtextfil extends StatelessWidget {
  final Icon prefixIcon;
  final bool Bool;
  final String hint;
  final TextEditingController mytextcontroller;
  final Widget? suffixIcon;

  const castumtextfil({
    required this.prefixIcon,
    required this.Bool,
    required this.hint,
    required this.mytextcontroller,
    this.suffixIcon,
    required String? Function(dynamic value) validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: Bool,
      controller: mytextcontroller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: hint,
        filled: false,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
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
