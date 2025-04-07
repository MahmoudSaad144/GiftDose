import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/translation/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class Termspage extends StatefulWidget {
  const Termspage({super.key});

  @override
  State<Termspage> createState() => _TermspageState();
}

class _TermspageState extends State<Termspage> {
  var text = "".obs;
  ApiService _api = ApiService();
  Future<void> getData() async {
    String? token = await TokenService.getToken();
    if (token == null) {
      print("Token is null");

      return;
    }
    Locale savedLocale = await LanguageService.getSavedLanguage();
    Map<String, String> headers = {
      "Accept": "application/json",
      "lang": "$savedLocale",
      "Authorization": "Bearer $token"
    };

    try {
      var response =
          await _api.getrequst(linkappinfo, "data", headers: headers);
      print("Raw Response: $response");

      if (response != null && response is Map && response.containsKey("data")) {
        var data = response["data"];
        text.value = data["terms"] ?? "";
      } else {
        print("The response is not in JSON format or missing 'data' key");
      }
    } catch (e) {
      print("Error caught: $e");
    } finally {}
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms".tr,
            style: TextStyle(
                fontSize: 40, fontFamily: "Caveat", color: Colors.blue)),
        backgroundColor: Color(0xFFF9EFC7),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EFC7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100000),
              ),
            ),
            child: ListView(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      Obx(
                        () => text.value.isEmpty
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue,
                                ),
                              )
                            : SingleChildScrollView(
                                padding: EdgeInsets.all(16),
                                child: Html(
                                  data: text.value,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
