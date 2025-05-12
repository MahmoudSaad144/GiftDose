import 'package:giftdose/navpar/friends/connect_with_contacts.dart';
import 'package:giftdose/navpar/friends/listfrind.dart';
import 'package:giftdose/navpar/friends/requstlist.dart';
import 'package:giftdose/navpar/friends/searchuser.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserAndFriendsPage extends StatefulWidget {
  const UserAndFriendsPage({super.key});

  @override
  State<UserAndFriendsPage> createState() => _UserAndFriendsPageState();
}

class _UserAndFriendsPageState extends State<UserAndFriendsPage> {
//رقوسيت post   add && cancel

  var isLoading = false.obs;
  var username = "".obs;
  var photo = "".obs;
  var name = "".obs;
  bool isFriendsList = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              color: Color(0xFFF9EFC7),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100000),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  SearchFriendsWidget(),
                  SizedBox(
                    height: 3,
                  ),
                  _buildConnectButton(),
                  SizedBox(
                    height: 3,
                  ),
                  _buildSectionButtons(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: isFriendsList
                        ? FriendsListSection()
                        : RequestsListSection(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: 400,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color.fromARGB(159, 219, 222, 223)),
            child: MaterialButton(
              onPressed: () => Get.to(() => ConnectWithContacts()),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Connect with Contacts'.tr,
                      style: TextStyle(fontSize: 18)),
                  Icon(
                    Icons.arrow_circle_right,
                    size: 30,
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionButtons() {
    return Row(
      children: [
        _sectionButton('Friends'.tr, isFriendsList, () {
          setState(() {
            isFriendsList = true;
          });
        }),
        _sectionButton('Requests'.tr, !isFriendsList, () {
          setState(() {
            isFriendsList = false;
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
