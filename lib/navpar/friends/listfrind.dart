import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/frind%20and%20%20rqust/friend.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/message/chat.dart';
import 'package:giftdose/translation/language_service.dart';

class FriendsListSection extends StatefulWidget {
  @override
  State<FriendsListSection> createState() => _FriendsListSectionState();
}

class _FriendsListSectionState extends State<FriendsListSection> {
  var isLoading = false.obs; // استخدام RxBool لمراقبة حالة التحميل
  int _loadLimit = 20;
  List<Map<String, dynamic>> _friendList = []; // تخزين بيانات الأصدقاء
  final ApiService _api = ApiService();
  bool _isDisposed = false;
  final ScrollController _scrollController = ScrollController();
  bool scroll = false;
  bool _isRequesting = false;
  @override
  @override
  void initState() {
    super.initState();
    _fetchfriends("", false);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !isLoading.value) {
        if (_isRequesting) return;
        _loadLimit += 8; // ممكن تزود بدل 1 مرة واحدة
        _fetchfriends("", true);
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchfriends(String query, bool scroll) async {
    if (_isDisposed || _isRequesting) return;
    _isRequesting = true;
    if (scroll == false) {
      isLoading.value = true; // تفعيل اللودر
    }

    String? token = await TokenService.getToken();
    if (token == null) {
      print("⚠️ Token is null");
      isLoading.value = false;
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
      "lang": "$savedLocale",
    };

    String apiUrl = '$friend/$query?load=$_loadLimit';
    try {
      var response = await _api.getrequst3(apiUrl, query, headers: headers);
      if (_isDisposed) return;
      if (response != null) {
        setState(() {
          _friendList =
              response['data'] != null && response['data']['data'] is List
                  ? List<Map<String, dynamic>>.from(response['data']['data'])
                  : [];
        });
      }
    } catch (e) {
      print("❌ Error fetching friends data: $e");
    } finally {
      _isRequesting = false;
      if (!_isDisposed) {
        isLoading.value = false; // إيقاف اللودر بعد الانتهاء
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => isLoading.value
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ) // عرض لودر أثناء التحميل
        : _friendList.isEmpty
            ? Center(
                child:
                    Text("No friends found".tr)) // عرض رسالة عند عدم وجود نتائج
            : ListView.builder(
                controller: _scrollController,
                itemCount: _friendList.length,
                itemBuilder: (context, index) {
                  final user = _friendList[index];
                  return _friendCard(
                    name: user['name'] ?? 'Unknown',
                    image: "$linkservername/${user['photo']}",
                    userId: user['id'] != null ? user['id'].toString() : "0",
                  );
                },
              ));
  }

  Widget _friendCard({
    required String name,
    required String image,
    required String userId,
  }) {
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
                image,
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
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          trailing: IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () => Get.to(ChatPage(
              userId: userId,
              userName: name,
              userPhoto: image,
            )),
          ),
        ),
      ),
    );
  }
}
