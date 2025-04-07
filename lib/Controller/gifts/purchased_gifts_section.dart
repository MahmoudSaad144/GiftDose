import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';

import 'package:giftdose/translation/language_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../navpar/darwar/occasions/occasions.dart';

class PurchasedGiftsSection extends StatefulWidget {
  final String searchQuery;
  const PurchasedGiftsSection({Key? key, required this.searchQuery});

  @override
  State<PurchasedGiftsSection> createState() => _PurchasedGiftsSectionState();
}

class _PurchasedGiftsSectionState extends State<PurchasedGiftsSection> {
  final ScrollController _scrollController = ScrollController();
  final RxList<Map<String, dynamic>> _gifts = <Map<String, dynamic>>[].obs;

  RxBool _isLoading = false.obs;
  int _loadLimit = 20;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didUpdateWidget(covariant PurchasedGiftsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _fetchGifts(showLoading: true);
    }
  }

  void _initializeData() {
    _fetchGifts(showLoading: true);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading.value) {
      if (mounted) {
        setState(() => _loadLimit += 10);
      }
      _fetchGifts();
    }
  }

  Future<void> _fetchGifts({bool showLoading = false}) async {
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

      final response = await _api.getrequst2(
        linkgiftspurchased,
        _loadLimit.toString(),
        widget.searchQuery,
        headers: headers,
      );

      if (response != null) {
        final Map<String, dynamic> responseData = response;

        if (responseData.containsKey("status") &&
            responseData["status"] == "success") {
          List<Map<String, dynamic>> data =
              response['data'] != null && response['data']['data'] is List
                  ? List<Map<String, dynamic>>.from(response['data']['data'])
                  : [];
          _gifts.value = data;
        } else {
          Get.snackbar("Error", " ${responseData["message"].toString().tr}",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else if (response.statusCode == 422) {
        // حذف التوكن
        await TokenService.removeToken();

        // طرد المستخدم لصفحة تسجيل الدخول
        Get.offAllNamed("/1");

        Get.snackbar("Error", "تم طردك بسبب انتهاء الجلسة أو الحظر.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching gifts: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading.value = false);
      }
    }
  }

  Future<void> _recovery(int idgift, {bool showLoading = false}) async {
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
        "https://newbrainse.dev-swift.com/api/cancelgift/$idgift ",
        _loadLimit.toString(),
        headers: headers,
      );

      if (response != null && response["status"] == "success") {
      } else {
        debugPrint("Error: Unexpected response format");
      }
    } catch (e) {
      debugPrint("Error fetching occasions: $e");
    } finally {
      if (showLoading) setState(() => _isLoading.value = false);
    }
  }

  void _MYdeleteOccasion(int index) {
    final idgift = _gifts[index]["gift"]['id'];
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
                setState(() => _isLoading.value = true); // ✅ تشغيل اللودنج
                _recovery(idgift, showLoading: true);
                _gifts.removeAt(index);
                setState(() => _isLoading.value = false); // ✅ إيقاف اللودنج
                Navigator.pop(context);
              },
              namebottomdilog2: _isLoading.value
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    ) // ✅ اللودنج أثناء الحذف
                  : Text(
                      "sure".tr,
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
    final filteredGifts = _gifts
        .where((gift) => gift["gift"]["name"]
            .toString()
            .toLowerCase()
            .contains(widget.searchQuery.toLowerCase()))
        .toList();

    return Obx(
      () => _isLoading.value
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : filteredGifts.isEmpty
              ? Center(
                  child: Text("No Gifts".tr,
                      style: TextStyle(fontSize: 18, color: Colors.grey)))
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: filteredGifts.length,
                  itemBuilder: (context, index) {
                    final gift = filteredGifts[index];
                    return GiftCard(
                      image: "$linkservername/${gift["gift"]["photo"]}",
                      color: gift["gift"]["color"] ?? " ",
                      user: gift["gift"]["user"]['username'] ?? " ",
                      location: gift["gift"]["address"] ?? "",
                      size: gift["gift"]["size"] ?? "",
                      productName: gift["gift"]["name"] ?? "",
                      productDescription: gift["gift"]["note"] ?? "",
                      price: gift["gift"]["price"],
                      currency: gift["gift"]["currency"],
                      onPressed: () => _MYdeleteOccasion(index),
                    );
                  },
                ),
    );
  }
}

