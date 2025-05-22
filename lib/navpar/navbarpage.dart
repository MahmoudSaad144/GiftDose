import 'dart:convert';

import 'dart:io';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/darwar/occasions/occasions.dart';
import 'package:giftdose/translation/language_service.dart';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/fanction/card.dart';
import 'package:giftdose/fanction/inkall.dart';
import 'package:giftdose/navpar/darwar/App_inf/about.dart';
import 'package:giftdose/navpar/darwar/App_inf/po;icy.dart';
import 'package:giftdose/navpar/darwar/App_inf/terms.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/navpar/gifts/gifts.dart';
import 'package:giftdose/navpar/message/masseg.dart';
import 'package:giftdose/navpar/nafication.dart';
import 'package:giftdose/navpar/friends/userandfrinds.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

class Navbarpage extends StatefulWidget {
  const Navbarpage({super.key});

  @override
  State<Navbarpage> createState() => _NavigationBarState();
}

class _NavigationBarState extends State<Navbarpage> {
  final ProfileController controller = Get.find<ProfileController>();
  var messageCount = "".obs; // عدد الرسائل الغير مقرؤة (افتراضي)
  var notificationsCount = "".obs;
  var email = "".obs;
  var photo = "".obs;
  var name = "".obs;
  ApiService _api = ApiService();
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
  }

  void logout() async {
    bool isLoggedOut = await TokenService.removeToken();
    if (isLoggedOut) {
      print("User logged out successfully");
      Get.offAllNamed("/1");
    } else {
      print("Failed to log out");
    }
  }

  Future<void> Delete_account() async {
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
      "Authorization": "Bearer $token",
    };
    Map<String, dynamic> body = {};

    try {
      var response = await _api.postRequest(deleteaccount, body, headers);
      final responseData = jsonDecode(response!.body);

      if (response.statusCode == 200) {
        Get.snackbar("تمت العمليه بنجاخ", "",
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offAllNamed("/1");
      } else {
        Get.snackbar("خطأ", responseData["message"] ?? "حدث خطأ أثناء التحديث",
            backgroundColor: Colors.red, colorText: Colors.white);
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

  void _MYdeleteOccasion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              content: Text(
                "Are you sure to delete?".tr,
                style: const TextStyle(fontSize: 20),
              ),
              Colortitle: Colors.red,
              dilogicon: Icons.question_mark_sharp,
              contentdilog: "Are you sure to delete?".tr,
              dilogiconcolor: Colors.red,
              fontsize: 20,
              namebottomdilog1: "Cancel".tr,
              onPressed1: () => Navigator.pop(context),
              onPressed2: () async {
                setState(() {
                  isLoading = true;
                });

                await Delete_account(); // تنفيذ حذف الحساب
              },
              namebottomdilog2: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                    ) // عرض اللودينج أثناء الحذف
                  : Text(
                      "Delete".tr,
                      style: TextStyle(color: Colors.white),
                    ),
              titledilog: "Warning".tr,
            );
          },
        );
      },
    );
  }

  int pageIndext = 0;

  final List<Widget> pages = [
    const GiftsPage(),
    Occasions(),
    UserAndFriendsPage(),
    const Naficationpage(),
    const MessagesPage(),
  ];
  final List<String> appBarTitles = [
    "Gifts".tr,
    "Occasions".tr,
    "Friends".tr,
    "Notifications".tr,
    "Messages".tr,
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        title: Text(
          "Gift Dose",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            fontFamily: "Caveat",
            color: Colors.blue,
          ),
        ),
        backgroundColor: Color(0xFFF9EFC7),
        centerTitle: true,
      ),
      drawerScrimColor: const Color.fromARGB(41, 255, 212, 212),
      drawer: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Color.fromARGB(255, 255, 251, 236),
        ),
        width: width * 0.8,
        child: SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: width * 0.04,
                  top: height * 0.03,
                ),
                child: Text(
                  "Menu".tr,
                  style: TextStyle(
                    fontSize: width * 0.08,
                    color: Colors.blue,
                  ),
                ),
              ),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              Padding(
                  padding: EdgeInsets.only(
                    top: height * 0.02,
                  ),
                  child: Obx(
                    () => CARD(
                      onTAP: () {
                        Get.to(ProfilePage());
                      },
                      imageProvider: controller.photo.value.startsWith("http")
                          ? NetworkImage(controller.photo.value)
                          : FileImage(File(controller.photo.value))
                              as ImageProvider,
                      title: controller.name.value,
                      subtitle: controller.email.value,
                    ),
                  )),
              INKWALL(
                onTAP: () {
                  Get.toNamed("/8");
                },
                icon: Icons.settings,
                name: "Settings".tr,
                color: const Color.fromARGB(255, 255, 255, 255),
                color2: Colors.black,
              ),
              INKWALL(
                onTAP: () {
                  Get.to(Aboutpage());
                },
                icon: Icons.question_mark_outlined,
                name: "About".tr,
                color: Color.fromARGB(255, 255, 255, 255),
                color2: Colors.black,
              ),
              INKWALL(
                onTAP: () {
                  Get.to(Termspage());
                },
                icon: Icons.privacy_tip_rounded,
                name: "Terms".tr,
                color: Color.fromARGB(255, 255, 255, 255),
                color2: Colors.black,
              ),
              INKWALL(
                onTAP: () {
                  Get.to(policypage());
                },
                icon: Icons.balance,
                name: "Policy".tr,
                color: Color.fromARGB(255, 255, 255, 255),
                color2: Colors.black,
              ),
              INKWALL(
                onTAP: () {
                  _MYdeleteOccasion();
                },
                icon: Icons.delete,
                name: "Delete Account".tr,
                color: Color.fromARGB(255, 249, 224, 224),
                color2: Colors.black,
              ),
              INKWALL(
                onTAP: () {
                  logout();
                },
                icon: Icons.logout,
                name: "Logout".tr,
                color: Color.fromARGB(255, 214, 252, 240),
                color2: Colors.black,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        height: isLandscape ? height * 0.20 : height * 0.1,
        color: const Color(0xFFF9EFC7),
        backgroundColor: Colors.transparent,
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.wallet_giftcard_sharp,
              size: isLandscape ? width * 0.05 : width * 0.09,
              color: Colors.blue,
            ),
            label: 'Gifts'.tr,
            labelStyle: TextStyle(fontSize: width * 0.025)
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.add_reaction_outlined,
              size: isLandscape ? width * 0.05 : width * 0.09,
              color: Colors.blue,
            ),
            label: "Occasions".tr,
            labelStyle: TextStyle(fontSize: width * 0.025)
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.supervised_user_circle_sharp,
              size: isLandscape ? width * 0.05 : width * 0.09,
              color: Colors.blue,
            ),
            label: 'Friends'.tr,
            labelStyle: TextStyle(fontSize: width * 0.025)
          ),
          CurvedNavigationBarItem(
            child: Obx(() => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.notifications_active,
                      size: isLandscape ? width * 0.05 : width * 0.09,
                      color: Colors.blue,
                    ),
                    if (controller.notificationsCount.value > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: badges.Badge(
                          badgeContent: Text(
                            "${controller.notificationsCount.value}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.red,
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                  ],
                )),
            label: 'Notifications'.tr,
            labelStyle: TextStyle(fontSize: width * 0.025)
          ),
          CurvedNavigationBarItem(
            child: Obx(() => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.messenger_outlined,
                      size: isLandscape ? width * 0.05 : width * 0.09,
                      color: Colors.blue,
                    ),
                    if (controller.messageCount.value > 0)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: badges.Badge(
                          badgeContent: Text(
                            "${controller.messageCount.value}",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          badgeStyle: badges.BadgeStyle(
                            badgeColor: Colors.red,
                            padding: EdgeInsets.all(5),
                          ),
                        ),
                      ),
                  ],
                )),
            label: 'Messages'.tr,
            labelStyle: TextStyle(fontSize: width * 0.025)
          ),
        ],
        onTap: (index) {
          if (index >= 0 && index < pages.length) {
            setState(() {
              pageIndext = index;
            });
          } else {
            print("تحذير: المؤشر خارج النطاق! index = $index");
          }
        },
      ),
      body: (pageIndext >= 0 && pageIndext < pages.length)
          ? pages[pageIndext]
          : pages[0], // عرض الصفحة بناءً على المؤشر الحالي
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String titledilog;
  final double? fontsize;
  final Color? Colortitle;
  final String? contentdilog;
  final String? namebottomdilog1;
  final Widget? namebottomdilog2;
  final Color? dilogiconcolor;
  final IconData? dilogicon;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final Widget? content;

  const CustomDialog({
    required this.titledilog,
    this.fontsize,
    this.Colortitle,
    this.contentdilog,
    this.namebottomdilog1,
    this.namebottomdilog2,
    this.dilogiconcolor,
    this.dilogicon,
    this.onPressed1,
    this.onPressed2,
    this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        titledilog,
        style: TextStyle(
          fontSize: fontsize ?? 18, // قيمة افتراضية
          color: Colortitle ?? Colors.black, // قيمة افتراضية
        ),
      ),
      content: content ??
          (contentdilog != null
              ? Text(
                  contentdilog!,
                  style: const TextStyle(fontSize: 16),
                )
              : null),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (namebottomdilog1 != null && onPressed1 != null)
              TextButton(
                onPressed: onPressed1,
                child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        colors: [
                          const Color.fromARGB(255, 43, 119, 182)
                              .withOpacity(1),
                          const Color.fromARGB(255, 86, 155, 211)
                              .withOpacity(1),
                          const Color.fromARGB(255, 121, 195, 255)
                              .withOpacity(1),
                        ],
                      ),
                    ),
                    child: Center(
                        child: Text(
                      namebottomdilog1!,
                      style: TextStyle(color: Colors.white),
                    ))),
              ),
            if (namebottomdilog2 != null && onPressed2 != null)
              TextButton(
                onPressed: onPressed2,
                child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        colors: [
                          Color.fromARGB(255, 182, 43, 43).withOpacity(1),
                          Color.fromARGB(255, 211, 86, 86).withOpacity(1),
                          Color.fromARGB(255, 255, 121, 121).withOpacity(1),
                        ],
                      ),
                    ),
                    child: Center(child: namebottomdilog2!)),
              ),
          ],
        )
      ],
      icon: dilogicon != null
          ? Icon(
              dilogicon,
              color: dilogiconcolor ?? Colors.black,
              size: 100,
            )
          : null,
    );
  }
}
