import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/controller/home_controller/chat_sent_controller.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../../constants/constant_string.dart';

class ChatSentScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isChat;

  const ChatSentScreen({
    super.key,
    required this.userData,
    required this.isChat,
  });

  @override
  State<ChatSentScreen> createState() => _ChatSentScreenState();
}

class _ChatSentScreenState extends State<ChatSentScreen> {
  late ChatSentController chatSentController;
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Initialize controller
    chatSentController = Get.put(ChatSentController());
    
    // Set user ID immediately
    _setUserId();
  }
  
  Future<void> _setUserId() async {
    try {
      final userDataString = await SharPreferences.getString(SharPreferences.userData);
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        chatSentController.userId.value = userData['id'].toString();
      }
    } catch (e) {
      debugPrint('Error getting user ID: $e');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: ConstantColor.primaryGradient,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Center(
            child: Icon(
              Icons.arrow_back_outlined,
              color: ConstantColor.whiteColor,
            ),
          ),
        ),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(1000),
              child: AppImageAsset(
                image: "${ConstantString.userImgUrlPath}${widget.userData['photo']}",
                isFile: false,
                fit: BoxFit.cover,
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: Text(
                widget.userData['name'] ?? "User",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ConstantColor.whiteColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () {
          // Get messages instantly from cache
          final messages = chatSentController.getDisplayMessages();
          
          // Show loading ONLY if no messages and still loading first time
          if (chatSentController.isLoading.value && messages.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        controller: chatSentController.scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, 
                          vertical: 10,
                        ),
                        itemBuilder: (context, index) {
                          final chatItem = messages[messages.length - 1 - index];
                          final isMe = chatItem['user_id']?.toString() == 
                                      chatSentController.userId.value;
                          final isOptimistic = chatItem['is_optimistic'] == true;
                          
                          return _buildChatBubble(
                            context, 
                            isMe, 
                            chatItem,
                            isOptimistic: isOptimistic,
                          );
                        },
                      ),
              ),
              if (widget.isChat) _buildMessageInput(width),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: ConstantColor.grayColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: TextStyle(
              fontSize: 16,
              color: ConstantColor.grayColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation',
            style: TextStyle(
              fontSize: 14,
              color: ConstantColor.grayColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(double width) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 10),
        decoration: BoxDecoration(
          color: ConstantColor.bgColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100.0),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff000000).withAlpha(48),
                      blurRadius: 0,
                      offset: const Offset(0, 2),
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: chatSentController.textController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    chatSentController.updateMessage(value);
                  },
                  onFieldSubmitted: (_) => _sendMessage(),
                  textInputAction: TextInputAction.send,
                  enabled: !chatSentController.isSending.value,
                  style: TextStyle(
                    fontSize: 16,
                    color: ConstantColor.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 15,
                    ),
                    hintText: "Type your message...",
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: ConstantColor.grayColor,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: width * 0.02),
            GestureDetector(
              onTap: chatSentController.isSending.value ? null : _sendMessage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: chatSentController.isSending.value 
                      ? Colors.grey 
                      : ConstantColor.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: chatSentController.isSending.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: ConstantColor.whiteColor,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, bool isMe, dynamic data, {bool isOptimistic = false}) {
    final message = data['text'] ?? "";
    final createdAt = data['created_at'];
    
    String timeString = "";
    if (createdAt != null && createdAt.toString().isNotEmpty && !isOptimistic) {
      try {
        String dateStr = createdAt.toString();
        DateTime dateTime;
        if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
          String formattedStr = dateStr.replaceAll(' ', 'T');
          if (!formattedStr.endsWith('Z')) {
            formattedStr = '${formattedStr}Z';
          }
          dateTime = DateTime.parse(formattedStr).toLocal();
        } else {
          dateTime = DateTime.parse(dateStr).toLocal();
        }
        timeString = DateFormat('hh:mm a').format(dateTime);
      } catch (e) {
        try {
          final dateTime = DateTime.parse(createdAt.toString()).toLocal();
          timeString = DateFormat('hh:mm a').format(dateTime);
        } catch (_) {
          timeString = DateFormat('hh:mm a').format(DateTime.now());
        }
      }
    } else if (!isOptimistic) {
      timeString = DateFormat('hh:mm a').format(DateTime.now());
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0, 
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: isMe 
                    ? (isOptimistic 
                        ? const Color(0xffD5EDFB).withOpacity(0.6) 
                        : const Color(0xffD5EDFB))
                    : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: isMe ? const Radius.circular(16.0) : const Radius.circular(4.0),
                  bottomRight: isMe ? const Radius.circular(4.0) : const Radius.circular(16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff000000).withAlpha(15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isOptimistic && isMe) ...[
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: ConstantColor.primary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: ConstantColor.blackColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            if (!isOptimistic)
              Text(
                timeString,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  color: ConstantColor.grayColor.withOpacity(0.8),
                ),
              ),
            if (isOptimistic)
              Text(
                "Sending...",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                  color: ConstantColor.grayColor.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _sendMessage() async {
    await chatSentController.postSendChatApi();
    // Keep focus for continuous typing
    _focusNode.requestFocus();
  }
}