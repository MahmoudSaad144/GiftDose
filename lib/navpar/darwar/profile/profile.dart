import 'dart:async';

import 'dart:io';

import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/navpar/darwar/profile/edit_profile.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ProfileController extends GetxController {
  var notificationsCount = 0.obs;
  var messageCount = 0.obs;

  var isLoading = false.obs;
  var name = "".obs;
  var username = "".obs;
  var phone = "".obs;
  var email = "".obs;
  var photo = "".obs;
  var country = "".obs;
  var profileImagePath = ''.obs;

  late Timer timer;
  void updateProfileImage(String imagePath) {
    profileImagePath.value = imagePath;
  }

  ApiService _api = ApiService();

  @override
  void onInit() {
    super.onInit();

    getData();

    // تحميل بيانات المستخدم من التخزين المحلي
  }

  Future<void> getData() async {
    isLoading.value = true;
    String? token = await TokenService.getToken();
    if (token == null) {
      print("Token is null");
      isLoading.value = false;
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    };

    try {
      var response =
          await _api.getrequst(linkuserprofile, "data", headers: headers);

      if (response != null && response is Map && response.containsKey("data")) {
        var data = response["data"];
        name.value = data["name"] ?? "";
        username.value = data["username"] ?? "";
        phone.value = data["phone"] ?? "";
        email.value = data["email"] ?? "";
        photo.value =
            data["photo"] != null ? "$linkservername/${data["photo"]}" : "";
        country.value = data["country"] ?? "";
        notificationsCount.value = data["notifications_count"] ?? 0;
        messageCount.value = data["message_count"] ?? 0;

        update();
      } else {
        print("The response is not in JSON format or missing 'data' key");
      }
    } catch (e) {
      print("Error caught: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class ProfilePage extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile".tr,
            style: TextStyle(
                fontSize: 40, fontFamily: "Caveat", color: Colors.blue)),
        backgroundColor: Color(0xFFF9EFC7),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        }

        return ListView(
          children: [
            Stack(
              children: [
                Container(
                  height: height * 0.3,
                  width: width,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9EFC7),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(145)),
                  ),
                ),
                Column(
                  children: [
                    SizedBox(height: 150),
                    Center(
                      child: Stack(
                        children: [
                          Obx(
                            () {
                              String imageUrl = controller.photo.value;

                              return CircleAvatar(
                                radius: 100,
                                backgroundImage: imageUrl.startsWith(
                                        "http") // تحقق مما إذا كانت الصورة من الإنترنت
                                    ? NetworkImage(imageUrl)
                                    : FileImage(File(imageUrl))
                                        as ImageProvider,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 20,
                            right: 10,
                            child: IconButton(
                              icon: Container(
                                decoration: BoxDecoration(
                                    color:
                                        const Color.fromARGB(93, 72, 155, 223),
                                    borderRadius: BorderRadius.circular(25)),
                                child: Icon(
                                  Icons.edit,
                                  size: 45,
                                  color:
                                      const Color.fromARGB(255, 56, 103, 255),
                                ),
                              ),
                              onPressed: () {
                                showImagePickerOptions(context);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Obx(() => Text(
                          controller.name.value.isNotEmpty
                              ? controller.name.value
                              : "الاسم غير متاح",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                    SizedBox(height: 20),
                    Obx(() => infoTileWithCopy(
                        Icons.person,
                        'Username'.tr,
                        controller.username.value.isNotEmpty
                            ? controller.username.value
                            : "غير متاح")),
                    Obx(() => infoTile(
                        Icons.phone,
                        'Phone'.tr,
                        controller.phone.value.isNotEmpty
                            ? controller.phone.value
                            : "غير متاح")),
                    Obx(() => infoTile(
                        Icons.email,
                        'Email'.tr,
                        controller.email.value.isNotEmpty
                            ? controller.email.value
                            : "غير متاح")),
                    Obx(() => infoTile(
                        Icons.location_on,
                        'Location'.tr,
                        controller.country.value.isNotEmpty
                            ? controller.country.value
                            : "غير متاح")),
                    SizedBox(height: 10),
                    Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            await Get.to(AddProfilePage(
                              phone: controller.phone.value,
                              name: controller.name.value,
                              email: controller.email.value,
                              location: controller.country.value,
                              username: controller.username.value,
                            ));

                            controller.getData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2B77B6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit, color: Colors.white),
                                SizedBox(width: 10),
                                Text("Edit Profile".tr,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ],
        );
      }),
    );
  }

  Widget infoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(width: 20),
            Text(subtitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void showImagePickerOptions(BuildContext context) {
    File? _selectedImage;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) => Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose an image".tr,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListTile(
                leading: Icon(Icons.photo, color: Colors.blueAccent),
                title: Text("Selection from the Gallery".tr),
                onTap: () async {
                  File? image = await _pickImage(ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Colors.green),
                title: Text("Take a new photo".tr),
                onTap: () async {
                  File? image = await _pickImage(ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedImage = image;
                    });
                  }
                },
              ),
              if (_selectedImage != null) ...[
                SizedBox(height: 10),
                Image.file(_selectedImage!, height: 100),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _uploadImage(_selectedImage!, context),
                  icon: Icon(
                    Icons.cloud_upload,
                  ),
                  label: Text("Upload image".tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

 Future<File?> _pickImage(ImageSource source) async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1000,
    );

    if (pickedFile == null) return null;

    // اقرأ الصورة كـ bytes
    final originalBytes = await pickedFile.readAsBytes();

    // فك ترميز الصورة
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return null;

    // حول الصورة إلى JPEG
    final jpgBytes = img.encodeJpg(decodedImage);

    // احفظ الصورة مؤقتًا
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final jpgFile = await File(tempPath).writeAsBytes(jpgBytes);

    return jpgFile;
  } catch (e) {
    Get.snackbar(
      "خطأ",
      "حدث خطأ أثناء اختيار الصورة",
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return null;
  }
}

  Future<void> _uploadImage(File image, BuildContext context) async {
    try {
      // عرض مؤشر التحميل
      Get.dialog(
        Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
          ),
        ),
        barrierDismissible: false,
      );

      // جلب التوكن
      String? token = await TokenService.getToken();
      if (token == null) {
        Get.back(); // إغلاق مؤشر التحميل
        Get.snackbar(
          "خطأ",
          "لم يتم العثور على توكن صالح",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // إنشاء طلب multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(linkeidetprofile),
      );

      // إضافة الصورة كملف
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();
      var multipartFile = http.MultipartFile(
        'photo', // اسم الحقل الذي يتوقعه السيرفر
        stream,
        length,
        filename: basename(image.path),
      );

      request.files.add(multipartFile);

      // إضافة الheaders
      request.headers.addAll({
        "Accept": "application/json",
        "lang": "ar",
        "Authorization": "Bearer $token"
      });

      // إرسال الطلب
      var response = await request.send();
      controller.photo.value = image.path;
      controller.update();
      // إغلاق مؤشر التحميل
      Get.back();

      // التحقق من الاستجابة
      if (response.statusCode == 200) {
        // إغلاق bottom sheet
        Get.back();

        Get.snackbar(
          "تم التحديث",
          "تم رفع الصورة بنجاح",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // إرجاع البيانات للصفحة السابقة
      } else {
        Get.snackbar(
          "خطأ",
          "حدث خطأ أثناء رفع الصورة",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // إغلاق مؤشر التحميل
      Get.snackbar(
        "خطأ",
        "حدث خطأ غير متوقع: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget infoTileWithCopy(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: Colors.blue),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                "$subtitle",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(Icons.copy, color: Colors.grey),
              onPressed: () {
                Clipboard.setData(ClipboardData(
                    text:
                        "${'To add this user to the Gift Dose application, search for this username:'.tr} $subtitle "));
                Get.snackbar(
                  "",
                  "Username copied successfully!".tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green.withOpacity(0.8),
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
