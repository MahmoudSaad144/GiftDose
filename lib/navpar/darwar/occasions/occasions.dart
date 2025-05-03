import 'dart:async';
import 'dart:convert';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/navpar/darwar/occasions/add_occasions.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';

import 'package:intl/intl.dart';

class Occasions extends StatefulWidget {
  const Occasions({Key? key}) : super(key: key);

  @override
  _OccasionsState createState() => _OccasionsState();
}

final ValueNotifier<List<Map<String, dynamic>>> _filteredOccasions =
    ValueNotifier([]);

class _OccasionsState extends State<Occasions> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _api = ApiService();

  final ValueNotifier<List<Map<String, dynamic>>> _occasions =
      ValueNotifier([]);
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  int _loadLimit = 10;
  bool _isLoading = false;
  final RxString search = "".obs;
  final GlobalKey<FormState> formstate = GlobalKey();
  Timer? _debounce;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _fetchOccasions(showLoading: true);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      setState(() => _loadLimit += 8);
      _fetchOccasions();
    }
  }

  Future<void> _fetchOccasions({bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading = true); // تشغيل اللودينج

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

      final response = await _api.getrequst2(
        linkOccausion,
        _loadLimit.toString(),
        search.value,
        headers: headers,
      );

      if (response != null && response["status"] == "success") {
        List<Map<String, dynamic>> occasionsList =
            response['data'] != null && response['data']['data'] is List
                ? List<Map<String, dynamic>>.from(response['data']['data'])
                : [];
        if (mounted) {
          _occasions.value = occasionsList;
          _filteredOccasions.value = occasionsList;
        }
      } else {
        debugPrint("Error: Unexpected response format");
      }
    } catch (e) {
      debugPrint("Error fetching occasions: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editOccasion(int occasionId, String name, String day) async {
    setState(() => _isLoading = true);

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
        "name": name,
        "day": day,
      };

      final response = await _api.postRequest(
        "https://giftdose.com/api/updateoccasion/$occasionId",
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
        Get.snackbar("", " ${responseData["message"].toString().tr}",
            backgroundColor: Colors.green, colorText: Colors.black);
        _fetchOccasions();
      } else {
        Get.snackbar("", " ${responseData["message"].toString().tr}",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("", "Server connection failed: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> deletoccasion(int occasionId, {bool showLoading = false}) async {
    if (showLoading) setState(() => _isLoading = true);

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
        "https://giftdose.com/api/Deleteoccasion/$occasionId",
        _loadLimit.toString(),
        headers: headers,
      );
      final responseData = jsonDecode(response.body);
      if (response != null && response["status"] == "success") {
        Get.snackbar("", " ${responseData["message"].toString().tr}",
            colorText: Colors.white, backgroundColor: Colors.green);
      } else {
        debugPrint("Error: Unexpected response format");
      }
    } catch (e) {
      debugPrint("Error fetching occasions: $e");
    } finally {
      if (showLoading) setState(() => _isLoading = false);
    }
  }

  void _filterOccasions(String query) {
    search.value = query; // تحديث قيمة البحث

    // إلغاء المؤقت السابق (لو موجود)
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // بدء مؤقت جديد لتأخير البحث
    _debounce = Timer(const Duration(seconds: 1), () {
      _fetchOccasions(showLoading: true);
    });
  }

  void _MYdeleteOccasion(int index) {
    final int occasionId = _occasions.value[index]['id'];
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
                setState(() => _isLoading = true); // ✅ تشغيل اللودنج
                await deletoccasion(occasionId, showLoading: true);
                _occasions.value.removeAt(index); // ✅ تحديث القائمة بعد الحذف
                setState(() => _isLoading = false); // ✅ إيقاف اللودنج
                Navigator.pop(context);
              },
              namebottomdilog2: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.blue,
                    ) // ✅ اللودنج أثناء الحذف
                  : Text(
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

  void _editOccasionDialog(int index) {
    final occasion = _occasions.value[index];
    final TextEditingController editNameController =
        TextEditingController(text: occasion['name']);
    final TextEditingController editDateController =
        TextEditingController(text: occasion['day']);

    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false; // حالة اللودنج داخل الديالوج

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              backgroundColor: const Color.fromARGB(255, 255, 251, 235),
              title: Center(
                child: Text('Edit Event'.tr,
                    style: const TextStyle(fontSize: 30, color: Colors.blue)),
              ),
              content: Form(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: editNameController,
                      decoration: InputDecoration(
                        hintText: 'Edit Event Name'.tr,
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: editDateController,
                      decoration: InputDecoration(
                        hintText: 'Edit Date'.tr,
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                      ),
                      readOnly: true,
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          editDateController.text =
                              DateFormat('yyyy-MM-dd').format(pickedDate);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() => isLoading = true); // تشغيل اللودنج
                            await _editOccasion(
                                occasion['id'],
                                editNameController.text,
                                editDateController.text);
                            setState(() => isLoading = false); // إيقاف اللودنج
                            Navigator.pop(context);
                          },
                    child: Container(
                      width: 90,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        gradient: const LinearGradient(
                          begin: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 43, 119, 182),
                            Color.fromARGB(255, 86, 155, 211),
                            Color.fromARGB(255, 121, 195, 255),
                          ],
                        ),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white) // ✅ مؤشر تحميل
                            : Text('Save'.tr,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final bool? isAdded = await Get.to(() => const AddOccasions());
          if (isAdded == true) {
            if (isAdded == true) _fetchOccasions();
            _fetchOccasions();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;

              return ListView(
                children: [
                  Container(
                    height: height,
                    width: width,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9EFC7),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(100000)),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: height * 0.02,
                                horizontal: width * 0.05),
                            child: TextField(
                              onChanged: _filterOccasions,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.blue),
                                hintText: "Search for an occasion".tr,
                                border: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.02),
                          Expanded(
                            child: ValueListenableBuilder<
                                List<Map<String, dynamic>>>(
                              valueListenable: _filteredOccasions,
                              builder: (context, occasions, _) {
                                if (_isLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ), // اللودينج
                                  );
                                }

                                if (occasions.isEmpty) {
                                  return Center(
                                    child: Text("No occasions available".tr),
                                  );
                                }

                                return ListView.builder(
                                  controller: _scrollController,
                                  itemCount: occasions.length,
                                  itemBuilder: (context, index) {
                                    final occasion = occasions[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: Card(
                                        elevation: 5,
                                        color:
                                            Color.fromARGB(255, 255, 252, 238),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: ListTile(
                                          title: Row(
                                            children: [
                                              const Icon(
                                                  Icons.add_reaction_outlined,
                                                  color: Colors.blue,
                                                  size: 30),
                                              SizedBox(width: 10),
                                              Text(occasion['name'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 18)),
                                            ],
                                          ),
                                          subtitle: Text(occasion['day'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 16)),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: Colors.blue),
                                                onPressed: () =>
                                                    _editOccasionDialog(index),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () =>
                                                    _MYdeleteOccasion(index),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener); // ✅ إزالة الليسنر
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

class CustomDialog extends StatelessWidget {
  final String titledilog;
  final double? fontsize;
  final Color? Colortitle;
  final String? contentdilog;
  final String? namebottomdilog1;
  final Widget? namebottomdilog2;
  final Color? dilogiconcolor;
  final IconData? dilogicon;
  final VoidCallback? onPressed1;
  final VoidCallback? onPressed2;
  final Widget? content;

  const CustomDialog({
    required this.titledilog,
    this.fontsize,
    this.Colortitle,
    this.contentdilog,
    this.namebottomdilog1,
    this.namebottomdilog2,
    this.dilogiconcolor,
    this.dilogicon,
    this.onPressed1,
    this.onPressed2,
    this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        titledilog,
        style: TextStyle(
          fontSize: fontsize ?? 18, // قيمة افتراضية
          color: Colortitle ?? Colors.black, // قيمة افتراضية
        ),
      ),
      content: content ??
          (contentdilog != null
              ? Text(
                  contentdilog!,
                  style: const TextStyle(fontSize: 16),
                )
              : null),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (namebottomdilog1 != null && onPressed1 != null)
              TextButton(
                onPressed: onPressed1,
                child: Container(
                    width: 100,
                    height: 40,
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
                      namebottomdilog1!,
                      style: TextStyle(color: Colors.white),
                    ))),
              ),
            if (namebottomdilog2 != null && onPressed2 != null)
              TextButton(
                onPressed: onPressed2,
                child: Container(
                    width: 100,
                    height: 40,
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
                      child: namebottomdilog2,
                    )),
              ),
          ],
        )
      ],
      icon: dilogicon != null
          ? Icon(
              dilogicon,
              color: dilogiconcolor ?? Colors.black,
              size: 100,
            )
          : null,
    );
  }
}
