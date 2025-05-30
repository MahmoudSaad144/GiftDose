import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/gifts/add_gifts.dart';
import 'package:giftdose/translation/language_service.dart';

class Exceptionspage extends StatefulWidget {
  const Exceptionspage({super.key});

  @override
  State<Exceptionspage> createState() => _ExceptionspageState();
}

class _ExceptionspageState extends State<Exceptionspage> {
  final ScrollController _scrollController = ScrollController();
  var isLoading = false.obs;
  List<Map<String, dynamic>> _friendList = [];
  List<int> selectedFriendIds = [];
  int _loadLimit = 20;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchfriends("");
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isLoading.value) {
      setState(() => _loadLimit += 10);
      _fetchfriends("");
    }
  }

  Future<void> _fetchfriends(String query) async {
    isLoading.value = true;
    String? token = await TokenService.getToken();
    if (token == null) {
      isLoading.value = false;
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token",
    };

    String apiUrl = '$friend/$query?load=$_loadLimit';
    try {
      var response = await _api.getrequst3(apiUrl, query, headers: headers);
      setState(() {
        _friendList =
            response['data'] != null && response['data']['data'] is List
                ? List<Map<String, dynamic>>.from(response['data']['data'])
                : [];
      });
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
                        'Hide the gift from specific people'.tr,
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
                          Get.off(() => AddGiftPage(
                              selectedFriendIds: selectedFriendIds));
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
            value: selectedFriendIds.contains(userId), onChanged: onChanged),
      ),
    );
  }
}
