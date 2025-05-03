import 'dart:convert';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/gifts/add_gifts.dart';
import 'package:giftdose/navpar/message/chat.dart';
import 'package:giftdose/translation/language_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendProfilePage extends StatefulWidget {
  final String userId;

  const FriendProfilePage({super.key, required this.userId});

  @override
  State<FriendProfilePage> createState() => _FriendProfilePageState();
}

class _FriendProfilePageState extends State<FriendProfilePage> {
  final ApiService _api = ApiService();
  var isLoading = false.obs;
  var userData = {}.obs;
  var _showGifts = true.obs;
  var isFriend = false.obs;
  var isLoadingFriendRequest = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _cancelFriendRequest(int userId) async {
    try {
      isLoadingFriendRequest.value = true; // تحديث الحالة عند بدء العملية
      final String? token = await TokenService.getToken();
      if (token == null) {
        isLoadingFriendRequest.value =
            false; // إعادة تعيين الحالة في حالة الخطأ
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "id": userId.toString(),
      };

      final response = await _api.postRequest(removefereind, body, headers);

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          userData['senderfriendship'] = null;
          userData['receiverfriendship'] = null;
          userData['friendstatus'] = false;
          _fetchUserData();
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingFriendRequest.value = false; // إعادة تعيين الحالة بعد الانتهاء
    }
  }

  Future<void> _fetchUserData() async {
    isLoading.value = true;

    String? token = await TokenService.getToken();
    if (token == null) {
      print("⚠️ Token is null");
      isLoading.value = false;
      return;
    }

    String apiUrl = "$linkfrienduser/${widget.userId}";
    Locale savedLocale = await LanguageService.getSavedLanguage();

    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "lang": "$savedLocale",
    };

    try {
      var response = await _api.getrequst3(apiUrl, "", headers: headers);

      if (response != null && response['status'] == 'success') {
        userData.value = response['data'];
        isFriend.value = userData['friendstatus'];
      } else {
        print("⚠️ No valid data found.");
      }
    } catch (e) {
      print("❌ Error fetching user data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendFriendRequest(int userId) async {
    try {
      isLoadingFriendRequest.value = true;

      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        isLoadingFriendRequest.value = false;
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "receiver": userId.toString(),
      };

      final response = await _api.postRequest(sendaddfreind, body, headers);

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          userData['senderfriendship'] = {"id": 1};
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingFriendRequest.value = false;
    }
  }

