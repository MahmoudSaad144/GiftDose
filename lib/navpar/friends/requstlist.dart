import 'dart:convert';

import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsListSection extends StatefulWidget {
  @override
  State<RequestsListSection> createState() => _RequestsListSectionState();
}

class _RequestsListSectionState extends State<RequestsListSection> {
  var isLoading = false.obs; // استخدام .obs لمراقبة حالة التحميل
  int _loadLimit = 20;
  List<Map<String, dynamic>> _requestList = [];
  ApiService _api = ApiService();
  bool _isDisposed = false;
  final ScrollController sc = ScrollController();
  @override
  void initState() {
    super.initState();
    _fetchRequests("");

    sc.addListener(() {
      if (sc.offset >= sc.position.maxScrollExtent) {
        if (mounted) {
          setState(() {
            _loadLimit++;
          });
          _fetchRequests("");
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _fetchRequests(String query) async {
    if (_isDisposed) return;
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
      "Authorization": "Bearer $token",
      "lang": "$savedLocale"
    };

    String apiUrl = '$requstfreind/$query?load=$_loadLimit';
    try {
      var response = await _api.getrequst3(apiUrl, query, headers: headers);
      if (_isDisposed) return;
      setState(() {
        _requestList =
            response['data'] != null && response['data']['data'] is List
                ? List<Map<String, dynamic>>.from(response['data']['data'])
                : [];
      });

      // تحديث الصفحة بعد الحذف
    } catch (e) {
      print("Error fetching search data: $e");
    } finally {
      if (!_isDisposed) {
        isLoading.value = false; // إيقاف اللودر بعد الانتهاء
      }
    }
  }

  Future<void> _cancelFriendRequest(int userId) async {
    try {
      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        return;
      }

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "ar",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "sender": userId.toString(),
      };

      final response = await _api.postRequest(
        cancelfreind,
        body,
        headers,
      );

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // حذف المستخدم من القائمة بعد نجاح الطلب
        setState(() {
          _requestList.removeWhere((user) => user['id'] == userId.toString());
        });

        _fetchRequests("");
      } else {
        Get.snackbar("Error", " ${responseData["message"].toString().tr}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _acceptaddfriendt(int userId) async {
    try {
      final String? token = await TokenService.getToken();
      if (token == null) {
        Get.snackbar("Error", "Token not found!");
        return;
      }

      final Map<String, String> headers = {
        "Accept": "application/json",
        "lang": "ar",
        "Authorization": "Bearer $token"
      };

      final Map<String, dynamic> body = {
        "sender": userId.toString(),
      };

      final response = await _api.postRequest(
        acceptfriend,
        body,
        headers,
      );

      if (response == null) {
        Get.snackbar("Error", "No response from server",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // حذف المستخدم من القائمة بعد نجاح الطلب
        setState(() {
          _requestList.removeWhere((user) => user['id'] == userId.toString());
        });

        _fetchRequests("");
      } else {
        Get.snackbar("Error", " ${responseData["message"].toString().tr}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => isLoading.value
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          ) // عرض لودر أثناء التحميل
        : _requestList.isEmpty
            ? Center(
                child: Text(
                    'No results found.'.tr)) // عرض رسالة عند عدم وجود نتائج
            : ListView.builder(
                itemCount: _requestList.length,
                itemBuilder: (context, index) {
                  final user = _requestList[index];
                  return _requestCard(
                    name: user['sender']['name'] ?? 'Unknown',
                    image: "$linkservername/${user['sender']['photo']}",
                    userId: user['sender']['id'] != null
                        ? user['sender']['id'].toString()
                        : "0",
                  );
                },
              ));
  }

  Widget _requestCard({
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
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              image,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('images/avatar.png', width: 50, height: 50);
              },
            ),
          ),
          title:
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () {
                  _acceptaddfriendt(
                      int.parse(userId)); // تحويل من String إلى int
                },
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () {
                  _cancelFriendRequest(
                      int.parse(userId)); // تحويل من String إلى int
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
