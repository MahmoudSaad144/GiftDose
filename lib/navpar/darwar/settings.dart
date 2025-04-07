import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? isContactsLinked;
  bool? isFindWithPhone;
  bool? isNotificationsEnabled;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    checkPermissions();
    _userdata();
  }

  Future<void> checkPermissions() async {
    setState(() {});
  }

  ApiService _api = ApiService();

  Future<void> _userdata() async {
    final token = await TokenService.getToken();
    if (token == null) return;
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final response = await _api.getrequst(linkuserprofile, "", headers: {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    });

    if (response != null && response["status"] == "success") {
      setState(() {
        isNotificationsEnabled = response["data"]["noti_status"] == 1;
        isContactsLinked = response["data"]["contacts_status"] == 1;
        isFindWithPhone = response["data"]["phone_search"] == 1;
        isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String endpoint) async {
    final token = await TokenService.getToken();
    if (token == null) return;

    final response = await _api.getrequst(endpoint, "", headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token"
    });

    if (response != null && response["status"] == "success") {
      setState(() {
        isNotificationsEnabled = response["data"]["noti_status"] == 1;
        isContactsLinked = response["data"]["contacts_status"] == 1;
        isFindWithPhone = response["data"]["phone_search"] == 1;
      });
    }
  }

  Future<void> _togglePermission(
      Permission permission, bool value, Function(bool) updateState) async {
    if (value) {
      PermissionStatus status = await permission.request();
      if (status.isGranted) {
        updateState(true);
      } else {
        _showPermissionDialog(permission);
        updateState(false);
      }
    } else {
      updateState(false);
    }
  }

  void _showPermissionDialog(Permission permission) {
    String permissionName = permission == Permission.contacts
        ? "Contacts"
        : permission == Permission.notification
            ? "Notifications"
            : "Permission";

    Get.defaultDialog(
      title: "Permission Required",
      middleText: "Please enable $permissionName permission in settings.",
      textConfirm: "Open Settings",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: openAppSettings,
    );
  }

  Widget languageTile(double iconSize, double fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: MaterialButton(
        onPressed: () async {
          Locale newLocale =
              (Get.locale?.languageCode == 'en') ? Locale('ar') : Locale('en');

          await LanguageService.changeLanguage(newLocale);
          await LanguageService.saveLanguage(newLocale);
          setState(() {});
        },
        child: Row(
          children: [
            Icon(Icons.language_rounded, size: iconSize, color: Colors.blue),
            SizedBox(width: 10),
            Text("Arabic".tr,
                style: TextStyle(fontSize: fontSize, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = screenWidth * 0.05;
    double iconSize = screenWidth * 0.08;
    double fontSize = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'.tr,
            style: TextStyle(fontSize: fontSize * 1.2, color: Colors.blue)),
        backgroundColor: Color(0xFFF9EFC7),
        elevation: 0,
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return isLoading // <-- عرض تحميل أثناء جلب البيانات
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : ListView(
                  padding: EdgeInsets.all(padding),
                  children: [
                    infoTile(
                        Icons.contacts,
                        "Contact Linking".tr,
                        isContactsLinked,
                        iconSize,
                        fontSize,
                        () => _updateStatus(contactsstatus)),
                    SizedBox(height: padding),
                    infoTile(
                        Icons.phone,
                        "Find by phone number".tr,
                        isFindWithPhone,
                        iconSize,
                        fontSize,
                        () => _updateStatus(phonesearch)),
                    SizedBox(height: padding),
                    infoTile(
                        Icons.notifications,
                        "Notifications".tr,
                        isNotificationsEnabled,
                        iconSize,
                        fontSize,
                        () => _updateStatus(notistatus)),
                    SizedBox(height: padding),
                    languageTile(iconSize, fontSize),
                  ],
                );
        },
      ),
    );
  }

  Widget infoTile(IconData icon, String title, bool? value, double iconSize,
      double fontSize, VoidCallback onTap) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: iconSize, color: Colors.blue),
              SizedBox(width: 10),
              Text(title,
                  style: TextStyle(fontSize: fontSize, color: Colors.black)),
            ],
          ),
          Switch(
            value: value ?? false,
            onChanged: (value) => onTap(),
          ),
        ],
      ),
    );
  }
}
