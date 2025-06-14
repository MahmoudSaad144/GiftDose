import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:giftdose/Controller/token.dart';
import 'package:giftdose/api/curd.dart';
import 'package:giftdose/api/linkserver.dart';
import 'package:giftdose/navpar/darwar/profile/profile.dart';
import 'package:giftdose/translation/language_service.dart';

class ChatPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhoto;

  const ChatPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userPhoto,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController messageController = TextEditingController();

  List<Map<String, dynamic>> messages = [];
  int _loadLimit = 20;
  bool _isLoading = false;
  bool _isFirstLoad = true;
  ApiService _api = ApiService();
  final ScrollController _scrollController = ScrollController();

  void _initializeData() {
    _conversations();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    // Check if we're near the top to load more messages (pagination)
    if (_scrollController.position.pixels <=
            _scrollController.position.minScrollExtent + 10 &&
        !_isLoading) {
      setState(() {
        _isLoading = true;
        _loadLimit += 10;
      });

      // Save current content height
      double currentContentHeight = _scrollController.position.maxScrollExtent;

      _conversations(loadMore: true, currentHeight: currentContentHeight);
    }
  }

  Future<void> _conversations({
    bool loadMore = false,
    double currentHeight = 0.0,
  }) async {
    if (_isLoading && !loadMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await TokenService.getToken();
      if (token == null) {
        return;
      }

      final response = await _api.postRequest(
        conversations,
        jsonEncode({"receiver": widget.userId}),
        {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        load: _loadLimit.toString(),
      );

      if (response != null) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode == 200 && responseData["status"] == "success") {
          final List<Map<String, dynamic>> newMessages =
              List<Map<String, dynamic>>.from(responseData['data'] ?? [])
                  .map((message) => {
                        ...message,
                        "time": DateTime.parse(message["time"]),
                      })
                  .toList();

          // Sort messages by date
          newMessages.sort((a, b) => a["time"].compareTo(b["time"]));

          setState(() {
            messages = newMessages;
            _isLoading = false;
          });

          // Handle scrolling based on context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              if (_isFirstLoad) {
                // First load - scroll to bottom
                _scrollToBottom();
                _isFirstLoad = false;
              } else if (loadMore) {
                // Pagination - maintain relative position
                final newHeight = _scrollController.position.maxScrollExtent;
                final diff = newHeight - currentHeight;
                _scrollController
                    .jumpTo(_scrollController.position.pixels + diff);
              }
            }
          });
        }
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final String messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    // Clear input field immediately
    messageController.clear();

    try {
      final String? token = await TokenService.getToken();
      if (token == null) {
        return;
      }

      // Optimistically add message to UI
      final newMessage = {
        "sender": "me",
        "message": messageText,
        "time": DateTime.now(),
      };

      setState(() {
        messages.add(newMessage);
      });

      // Scroll to the new message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Send to server
      Locale savedLocale = await LanguageService.getSavedLanguage();
      final response = await _api.postRequest(sendmessage, {
        "receiver": widget.userId,
        "message": messageText
      }, {
        "Accept": "application/json",
        "lang": "$savedLocale",
        "Authorization": "Bearer $token"
      });

      if (response != null) {
        final responseData = jsonDecode(response.body);
        if (response.statusCode != 200 || responseData["status"] != "success") {
          // Handle error if needed
        }
      }
    } catch (e) {}
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.find<ProfileController>().getData();
        Get.back(result: true);
        return false; // منع الرجوع التلقائي
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Get.find<ProfileController>().getData();
              Get.back(result: true);
            },
          ),
          backgroundColor: const Color(0xFFF9EFC7),
          title: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(widget.userPhoto)),
              const SizedBox(width: 10),
              Text(widget.userName,
                  style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFC3EDBF), Color(0xFF2B77B6)],
            ),
          ),
          child: Column(
            children: [
              // Loading indicator at the top for pagination
              if (_isLoading && messages.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  reverse: false, // Keep standard order
                  padding: const EdgeInsets.all(16.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    // Fix the isMe logic - if the sender is not me, then it's them
                    bool isMe = message['sender'].toString() !=
                        widget.userId.toString();

                    // Group messages by sender and time
                    bool showAvatar = true;
                    if (index > 0) {
                      final prevMessage = messages[index - 1];
                      if (prevMessage['sender'] == message['sender']) {
                        // Same sender, check time difference
                        final prevTime = prevMessage['time'] as DateTime;
                        final currentTime = message['time'] as DateTime;
                        if (currentTime.difference(prevTime).inMinutes < 5) {
                          showAvatar = false;
                        }
                      }
                    }

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMe && showAvatar)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundImage:
                                      NetworkImage(widget.userPhoto),
                                ),
                              ),
                            SizedBox(
                              width: 10,
                            ),
                            if (!isMe && !showAvatar)
                              const SizedBox(width: 38), // Space for alignment

                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    message['message'] ?? "",
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    message['time']?.toString() ?? "",
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: 'Write a message...'.tr,
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF2B77B6),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
