import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chat.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSearchResults = [];
  var isLoading = false.obs;
  var id = "".obs;
  int _loadLimit = 20;
  var conversations1 = <Map<String, dynamic>>[].obs;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchChats("");
    _fetchUserId();
  }

  Future<void> _fetchUserId() async {
    int? fetchedId = await TokenService.getUserId();
    if (fetchedId != null && mounted) {
      id.value = fetchedId.toString();
    }
  }

  Future<void> _fetchChats(String query) async {
    if (!mounted) return;
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

    try {
      var response = await _api.getrequst3(
          '$chats?load=$_loadLimit&search=$query', "",
          headers: headers);
      if (mounted) {
        conversations1.value = response['data']?['data'] is List
            ? List<Map<String, dynamic>>.from(response['data']['data'])
            : [];
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch chats: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: height,
          width: width,
          decoration: const BoxDecoration(
            color: Color(0xFFF9EFC7),
            borderRadius:
                BorderRadius.only(bottomLeft: Radius.circular(100000)),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.blue),
                    hintText: 'Search user...'.tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  onChanged: (value) {
                    _fetchChats(value);
                    setState(() {});
                  },
                ),
              ),
              Obx(() {
                if (isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
                if (conversations1.isEmpty) {
                  return Center(
                      child: Text("No chats available 📭".tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)));
                }
                return Expanded(
                  child: ListView.builder(
                    itemCount: conversations1.length,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    itemBuilder: (context, index) {
                      final user = conversations1[index];
                      bool isUnread = user['receiver'].toString() == id.value &&
                          user['last_message_status'].toString() == "0";
                      return Card(
                        color: isUnread
                            ? const Color.fromARGB(255, 213, 242, 214)
                            : Colors.white,
                        elevation: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                              "$linkservername/${user['photo']}",
                            ),
                          ),
                          title: Text(user['name']!,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(user['last_message'],
                              style: const TextStyle(color: Colors.black)),
                          onTap: () async {
                            bool? needRefresh = await Get.to(ChatPage(
                              userId: user['id'].toString(),
                              userName: user['name'],
                              userPhoto: "$linkservername/${user['photo']}",
                            ));
                            if (needRefresh == true) {
                              _fetchChats("");
                            }
                          },
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
