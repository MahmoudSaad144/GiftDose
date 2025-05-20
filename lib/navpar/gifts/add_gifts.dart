import 'dart:convert';

import 'package:giftdose/Controller/placelocation.dart';

import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/navpar/gifts/exception.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GiftController extends GetxController {
  final List<int> selectedFriends = [];
  final Rx<File?> image = Rx<File?>(null);
  final RxString selectedCurrency = 'USD'.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString locationAddress = 'location'.obs;
  final RxString placeId = ''.obs;
  final RxString placeName = ''.obs;

  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();
  final colorController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final currencies = [
    'USD', // الدولار الأمريكي
    'EUR', // اليورو
    'GBP', // الجنيه الإسترليني
    'EGP', // الجنيه المصري
    'SAR', // الريال السعودي
    'AED', // الدرهم الإماراتي
    'KWD', // الدينار الكويتي
    'QAR', // الريال القطري
    'BHD', // الدينار البحريني
    'OMR', // الريال العماني
    'JOD', // الدينار الأردني
    'LBP', // الليرة اللبنانية
    'SYP', // الليرة السورية
    'DZD', // الدينار الجزائري
    'TND', // الدينار التونسي
    'MAD', // الدرهم المغربي
    'LYD', // الدينار الليبي
    'SDG', // الجنيه السوداني
    'YER', // الريال اليمني
    'IQD', // الدينار العراقي
    'SOS', // الشلن الصومالي
    'MRU', // الأوقية الموريتانية
    'DJF', // الفرنك الجيبوتي
    'TRY', // الليرة التركية
  ];

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.blue),
              title: Text("Take a new photo".tr),
              onTap: () async {
                Get.back();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.camera);
                _processPickedImage(pickedFile);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.green),
              title: Text("Selection from the Gallery".tr),
              onTap: () async {
                Get.back();
                final pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);
                _processPickedImage(pickedFile);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processPickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      String extension = pickedFile.path.split('.').last.toLowerCase();
      if (extension != 'jpg' && extension != 'jpeg' && extension != 'png') {
        Get.snackbar(
            "", "You must choose an image in JPG, PNG, or JPEG format.".tr,
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      image.value = File(pickedFile.path);
    }
  }

  void updateLocation(double lat, double lng, String address, String placeId,
      String placeName) {
    latitude.value = lat;
    longitude.value = lng;
    locationAddress.value = address;
    this.placeId.value = placeId;
    this.placeName.value = placeName;
  }

  Future<void> _addGift() async {
    _isLoading.value = true; // تشغيل اللودنج
    final String? token = await TokenService.getToken();
    if (token == null) {
      Get.snackbar("Error", "Token not found!");
      _isLoading.value = false; // تأكيد إيقاف اللودنج
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token",
    };

    if (placeName.value.trim().isEmpty) {
      Get.snackbar("", "Address must be selected before proceeding!".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
      _isLoading.value = false; // تأكيد إيقاف اللودنج
      return;
    }

    var request = http.MultipartRequest("POST", Uri.parse(linkaddgifts))
      ..headers.addAll(headers)
      ..fields["name"] = nameController.text
      ..fields["size"] = sizeController.text
      ..fields["color"] = colorController.text
      ..fields["price"] = priceController.text
      ..fields["currency"] = selectedCurrency.value
      ..fields["note"] = notesController.text
      ..fields["lat"] = latitude.value.toString()
      ..fields["lng"] = longitude.value.toString()
      ..fields["address"] = placeName.value;
// ✅ إرسال placeId مع الطلب

    for (var id in selectedFriends) {
      request.fields.addAll({"exciption[$id]": id.toString()});
    }

    if (image.value != null) {
      request.files.add(
        await http.MultipartFile.fromPath("photo", image.value!.path),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.offAllNamed("/4");
      } else {
        Get.snackbar("Error", "${responseData["errors"]}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
      // 🔴 مهم عشان يضمن تنفيذ الـ `finally`
    } finally {
      _isLoading.value = false; // إيقاف اللودنج في جميع الحالات
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    sizeController.dispose();
    priceController.dispose();
    notesController.dispose();
    colorController.dispose();
    super.onClose();
  }
}

class AddGiftPage extends GetView<GiftController> {
  final List<int> selectedFriendIds; // استقبال القائمة من الصفحة السابقة

  AddGiftPage({Key? key, required this.selectedFriendIds}) : super(key: key) {
    Get.put(GiftController());
    controller.selectedFriends
        .addAll(selectedFriendIds); // تخزينها في الكنترولر
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
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
                    vertical: constraints.maxHeight * 0.02,
                    horizontal: constraints.maxWidth * 0.1,
                  ),
                  child: Column(
                    children: [
                      _buildImagePicker(),
                      const SizedBox(height: 20),
                      _buildInputFields(),
                      _buildLocationSection(),
                      _buildPriceSection(),
                      _buildExceptionButton(),
                      const SizedBox(height: 15),
                      _buildSubmitButton(constraints.maxWidth),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Obx(() => Center(
          child: GestureDetector(
            onTap: controller.pickImage,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color.fromARGB(74, 103, 183, 226),
              backgroundImage: controller.image.value != null
                  ? FileImage(controller.image.value!)
                  : null,
              child: controller.image.value == null
                  ? const Icon(Icons.camera_alt, size: 50, color: Colors.blue)
                  : null,
            ),
          ),
        ));
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        CustomTextField(
            controller: controller.nameController, label: "Gift name".tr),
        CustomTextField(
            controller: controller.sizeController, label: "Size".tr),
        CustomTextField(
            controller: controller.colorController, label: "color".tr),
        CustomTextField(
            controller: controller.notesController,
            label: "Notes".tr,
            maxLines: 3),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          // onTap: () => Get.to(() => MapSelectionScreen(
          //       onLocationSelected: (lat, lng, address, placeId, placeName) {
          //         controller.updateLocation(
          //             lat, lng, address, placeId, placeName);
          //       },
          //     )),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 10),
                Expanded(
                  child: Obx(() => Text(
                        controller.locationAddress.value,
                        style: TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => DropdownButtonFormField(
                value: controller.selectedCurrency.value,
                items: controller.currencies.map((currency) {
                  return DropdownMenuItem(
                    value: currency,
                    child: Text(currency, style: TextStyle(fontSize: 18)),
                  );
                }).toList(),
                onChanged: (value) =>
                    controller.selectedCurrency.value = value.toString(),
                decoration: InputDecoration(
                  labelText: "currency".tr,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomTextField(
              controller: controller.priceController, label: "price".tr),
        ),
      ],
    );
  }

  Widget _buildExceptionButton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(159, 219, 222, 223)),
            child: MaterialButton(
              onPressed: () => Get.to(() => Exceptionspage()),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hide the gift'.tr, style: TextStyle(fontSize: 18)),
                      Icon(Icons.visibility_off)
                    ],
                  )),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Obx(() => ElevatedButton(
              onPressed: controller._isLoading.value
                  ? null
                  : () => controller._addGift(), // ✅ تعطيل الزر أثناء التحميل
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(width * 0.8, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: controller._isLoading.value
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    ) // ✅ إظهار اللودر
                  : Text('Add a Gift'.tr,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
            )),
      ),
    );
  }
}

// ويدجت حقل الإدخال المخصص
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
