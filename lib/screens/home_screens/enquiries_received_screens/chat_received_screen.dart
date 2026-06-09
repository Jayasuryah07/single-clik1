import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/chat_received_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../../constants/constant_string.dart';
import '../../../controller/home_controller/enquiries_received_controller.dart';

class ChatReceivedScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isChat;

  const ChatReceivedScreen({
    super.key,
    required this.userData,
    required this.isChat,
  });

  @override
  State<ChatReceivedScreen> createState() => ChatReceivedScreenState();
}

class ChatReceivedScreenState extends State<ChatReceivedScreen> {
  HomeController homeController = Get.put(HomeController());
  EnquiriesReceivedController enquiriesReceivedController =
      Get.put(EnquiriesReceivedController());

  ChatReceivedController chatReceivedController = Get.put(ChatReceivedController());
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Future<void> getData() async {
    final userDataString = await SharPreferences.getString(SharPreferences.userData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      chatReceivedController.userId.value = userData['id'].toString();
      debugPrint('userId : ${chatReceivedController.userId.value}');
    } else {
      debugPrint('No user data found in SharedPreferences');
    }
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
          title: Text(
            "Enquiries Received",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: ConstantColor.whiteColor,
            ),
          ),
        ),
        body: Obx(
          () {
            final messages = chatReceivedController.getDisplayMessages();
            if (chatReceivedController.isLoading.value && messages.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(Get.width/30,Get.width/120,Get.width/50,Get.width/30),
                  margin: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                      color: ConstantColor.whiteColor,
                      borderRadius:
                      BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: Get.width/50,),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: ConstantColor
                                        .primary,
                                    width: 1.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: AppImageAsset(
                                    image:
                                    "${ConstantString.userImgUrlPath}${widget.userData['photo']}",
                                    isFile: false,
                                    fit: BoxFit.cover,
                                    height:
                                    Get.width / 5.6,
                                    width:
                                    Get.width / 5.6,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: Get.width / 90,
                              ),
                              Text(
                                "${widget.userData['name'] == null || widget.userData['name'].toString().trim().isEmpty ? 'Name ${ConstantString.naLabel}' : widget.userData['name']}",
                                maxLines: 2,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w800,
                                  color: ConstantColor
                                      .primaryDark,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              width: width * 0.04),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: [
                                    SizedBox(height: Get.width/50,),
                                    Text(
                                      "${widget.userData['category'] == null || widget.userData['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : widget.userData['category']} (${widget.userData['subcategory'] == null || widget.userData['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : widget.userData['subcategory']})",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        color: ConstantColor
                                            .blackColor,
                                      ),
                                    ),

                                    Text(
                                      widget.userData[
                                      'enq_text'] ??
                                          "",
                                      style: TextStyle(
                                        color: ConstantColor
                                            .blackColor,
                                        fontSize: 11,
                                        fontWeight:
                                        FontWeight
                                            .w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Get.width/10,),
                                Text(
                                  DateFormat('dd-MM-yyyy')
                                      .format(DateTime.parse(
                                      widget.userData[
                                      'created_at'] ??
                                          DateTime
                                              .now())),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w400,
                                    color: ConstantColor
                                        .grayColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    controller: chatReceivedController.scrollController,
                    shrinkWrap: true,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20.0),
                    itemBuilder: (context, index) {
                      final chatItem = messages[messages.length - 1 - index];
                      final isMe = chatItem['user_id']?.toString() ==
                          chatReceivedController.userId.value;
                      final isOptimistic = chatItem['is_optimistic'] == true;
                      return chatBubbles(
                          context,
                          isMe,
                          chatItem,
                          isOptimistic: isOptimistic);
                    },
                  ),
                ),
                widget.isChat
                    ? Padding(
                  padding: const EdgeInsets.only(
                      left: 15, right: 15, bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.circular(100.0),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff000000)
                                      .withAlpha(48),
                                  blurRadius: 0,
                                  offset: const Offset(0, 2),
                                  spreadRadius: 1,
                                ),
                              ]),
                          child: TextFormField(
                            controller:
                            chatReceivedController.charController,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              chatReceivedController.updateMessage(value);
                            },
                            textInputAction: TextInputAction.send,
                            onFieldSubmitted: (_) {
                              if (chatReceivedController.getMessage().isNotEmpty) {
                                chatReceivedController.postSendChatApi(
                                    Map<String, dynamic>.from(widget.userData)
                                );
                              }
                            },
                            style: TextStyle(
                              fontSize: 18,
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            keyboardType: TextInputType.text,
                            cursorColor: ConstantColor.blackColor,
                            decoration: InputDecoration(
                              fillColor: Colors.white,
                              contentPadding:
                              const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 15),
                              hintText: "Type your messages...",
                              hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: ConstantColor.grayColor,
                                  fontWeight: FontWeight.w400),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(100.0),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.02),
                      GestureDetector(
                        onTap: () {
                          if (chatReceivedController.getMessage().isEmpty) {
                            ShowToast.showToast(
                              'Please Enter Message',
                              showSuccess: false,
                            );
                          } else {
                            chatReceivedController.postSendChatApi(
                                Map<String, dynamic>.from(widget.userData)
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: ConstantColor.primary,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Obx(() => chatReceivedController.isSending.value
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
                                )),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox()
              ],
            );
          },
        ));
  }

  Widget chatBubbles(BuildContext context, bool isMe, Map<String, dynamic> chatItem, {bool isOptimistic = false}) {
    return isMe
        ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  constraints:
                      BoxConstraints(maxWidth: Responsive.width(60, context)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 12.0),
                  decoration: BoxDecoration(
                      color: isOptimistic
                          ? const Color(0xffD5EDFB).withOpacity(0.6)
                          : const Color(0xffD5EDFB),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withAlpha(48),
                          blurRadius: 0,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isOptimistic) ...[
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
                          chatItem['text'] ?? "",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            color: ConstantColor.blackColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: isOptimistic
                      ? Text(
                          "Sending...",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: ConstantColor.grayColor.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          DateFormat('hh:mm a').format(_parseLocalTime(chatItem['created_at'])),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 10,
                            color: ConstantColor.grayColor,
                          ),
                        ),
                )
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints:
                      BoxConstraints(maxWidth: Responsive.width(75, context)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30.0, vertical: 12.0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        bottomRight: Radius.circular(10.0),
                        bottomLeft: Radius.circular(10.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff000000).withAlpha(48),
                          blurRadius: 0,
                          offset: const Offset(0, 2),
                          spreadRadius: 0,
                        ),
                      ]),
                  child: Text(
                    chatItem['text'] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    DateFormat('hh:mm a').format(_parseLocalTime(chatItem['created_at'])),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 10,
                      color: ConstantColor.grayColor,
                    ),
                  ),
                )
              ],
            ),
          );
  }

  DateTime _parseLocalTime(dynamic createdAt) {
    if (createdAt == null || createdAt.toString().isEmpty) {
      return DateTime.now();
    }
    try {
      String dateStr = createdAt.toString();
      if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
        String formattedStr = dateStr.replaceAll(' ', 'T');
        if (!formattedStr.endsWith('Z')) {
          formattedStr = '${formattedStr}Z';
        }
        return DateTime.parse(formattedStr).toLocal();
      }
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      try {
        return DateTime.parse(createdAt.toString()).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
  }
}

class Responsive {

  static double width(double size, BuildContext context) {
    return MediaQuery.of(context).size.width * (size / 100);
  }

  static double height(double size, BuildContext context) {
    return MediaQuery.of(context).size.height * (size / 100);
  }

}