  Future<void> _acceptfriend(int userId) async {
    try {
      isLoadingFriendRequest.value = true;

      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        isLoadingFriendRequest.value = false;
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "sender": userId.toString(),
      };

      final response = await _api.postRequest(acceptfriend, body, headers);

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          userData['senderfriendship'] = {"id": 1};
          _fetchUserData();
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingFriendRequest.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;
          double height = constraints.maxHeight;
          return Obx(() {
            if (isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Colors.blue,
              ));
            }

            if (userData.isEmpty) {
              return Center(child: Text("No data available.".tr));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: height,
                        width: width,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9EFC7),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(10000000),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 50),
                          Padding(
                            padding: EdgeInsets.all(width * 0.04),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "$linkservername/${userData['photo']}"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  height: width * 0.3,
                                  width: width * 0.3,
                                ),
                                SizedBox(height: height * 0.015),
                                Text(userData['name'] ?? "Unknown",
                                    style: TextStyle(
                                        fontSize: width * 0.06,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 20),
                                Obx(() => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        isLoadingFriendRequest.value
                                            ? const CircularProgressIndicator()
                                            : _getFriendshipActionButton(),
                                        const SizedBox(width: 10),
                                        actionButton(
                                          Icons.message,
                                          Colors.green,
                                          () => Get.to(ChatPage(
                                            userId: widget.userId,
                                            userName: userData['name'],
                                            userPhoto:
                                                "$linkservername/${userData['photo']}",
                                          )),
                                        ),
                                      ],
                                    )),
                                SizedBox(height: height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                        child: infoColum(
                                      mywidth: width,
                                      myBool: true,
                                      Location: userData['country'] ?? "",
                                      email: userData['email'] ?? "",
                                      username: userData['username'] ?? "",
                                      phone: userData['phone'] ?? "",
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: height * 0.015),
                          Row(
                            children: [
                              _sectionButton("Gifts".tr, _showGifts.value, () {
                                _showGifts.value = true;
                              },
                                  const ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(100)))),
                              _sectionButton("Occasion".tr, !_showGifts.value,
                                  () {
                                _showGifts.value = false;
                              },
                                  const ContinuousRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(100))))
                            ],
                          ),
                          SizedBox(
                            height: height * 0.9,
                            child: Obx(() {
                              int itemCount = _showGifts.value
                                  ? (userData['gift']?.length ?? 0)
                                  : (userData['occasion']?.length ?? 0);

                              if (itemCount == 0) {
                                return Center(
                                  child: Text(
                                    "No results found.".tr,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                itemCount: itemCount,
                                itemBuilder: (context, index) {
                                  return _showGifts.value
                                      ? _giftCard(
                                          userData['gift'][index],
                                          width,
                                          height,
                                          userData['gift'][index]['id'])
                                      : _eventCard(userData['occasion'][index],
                                          width, height);
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  TextEditingController notesController = TextEditingController();

  final RxMap<int, bool> isLoadingGifts = <int, bool>{}.obs;
  Future<void> _buygifts(int giftid) async {
    try {
      isLoadingGifts[giftid] = true; // تحديث الحالة عند بدء العملية
      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        isLoadingGifts[giftid] = false; // إعادة تعيين الحالة في حالة الخطأ
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };
      String note = notesController.text;
      final Map<String, dynamic> body = {"id": giftid.toString(), "note": note};

      final response = await _api.postRequest(buygift, body, headers);

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          _fetchUserData();
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingGifts[giftid] = false; // إعادة تعيين الحالة بعد الانتهاء
    }
  }

  Future<void> _recovery(
    int giftid,
  ) async {
    try {
      isLoadingGifts[giftid] = true;
      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        isLoadingGifts[giftid] = false;
        return;
      }
      Locale savedLocale = await LanguageService.getSavedLanguage();
      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      };

      final response = await _api.getrequst(
        "https://giftdose.com/api/cancelgift/$giftid ",
        "",
        headers: headers,
      );

      if (response != null && response["status"] == "success") {
        _fetchUserData();
      } else {
        debugPrint("Error: Unexpected response format");
      }
    } catch (e) {
      debugPrint("Error fetching occasions: $e");
    } finally {
      isLoadingGifts[giftid] = false;
    }
  }

  Widget _giftCard(
      Map<String, dynamic> gift, double width, double height, int giftid) {
    bool isPurchased = gift['purchased_status'] != null;
    bool isPurchasedit = gift['bought_it'] != 1;

    return Stack(
      children: [
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 5,
          margin: EdgeInsets.symmetric(
              horizontal: width * 0.04, vertical: height * 0.015),
          child: Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                              "$linkservername/${gift['photo']}",
                              height: width * 0.53,
                              width: width * 0.4,
                              fit: BoxFit.cover),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${'name'.tr}: ${gift['name']}",
                              style: TextStyle(
                                  fontSize: width * 0.04,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              "${'price'.tr}: ${gift['price']} ( ${gift['currency']})",
                              style: TextStyle(
                                  fontSize: width * 0.04, color: Colors.green)),
                          Text("${'color'.tr}: ${gift['color']}",
                              style: TextStyle(fontSize: width * 0.035)),
                          Text("${'Size'.tr}: ${gift['size']} ",
                              style: TextStyle(fontSize: width * 0.035)),
                          Text("${'location'.tr}: ${gift['address']}",
                              style: TextStyle(fontSize: width * 0.035)),
                          Text("${'Notes'.tr}: ${gift['note'] ?? ""}",
                              style: TextStyle(fontSize: width * 0.035)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (!isPurchased)
                  CustomTextField(
                      controller: notesController,
                      label: "Notes".tr,
                      maxLines: 2),
                if (!isPurchased)
                  Obx(() => Column(
                        children: [
                          MaterialButton(
                            onPressed: isLoadingGifts[giftid] == true
                                ? null
                                : () => _buygifts(gift[
                                    'id']), // تأكد من أن الدالة لا تُستدعى تلقائيًا
                            child: Center(
                              child: Container(
                                width: width * 6,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: isLoadingGifts[giftid] == true
                                      ? null
                                      : LinearGradient(
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
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isLoadingGifts[giftid] == true)
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    else
                                      Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                      ),
                                    SizedBox(width: 5),
                                    Text(
                                      isLoadingGifts[giftid] == true
                                          ? "Loading...".tr
                                          : "Buy".tr,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
                if (!isPurchasedit)
                  Obx(() => Column(
                        children: [
                          MaterialButton(
                            onPressed: isLoadingGifts[giftid] == true
                                ? null
                                : () => _recovery(gift[
                                    'id']), // تأكد من أن الدالة لا تُستدعى تلقائيًا
                            child: Center(
                              child: Container(
                                width: width * 6,
                                height: height * 0.05,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  gradient: isLoadingGifts[giftid] == true
                                      ? null
                                      : LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          colors: [
                                            Color.fromARGB(255, 182, 43, 43)
                                                .withOpacity(1),
                                            Color.fromARGB(255, 211, 86, 86)
                                                .withOpacity(1),
                                            Color.fromARGB(255, 255, 121, 121)
                                                .withOpacity(1),
                                          ],
                                        ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isLoadingGifts[giftid] == true)
                                      CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    else
                                      SizedBox(width: 5),
                                    Text(
                                      isLoadingGifts[giftid] == true
                                          ? "Loading...".tr
                                          : 'Cancel'.tr,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
              ],
            ),
          ),
        ),
        if (isPurchased)
          Positioned(
            top: height * 0.06, // بدلاً من رقم ثابت
            left: width * 0.02, // تحسين المحاذاة حسب الشاشة
            right: width * 0.5, // تقليل العرض ليتناسب مع الشاشات المختلفة
            child: Transform.rotate(
              angle: -0.5,
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: height * 0.009), // بدلاً من 8 ثابتة
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromARGB(200, 244, 67, 54),
                  borderRadius: BorderRadius.all(Radius.circular(
                      width * 0.03)), // تحسين الاستدارة حسب العرض
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2),
                  child: Text(
                    gift['purchased_status'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,

                      // تحسين حجم الخط تلقائيًا
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _getFriendshipActionButton() {
    return Obx(() {
      bool isFriend = userData['friendstatus'] == true;
      bool senderFriendship = userData['senderfriendship'] != null;
      bool receiverFriendship = userData['receiverfriendship'] != null;
      int? receiverStatus = userData['receiverfriendship']?['status'];

      if (isFriend || receiverStatus == 1) {
        return actionButton(Icons.person_remove, Colors.red, () {
          _cancelFriendRequest(int.parse(widget.userId));
        });
      } else if (receiverFriendship) {
        return actionButton(Icons.check_circle, Colors.green, () {
          _acceptfriend(int.parse(widget.userId));
        });
      } else if (senderFriendship) {
        return actionButton(Icons.person_remove, Colors.red, () {
          _cancelFriendRequest(int.parse(widget.userId));
        });
      } else {
        return actionButton(Icons.person_add, Colors.blue, () {
          _sendFriendRequest(int.parse(widget.userId));
        });
      }
    });
  }

  Widget actionButton(
    IconData icon,
    Color color,
    void Function()? onPressed,
  ) {
    return Container(
      height: 50,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: color,
      ),
      child: MaterialButton(
        onPressed: onPressed,
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

Widget _eventCard(Map<String, dynamic> event, double width, double height) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    elevation: 5,
    margin:
        EdgeInsets.symmetric(vertical: height * 0.01, horizontal: width * 0.03),
    child: ListTile(
      title: Row(
        children: [
          Icon(Icons.event, color: Colors.blue, size: width * 0.07),
          SizedBox(width: width * 0.03),
          Text(event['name'], style: TextStyle(fontSize: width * 0.045)),
        ],
      ),
      subtitle: Text(event['day'], style: TextStyle(fontSize: width * 0.04)),
    ),
  );
}

Widget _sectionButton(
    String title, bool isSelected, VoidCallback onTap, OutlinedBorder? shape) {
  return Expanded(
    child: SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? Color.fromARGB(255, 0, 140, 255).withOpacity(0.6)
              : Colors.white,
          shape: shape,
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ),
      ),
    ),
  );
}

class infoColum extends StatelessWidget {
  final double mywidth;
  final bool myBool;
  final String email;
  final String phone;
  final String Location;
  final String username;

  const infoColum({
    super.key,
    required this.myBool,
    required this.email,
    required this.phone,
    required this.Location,
    required this.mywidth,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        infoTile(
          Icons.person,
          username,
        ),
        SizedBox(height: mywidth * 0.02),
        infoTile(
          Icons.email,
          email,
        ),
        SizedBox(height: mywidth * 0.02),
        infoTile(
          Icons.phone,
          phone,
        ),
        SizedBox(height: mywidth * 0.02),
        infoTile(
          Icons.location_pin,
          Location,
        ),
      ],
    );
  }
}

Widget infoTile(
  IconData icon,
  String title,
) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 30,
          color: Colors.blue,
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
