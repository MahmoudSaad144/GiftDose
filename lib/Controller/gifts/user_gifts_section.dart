import 'dart:convert';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/fanction/gift_card.dart';
import 'package:giftdose/navpar/gifts/eidet_gifts.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../navpar/darwar/occasions/occasions.dart';

class UserGiftsSection extends StatefulWidget {
  final String searchQuery;
  const UserGiftsSection({super.key, required this.searchQuery});

  @override
  State<UserGiftsSection> createState() => _UserGiftsSectionState();
}

class _UserGiftsSectionState extends State<UserGiftsSection> {
  final ScrollController _scrollController = ScrollController();
  final RxList<Map<String, dynamic>> _gifts = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _user = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;
  bool _isDisposed = false;
  int _loadLimit = 20;
  String? purchasedStatus;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant UserGiftsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _gifts.clear();
      _fetchGifts(showLoading: true);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    _fetchGifts(showLoading: true);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading.value) {
      _loadLimit += 8;
      _fetchGifts();
    }
  }

  Future<void> _updateGiftStatus(int giftId, bool isActive) async {
    String myIsActive = isActive ? "1" : "0";

    try {
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

      final Map<String, dynamic> body = {
        "id": giftId.toString(),
        "status": myIsActive,
      };

      final response = await _api.postRequest(
          "https://giftdose.com/api/updategifts/$giftId", body, headers);

      if (response != null) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData["status"] == "success") {
        } else {
          Get.snackbar("", " ${responseData["message"].toString().tr}",
              colorText: Colors.white, backgroundColor: Colors.red);
        }
      } else {
        Get.snackbar("Error", "Invalid response from server.",
            colorText: Colors.white, backgroundColor: Colors.red);
        debugPrint("Unexpected response format: $response");
      }
    } catch (e) {
      debugPrint("Error updating gift status: $e");
    }
  }

  Future<void> _fetchGifts({bool showLoading = false}) async {
    if (_isDisposed) return;
    if (showLoading) _isLoading.value = true;

    try {
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

      final response = await _api.getrequst2(
        linkgifts,
        _loadLimit.toString(),
        widget.searchQuery,
        headers: headers,
      );

      if (response != null && response["status"] == "success") {
        List<Map<String, dynamic>> data = [];
        if (response['data'] != null && response['data']['data'] is List) {
          data = List<Map<String, dynamic>>.from(response['data']['data']);
        }
        _gifts.value = data;
      } else {
        Get.snackbar(
            "Error", response?["message"]?.toString().tr ?? "Unknown error",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching gifts: $e");
    } finally {
      if (!_isDisposed) _isLoading.value = false;
    }
  }

  Future<void> _deletegits(int idgift, {bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading.value = true);

    try {
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

      final response = await _api.getrequst(
        "https://giftdose.com/api/Deletegifts/$idgift",
        _loadLimit.toString(),
        headers: headers,
      );

      if (response != null && response["status"] == "success") {
        // تم الحذف بنجاح
        Get.snackbar("", " ${response["message"].toString().tr} ",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        debugPrint("Error: Unexpected response format");
      }
    } catch (e) {
      debugPrint("Error deleting gift: $e");
    } finally {
      if (showLoading) setState(() => _isLoading.value = false);
    }
  }

  void _MYdeleteOccasion(int index) {
    final int idgift = _gifts[index]['id'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              content: Text("Are you sure to delete?".tr,
                  style: const TextStyle(fontSize: 20)),
              Colortitle: Colors.red,
              dilogicon: Icons.question_mark_sharp,
              contentdilog: "Are you sure to delete?".tr,
              dilogiconcolor: Colors.red,
              fontsize: 20,
              namebottomdilog1: "Cancel".tr,
              onPressed1: () => Navigator.pop(context),
              onPressed2: () async {
                // حذف العنصر من الواجهة أولًا
                _gifts.removeAt(index);
                setState(() {}); // تحديث الواجهة فورًا
                Navigator.pop(context);

                // تنفيذ الحذف من الـ API بعد التحديث مباشرة
                await _deletegits(idgift);
              },
              namebottomdilog2: Text(
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : _gifts.isEmpty
              ? Center(
                  child: Text("No Gifts".tr,
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _gifts.length,
                  itemBuilder: (context, index) {
                    final gift = _gifts[index];
                    return GiftCard(
                      purchasedStatus: gift['purchased_status'],
                      image: gift["photo"] != null
                          ? "$linkservername/${gift["photo"]}"
                          : "",
                      color: gift["color"] ?? "N/A",
                      location: gift["address"] ?? "Unknown",
                      size: gift["size"] ?? "N/A",
                      productName: gift["name"] ?? "Unknown",
                      productDescription: (gift["note"] ?? "").toString(),
                      price: gift["price"] ?? "0",
                      currency: gift["currency"] ?? "",
                      isUserProduct: true,
                      isActive: (gift["status"] == 1),
                      onStatusChanged: (bool newValue) async {
                        _gifts[index]["status"] = newValue;
                        await _updateGiftStatus(gift["id"], newValue);
                      },
                      onPressed2: () async {
                        await Get.to(
                          () => EidetGifts(selectedFriendIds2: []),
                          arguments: {
                            "id": gift["id"],
                            "name": gift["name"] ?? "Unknown",
                            "size": gift["size"] ?? "N/A",
                            "color": gift["color"] ?? "N/A",
                            "price": gift["price"] ?? "0",
                            "note": gift["note"] ?? "",
                            "image": gift["photo"] != null
                                ? "$linkservername/${gift["photo"]}"
                                : "",
                            "address": gift["address"] ?? "Unknown",
                            "hidden_users": gift["hidden_users"] ?? [],
                          },
                        );
                      },
                      onPressed: () => _MYdeleteOccasion(index),
                    );
                  },
                ),
    );
  }
}
