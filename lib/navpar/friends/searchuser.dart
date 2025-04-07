import 'package:giftdose/Controller/frind%20and%20%20rqust/friend.dart';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchFriendsWidget extends StatefulWidget {
  const SearchFriendsWidget({Key? key}) : super(key: key);

  @override
  _SearchFriendsWidgetState createState() => _SearchFriendsWidgetState();
}

class _SearchFriendsWidgetState extends State<SearchFriendsWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredSearchResults = [];
  final Map<String, bool> _loadingState = {};
  final int _loadLimit = 13;
  ApiService _api = ApiService();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          hintText: 'Search user...'.tr,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(50)),
        ),
        onTap: () => _showSearchDialog(context),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    _searchController.clear();
    _filteredSearchResults = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                height: 600,
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(99, 249, 239, 199),
                  borderRadius:
                      BorderRadius.only(bottomLeft: Radius.circular(100000)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.blue),
                        hintText: 'Search user...'.tr,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50)),
                      ),
                      onChanged: (value) async {
                        if (value.isEmpty) {
                          setState(() => _filteredSearchResults = []);
                        } else {
                          await _fetchSearchResults(value);
                          if (mounted) setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    Expanded(
                      child: _filteredSearchResults.isEmpty
                          ? Center(child: Text("No results found.".tr))
                          : ListView.builder(
                              itemCount: _filteredSearchResults.length,
                              itemBuilder: (context, index) {
                                var user = _filteredSearchResults[index];
                                return _userSearchCard(user, setState);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _userSearchCard(Map<String, dynamic> user,
      void Function(void Function()) setStateCallback) {
    String userId = user['id']?.toString() ?? '0';
    bool isFriend = (user['senderfriendship']?['status'] ?? 0) == 1 ||
        (user['receiverfriendship']?['status'] ?? 0) == 1;
    bool senderFriendship = user['senderfriendship'] != null;
    bool receiverFriendship = user['receiverfriendship'] != null;
    bool isLoading = _loadingState[userId] ?? false;
    Widget trailingIcon = isLoading
        ? const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue,
            ),
          )
        : isFriend
            ? IconButton(
                icon: const Icon(Icons.message, color: Colors.blue),
                onPressed: () {},
              )
            : receiverFriendship
                ? IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () async {
                      await _acceptaddfriendt(
                          int.parse(userId), setStateCallback);
                    },
                  )
                : IconButton(
                    icon: Icon(
                        senderFriendship ? Icons.cancel : Icons.person_add,
                        color: senderFriendship ? Colors.red : Colors.blue),
                    onPressed: () async {
                      setStateCallback(() => _loadingState[userId] = true);
                      senderFriendship
                          ? await _cancelAddFriend(
                              int.parse(userId)) // إلغاء الطلب
                          : await _addFriend(int.parse(userId)); // إرسال الطلب
                      setStateCallback(() => _loadingState[userId] = false);
                    },
                  );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: GestureDetector(
          onTap: () => Get.to(() => FriendProfilePage(userId: userId)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              "$linkservername/${user['photo']}",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Image.asset('images/avatar.png'),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () => Get.to(() => FriendProfilePage(userId: userId)),
          child: Text(user['name'] ?? 'Unknown'),
        ),
        trailing: trailingIcon,
      ),
    );
  }

  Future<void> _acceptaddfriendt(
      int userId, void Function(void Function()) setStateCallback) async {
    setStateCallback(() => _loadingState[userId.toString()] = true);

    await _sendFriendRequest(userId, acceptfriend, "sender");

    setStateCallback(() {
      _loadingState[userId.toString()] = false;

      // تحديث حالة الصداقة ليصبح Friend (أي تتحول الأيقونة إلى الرسائل)
      for (var user in _filteredSearchResults) {
        if (user['id'].toString() == userId.toString()) {
          user['senderfriendship'] = {'status': 1}; // تحديد أنه أصبح صديق
          break;
        }
      }
    });
  }

  Future<void> _addFriend(int userId) async {
    await _sendFriendRequest(userId, sendaddfreind, "receiver");
  }

  Future<void> _cancelAddFriend(int userId) async {
    await _sendFriendRequest(userId, removefereind, "id");
  }

  Future<void> _sendFriendRequest(
      int userId, String endpoint, String idOrRECEIVER) async {
    try {
      final String? token = await TokenService.getToken();
      if (token == null) return;
      Locale savedLocale = await LanguageService.getSavedLanguage();
      final response = await _api.postRequest(
        endpoint,
        {idOrRECEIVER: userId.toString()},
        {
          "Accept": "application/json",
          "lang": "$savedLocale",
          "Authorization": "Bearer $token"
        },
      );

      if (response != null && response.statusCode == 200) {
        await _fetchSearchResults(_searchController.text);
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    final token = await TokenService.getToken();
    if (token == null) return;
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final response = await _api
        .getrequst3('$searchuser/$query?load=$_loadLimit', "", headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "lang": "$savedLocale",
    });

    setState(() {
      _filteredSearchResults = response?['data'] is List
          ? List<Map<String, dynamic>>.from(response['data'])
          : [];
    });
  }
}
