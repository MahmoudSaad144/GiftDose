import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/fanction/cardnofiticaton.dart';
import 'package:giftdose/translation/language_service.dart';

class Naficationpage extends StatefulWidget {
  const Naficationpage({super.key});

  @override
  State<Naficationpage> createState() => NaficationpageState();
}

class NaficationpageState extends State<Naficationpage> {
  final ScrollController _scrollController = ScrollController();
  bool _isRequesting = false;
  int load = 10;
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _notifications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(showLoading: true);

    _scrollController.addListener(() {
      if (_scrollController.offset >=
          _scrollController.position.maxScrollExtent) {
        if (_isRequesting) return;
        if (mounted) {
          setState(() {
            load += load;
          });
          _fetchNotifications(scroll: true);
        }
      }
    });
  }

  Future<void> _fetchNotifications(
      {bool showLoading = false, bool scroll = false}) async {
    if (showLoading && mounted) {
      setState(() {
        isLoading = true;
      });
    }
    _isRequesting = true;
    final String? token = await TokenService.getToken();
    if (token == null) {
      if (mounted) {
        Get.snackbar("Error", "Token not found!");
      }
      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    final Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    };
    try {
      String apiUrl = '$usernotifications/?load=$load';

      var response = await _api.getrequst3(apiUrl, "", headers: headers);

      if (response != null && response["data"] != null) {
        if (mounted) {
          setState(() {
            _notifications =
                response['data'] != null && response['data']['data'] is List
                    ? List<Map<String, dynamic>>.from(response['data']['data'])
                    : [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching gifts: $e");
    } finally {
      _isRequesting = false;
      if (showLoading && mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(() {});
    _scrollController.dispose();
    super.dispose();
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(100000),
            ),
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        "No notifications".tr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _notifications.length,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      itemBuilder: (context, index) {
                        var noti = _notifications[index];
                        return CARDnofiticaton(
                          title: " ${noti['title']}",
                          notification: " ${noti['message']}  ",
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
