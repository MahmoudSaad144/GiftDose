import 'package:giftdose/Controller/gifts/purchased_gifts_section.dart';
import 'package:giftdose/Controller/gifts/user_gifts_section.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'add_gifts.dart';

class GiftsPage extends StatefulWidget {
  const GiftsPage({super.key});

  @override
  State<GiftsPage> createState() => _GiftsPageState();
}

class _GiftsPageState extends State<GiftsPage> {
  bool isUserGifts = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      final height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => Get.to(() => AddGiftPage(
              selectedFriendIds: [],
            )),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildHeader(width, height),
          Expanded(
            child: isUserGifts
                ? UserGiftsSection(
                    searchQuery: _searchController.text,
                  )
                : PurchasedGiftsSection(searchQuery: _searchController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double width, double height) {
    return Container(
      height: height * 0.16,
      width: width,
      decoration: const BoxDecoration(
        color: Color(0xFFF9EFC7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.00),
              child: Column(
                mainAxisSize: MainAxisSize.min, // يتجنب تمدد العمود الزائد
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                    child: _buildSearchBar(),
                  ),
                  SizedBox(height: height * 0.03),
                  _buildSectionButtons(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {}); // إعادة بناء الواجهة عند الكتابة
        },
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Colors.blue),
          hintText:
              isUserGifts ? 'Find the gift....'.tr : 'Find the gift....'.tr,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionButtons() {
    return Row(
      children: [
        _sectionButton('My gifts'.tr, isUserGifts, () {
          setState(() {
            isUserGifts = true;
          });
        }),
        _sectionButton('Gifts purchased'.tr, !isUserGifts, () {
          setState(() {
            isUserGifts = false;
          });
        }),
      ],
    );
  }

  Widget _sectionButton(String title, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: SizedBox(
        height: 50,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isActive ? Colors.blue.withOpacity(0.6) : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
