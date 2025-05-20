import 'dart:convert';
import 'package:giftdose/Controller/frind%20and%20%20rqust/friend.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/message/chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/Controller/token.dart';

class ConnectWithContacts extends StatefulWidget {
  const ConnectWithContacts({super.key});

  @override
  State<ConnectWithContacts> createState() => _ConnectWithContactsState();
}

class _ConnectWithContactsState extends State<ConnectWithContacts> {
  ApiService _api = ApiService();
  ScrollController _scrollController = ScrollController();
  var isLoading = false.obs;
  var friends = <Map<String, dynamic>>[].obs;
  int page = 1;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchContactsAndSendToAPI();

    // إضافة مستمع للتمرير للتحميل التدريجي
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        _fetchContactsAndSendToAPI(isLoadMore: true);
      }
    });
  }

  Future<void> _fetchContactsAndSendToAPI({bool isLoadMore = false}) async {
    if (_isFetching) return;
    _isFetching = true;
    isLoading.value = true;

    if (!isLoadMore) {
      page = 1;
      friends.clear();
    } else {
      page++;
    }

    // if (await FlutterContacts.requestPermission()) {
    //   List<Contact> contacts =
    //       await FlutterContacts.getContacts(withProperties: true);
    //   List<String> contactNumbers = contacts
    //       .expand((contact) => contact.phones
    //           .map((phone) => phone.number.replaceAll(RegExp(r'\D'), '')))
    //       .where((number) => number.isNotEmpty)
    //       .toList();

    //   if (contactNumbers.isNotEmpty) {
    //     await _sendContactsToAPI(contactNumbers);
    //   }
    // }

    isLoading.value = false;
    _isFetching = false;
  }

  Future<void> _sendContactsToAPI(List<String> contacts) async {
    final String? token = await TokenService.getToken();
    if (token == null) return;

    final response = await _api.postRequest(
      cotactnumberaccount,
      jsonEncode({"numbers": contacts, "page": page}),
      {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
    );

    if (response != null && response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["status"] == "success") {
        friends.addAll(List<Map<String, dynamic>>.from(responseData["data"]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFF9EFC7),
            borderRadius:
                BorderRadius.only(bottomLeft: Radius.circular(100000)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('Connect with Contacts'.tr,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 20),
              Expanded(child: Obx(() => _listSection())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: friends.isEmpty
          ? Center(
              child: isLoading.value
                  ? const CircularProgressIndicator(color: Colors.blue)
                  : Text('No results found.'.tr),
            )
          : ListView.builder(
              controller: _scrollController,
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var user = friends[index];
                return _friendCard(user);
              },
            ),
    );
  }

  Widget _friendCard(Map<String, dynamic> user) {
    String userId = user['id'].toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        margin: const EdgeInsets.only(bottom: 15),
        child: ListTile(
          leading: InkWell(
            onTap: () => Get.to(FriendProfilePage(userId: userId)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                "$linkservername/${user['photo']}",
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('images/avatar.png');
                },
              ),
            ),
          ),
          title: InkWell(
              onTap: () => Get.to(FriendProfilePage(userId: userId)),
              child: Text(user['name'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          trailing: IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () => Get.to(ChatPage(
              userId: userId,
              userName: user['name'] ?? 'Unknown',
              userPhoto: "$linkservername/${user['photo']}",
            )),
          ),
        ),
      ),
    );
  }
}
