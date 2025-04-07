import 'dart:convert';

import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';

class AddOccasions extends StatefulWidget {
  const AddOccasions({super.key});

  @override
  State<AddOccasions> createState() => _AddOccasionsState();
}

class _AddOccasionsState extends State<AddOccasions> {
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  DateTime? _selectedDate;
  final ApiService _api = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _addOccasion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!",
            backgroundColor: Colors.red, colorText: Colors.white);
        setState(() => _isLoading = false);
        return;
      }

      final String? formattedDate = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      final String description = _descriptionController.text;
      Locale savedLocale = await LanguageService.getSavedLanguage();
      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "name": description,
        "day": formattedDate,
      }..removeWhere((key, value) => value == null || value.toString().isEmpty);

      try {
        final response =
            await _api.postRequest(linkaddOccausion, body, headers);
        if (response == null) {
          Get.snackbar("Error", "No response from server",
              backgroundColor: Colors.red, colorText: Colors.white);
          return;
        }

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          Navigator.pop(context, true);
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        if (e.toString().contains('SocketException')) {
          Get.snackbar("Error", "No internet connection",
              backgroundColor: Colors.red, colorText: Colors.white);
        } else {
          Get.snackbar("Error", "Server connection failed: $e",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              return Container(
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: height * 0.02, horizontal: width * 0.1),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: height * 0.05),
                            const Text(
                              "Gift Dose",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 40,
                                fontFamily: "Caveat",
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: height * 0.05),
                            TextFormField(
                              controller: _descriptionController,
                              decoration: InputDecoration(
                                labelText: 'Occasion Details'.tr,
                                hintText: 'Enter Occasion Details'.tr,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter occasion details".tr;
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: height * 0.04),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: _selectedDate == null
                                        ? "Choose date".tr
                                        : DateFormat('dd/MM/yyyy')
                                            .format(_selectedDate!),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (_selectedDate == null) {
                                      return "Please select a date".tr;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: height * 0.05),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: MaterialButton(
                                  onPressed: _isLoading ? null : _addOccasion,
                                  child: Container(
                                    height: height * 0.07,
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
                                          ? const CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text(
                                              "Add Occasion".tr,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
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
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