class GiftCard extends StatefulWidget {
  final String image;
  final String color;

  final String location;
  final String size;
  final String? user;
  final String productName;
  final String? purchasedStatus;
  final String productDescription;
  final String price;
  final String currency;
  final bool isUserProduct;
  final bool isActive; // ✅ تمرير حالة النشاط
  final Function(bool)? onStatusChanged; // ✅ إضافة كولباك لتغيير الحالة
  final void Function()? onPressed;
  final void Function()? onPressed2;

  const GiftCard({
    required this.image,
    required this.color,
    required this.location,
    required this.size,
    required this.productName,
    required this.productDescription,
    required this.price,
    this.isUserProduct = false,
    this.isActive = false, // ✅ قيمة افتراضية
    this.onStatusChanged,
    this.onPressed,
    this.onPressed2,
    required this.currency,
    this.purchasedStatus,
    this.user,
  });

  @override
  State<GiftCard> createState() => _GiftCardState();
}

class _GiftCardState extends State<GiftCard> {
  late bool isActive;
  @override
  void initState() {
    super.initState();
    isActive = widget.isActive; // ✅ تحميل الحالة الأولية من widget
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.image,
                    width: screenWidth * 0.9,
                    height: screenHeight * 0.2,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'images/GTIF.jpg',
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.1,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                if (widget.purchasedStatus !=
                    null) // ✅ إظهار الشريط فقط إذا لم يكن null
                  Positioned(
                    top: 10, // يتحكم في موضع الشريط من الأعلى
                    left: 0,
                    right: 0,
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.7), // لون أخضر شفاف
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.purchasedStatus!, // ✅ عرض النص القادم من API
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${'name'.tr}:${widget.productName}".tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "${'username'.tr}: ${widget.user}".tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Text(
                        '${'color'.tr}: ${widget.color}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'Size'.tr}:  ${widget.size}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${'location'.tr}: ${widget.location}',
                        style: const TextStyle(fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${'price'.tr}: ${widget.price}(${widget.currency})".tr,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (widget.isUserProduct)
                  Flexible(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ زر تبديل الحالة فقط إذا كان المنتج يخص المستخدم
                        if (widget.isUserProduct)
                          Row(
                            children: [
                              Text(
                                isActive
                                    ? "Hide".tr
                                    : "Show".tr, // ✅ تغيير النص حسب الحالة
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Switch(
                                value: isActive,
                                onChanged: (value) {
                                  setState(() {
                                    isActive = value;
                                  });
                                  widget.onStatusChanged?.call(value);
                                },
                                activeColor: Colors.blue,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              widget.productDescription,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (widget.isUserProduct)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed2,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              const Color.fromARGB(255, 43, 119, 182)
                                  .withOpacity(1),
                              const Color.fromARGB(255, 86, 155, 211)
                                  .withOpacity(1),
                              const Color.fromARGB(255, 121, 195, 255)
                                  .withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Edit'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 182, 43, 43).withOpacity(1),
                              Color.fromARGB(255, 211, 86, 86).withOpacity(1),
                              Color.fromARGB(255, 255, 121, 121).withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Delete'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (widget.isUserProduct == false)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    flex: 1,
                    child: TextButton(
                      onPressed: widget.onPressed,
                      child: Container(
                        height: 40,
                        width: screenWidth * 0.9,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 182, 43, 43).withOpacity(1),
                              Color.fromARGB(255, 211, 86, 86).withOpacity(1),
                              Color.fromARGB(255, 255, 121, 121).withOpacity(1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
