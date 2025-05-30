import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';

class Exceptionspage2 extends StatefulWidget {
  const Exceptionspage2({super.key});

  @override
  State<Exceptionspage2> createState() => _Exceptionspage2State();
}

class _Exceptionspage2State extends State<Exceptionspage2> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();
  var isLoading = false.obs;
  List<Map<String, dynamic>> _friendList = [];
  List<int> hiddenUserIds = [];
  List<int> selectedFriendIds = [];
  int _loadLimit = 20;
  int giftId = 0;
  @override
  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args["giftId"] != null) {
      giftId = args["giftId"];
    }
    _scrollController.addListener(_scrollListener); // ✅ إضافة المستمع
    _loadData();
  }

  void _loadData() async {
    await _fetchHiddenUsers(
        giftId); // ✅ انتظر تحميل الـ hidden users قبل جلب الأصدقاء
    _fetchFriends("");
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading.value) {
      setState(() => _loadLimit += 10);
      _fetchFriends("");
    }
  }

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

        setState(() {
          hiddenUserIds =
              hiddenUsers.map<int>((user) => user["id"] as int).toList();
          selectedFriendIds =
              List.from(hiddenUserIds); // ✅ تأكد إن hiddenUserIds فيها البيانات
        });
      } else {
        print("❌ No hidden users found in response!");
      }
    } catch (e) {
      print("❌ Error fetching hidden users: $e");
    }
  }

  Future<void> _fetchFriends(String query) async {
    isLoading.value = true;
    final String? token = await TokenService.getToken();
    if (token == null) {
      isLoading.value = false;
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token",
    };
    String apiUrl = '$friend/$query?load=$_loadLimit';
    try {
      var response = await _api.getrequst3(apiUrl, query, headers: headers);

      if (response['data'] != null && response['data']['data'] is List) {
        setState(() {
          _friendList =
              List<Map<String, dynamic>>.from(response['data']['data']);

          for (var user in _friendList) {
            if (hiddenUserIds.contains(user['id']) &&
                !selectedFriendIds.contains(user['id'])) {
              selectedFriendIds.add(user['id']);
            }
          }
        });
      } else {
        print("❌ No friends data found!");
      }
    } catch (e) {
      print("❌ Error fetching friends data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF9EFC7),
              child: SafeArea(
                child: Container(
                  width: width,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9EFC7),
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(100000)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Exception'.tr,
                        style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _listSection()),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: Size(width * 0.8, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25)),
                        ),
                        onPressed: () {
                          Get.back(
                              result:
                                  selectedFriendIds); // إرجاع القائمة المحددة
                        },
                        child: const Text("إرسال المحددين",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20)),
                      ),
                      const SizedBox(height: 20),
                    ],
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
        ],
      ),
    );
  }

  Widget _listSection() {
    return Obx(
      () => isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _friendList.length,
              itemBuilder: (context, index) {
                final user = _friendList[index];
                return _friendCard(
                  name: user['name'] ?? 'Unknown',
                  image: "$linkservername/${user['photo']}",
                  userId: user['id'],
                  isChecked: selectedFriendIds.contains(user['id']),
                  onChanged: (bool? newValue) {
                    setState(() {
                      if (newValue == true) {
                        selectedFriendIds.add(user['id']);
                      } else {
                        selectedFriendIds.remove(user['id']);
                      }
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _friendCard({
    required String name,
    required String image,
    required int userId,
    required bool isChecked,
    required Function(bool?) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.network(image, width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Checkbox(
          value: selectedFriendIds
              .contains(userId), // ✅ تحقق بناءً على selectedFriendIds
          onChanged: (bool? newValue) {
            setState(() {
              if (newValue == true) {
                selectedFriendIds.add(userId);
              } else {
                selectedFriendIds.remove(userId);
              }
            });
          },
        ),
      ),
    );
  }
}
