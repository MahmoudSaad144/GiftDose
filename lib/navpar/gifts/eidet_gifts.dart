import 'dart:convert';

import 'package:giftdose/Controller/placelocation.dart';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/gifts/eidetexception.dart';

import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class EidetGiftController extends GetxController {
  final List<int> selectedFriends2 = [];
  final Rx<File?> image = Rx<File?>(null);
  final RxString selectedCurrency = 'USD'.obs;
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxString locationAddress = 'location'.obs;
  final RxString placeId = ''.obs;
  final RxString placeName = ''.obs;
  List<int> selectedFriendIds = [];
  final nameController = TextEditingController();
  final sizeController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();
  final colorController = TextEditingController();
  late int giftId;
  List<int> hiddenUserIds = [];
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

  ApiService _api = ApiService();
  Future<void> _fetchHiddenUsers(int giftId) async {
    final String? token = await TokenService.getToken();
    if (token == null) {
      Get.snackbar("Error", "Token not found!");
      return;
    }

    Locale savedLocale = await LanguageService.getSavedLanguage();
    final Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    };

    try {
      var response = await _api.getrequst2("$Gifts_details/$giftId", "", "",
          headers: headers);

      if (response != null && response["data"] != null) {
        List<dynamic> hiddenUsers = response["data"]["hidden_users"] ?? [];

        hiddenUserIds =
            hiddenUsers.map<int>((user) => user["id"] as int).toList();
        selectedFriendIds =
            List.from(hiddenUserIds); // ✅ تأكد إن hiddenUserIds فيها البيانات
      } else {
        print("❌ No hidden users found in response!");
      }
    } catch (e) {
      print("❌ Error fetching hidden users: $e");
    }
  }

  Future<void> _eidetGift() async {
    _isLoading.value = true;

    final String? token = await TokenService.getToken();
    if (token == null) {
      Get.snackbar("Error", "Token not found!");
      _isLoading.value = false;
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token",
    };

    var request = http.MultipartRequest(
        "POST", Uri.parse("https://giftdose.com/api/updategifts/$giftId"))
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
    if (selectedFriendIds.isNotEmpty) {
      for (var id in selectedFriendIds) {
        request.fields.addAll({"exciption[$id]": id.toString()});
      }
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
      print("📤 Response: ${response.body}");

      if (response.statusCode == 200) {
        Get.offNamed("/4");
      } else {
        Get.snackbar("Error", responseData["message"] ?? "Failed to add gift",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      _isLoading.value = false; // **ضمان إيقاف اللودينج في كل الحالات**
    }
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments ?? {};
    giftId = arguments["id"] ?? 0;

    print("🎁 Gift ID: $giftId");
    if (giftId == 0) {
      Get.snackbar("خطأ", "لم يتم تمرير معرف الهدية بشكل صحيح!",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    nameController.text = arguments["name"] ?? "";
    sizeController.text = arguments["size"]?.toString() ?? "";
    colorController.text = arguments["color"] ?? "";
    priceController.text = arguments["price"]?.toString() ?? "";
    notesController.text = arguments["note"] ?? "";
    locationAddress.value = arguments["address"] ?? "اضغط لتحديد الموقع";

    if (arguments["photo"] != null) {
      image.value = File(arguments["photo"]);
    }

    if (arguments["lat"] != null && arguments["lng"] != null) {
      latitude.value = arguments["lat"];
      longitude.value = arguments["lng"];
    }

    _fetchHiddenUsers(giftId); // تحميل المستخدمين المخفيين للهدية
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

class EidetGifts extends GetView<EidetGiftController> {
  final List<int> selectedFriendIds2;

  EidetGifts({Key? key, required this.selectedFriendIds2}) : super(key: key) {
    Get.put(EidetGiftController());
    controller.selectedFriends2.clear();
    controller.selectedFriends2.addAll(selectedFriendIds2);
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
                      SizedBox(
                        height: 15,
                      ),
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
          onTap: () => Get.to(() => MapSelectionScreen(
                onLocationSelected: (lat, lng, address, placeId, placeName) {
                  controller.updateLocation(
                      lat, lng, address, placeId, placeName);
                },
              )),
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
              onPressed: () async {
                final updatedFriends = await Get.to(() => Exceptionspage2(),
                    arguments: {"giftId": controller.giftId});

                if (updatedFriends != null) {
                  controller.selectedFriends2.clear();
                  controller.selectedFriends2.addAll(updatedFriends);
                  controller.selectedFriendIds =
                      List.from(updatedFriends); // ✅ حفظ القيم الجديدة
                }
              },
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
              onPressed:
                  controller._isLoading.value ? null : controller._eidetGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(width * 0.8, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: controller._isLoading.value
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Save".tr,
                      style: TextStyle(color: Colors.white, fontSize: 20)),
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
