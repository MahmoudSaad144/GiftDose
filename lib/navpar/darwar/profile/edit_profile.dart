import 'dart:convert';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProfilePage extends StatefulWidget {
  final String name;
  final String username;
  final String email;
  final String phone;
  final String location;

  const AddProfilePage({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.username,
  });

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> {
  final GlobalKey<FormState> formstate = GlobalKey();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  final ApiService _api = ApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    usernameController.text = widget.username;
    emailController.text = widget.email;
    phoneController.text = widget.phone;
    locationController.text = widget.location;
  }

  Future<void> editProfile() async {
    if (formstate.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("خطأ", "لم يتم العثور على التوكن!");
        setState(() {
          isLoading = false;
        });
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();
      Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      Map<String, dynamic> body = {
        "email": emailController.text,
        "name": nameController.text,
        "username": usernameController.text,
        "phone": phoneController.text,
        "country": locationController.text,
        "password":
            passwordController.text.isNotEmpty ? passwordController.text : null,
        "confirmpassword": confirmpasswordController.text.isNotEmpty
            ? confirmpasswordController.text
            : null,
      }..removeWhere((key, value) => value == null || value.toString().isEmpty);

      try {
        var response = await _api.postRequest(linkeidetprofile, body, headers);
        final responseData = jsonDecode(response!.body);

        if (response.statusCode == 200) {
          Get.snackbar("", responseData["message"],
              backgroundColor: Colors.green, colorText: Colors.white);
          Navigator.pop(context, {
            'name': nameController.text,
            'email': emailController.text,
            'phone': phoneController.text,
            'location': locationController.text,
            'username': usernameController.text,
          });
        }
      } catch (e) {
        Get.snackbar("خطأ", "فشل الاتصال بالخادم: $e",
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
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
            bottomRight: Radius.circular(0),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: formstate,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.05),
                  Text(
                    "Edit Profile".tr,
                    style: const TextStyle(
                        fontSize: 40, fontFamily: "Caveat", color: Colors.blue),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: height * 0.05, horizontal: width * 0.1),
                    child: Column(
                      children: [
                        _buildCustomTextField(Icons.person, "Enter Name".tr,
                            nameController, true),
                        _buildCustomTextField(Icons.person,
                            "Enter Name Account".tr, usernameController, true),
                        _buildCustomTextField(Icons.email, "Enter Email".tr,
                            emailController, false),
                        _buildCustomTextField(Icons.phone, "Enter Phone".tr,
                            phoneController, true),
                        _buildCustomTextField(Icons.location_on,
                            "Enter Location".tr, locationController, true),
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.03),
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
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
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height * 0.03),
                          child: TextFormField(
                            controller: confirmpasswordController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText:
                                  "Enter Password to Confirm password".tr,
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
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            validator: (value) {
                              if (value != passwordController.text) {
                                return "كلمة السر لا تتطابق";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: width * 5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF2B77B6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                            ),
                            onPressed: isLoading ? null : editProfile,
                            child: isLoading
                                ? CircularProgressIndicator(
                                    color: Colors.blue,
                                  )
                                : Text(
                                    "Save Changes".tr,
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField(IconData icon, String hint,
      TextEditingController controller, bool enabled,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          hintText: hint,
          filled: true,
          enabled: enabled,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) return "$hint مطلوب";
          return null;
        },
      ),
    );
  }
}
