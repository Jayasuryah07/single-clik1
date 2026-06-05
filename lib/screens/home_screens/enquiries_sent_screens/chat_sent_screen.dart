import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/chat_sent_controller.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../../constants/constant_string.dart';
import '../../../controller/home_controller/enquiries_received_group_controller.dart';

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
  EnquiriesSentGroupController enquiriesSentGroupController =
      Get.put(EnquiriesSentGroupController());
  ChatSentController chatSentController = Get.put(ChatSentController());

  @override
  void initState() {
    // TODO: implement initState
    getUserId();
    super.initState();
  }

  Future<void> getUserId() async {
    final userDataString = await SharPreferences.getString(SharPreferences.userData);

    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      chatSentController.userId.value = userData['id'].toString();
    } else {
      debugPrint('No user data found in SharedPreferences');
      chatSentController.userId.value = ''; // or handle gracefully
    }
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: ConstantColor.bgColor,
        appBar: AppBar(
          backgroundColor: ConstantColor.primary,
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
                  image:
                  "${ConstantString.userImgUrlPath}${widget.userData['photo']}",
                  isFile: false,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
              SizedBox(width: width * 0.03),
              Text(
                widget.userData['name'] ?? "",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ConstantColor.whiteColor,
                ),
              ),
            ],
          ),
        ),
        body: Obx(
          () => chatSentController.isLoading.value
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatSentController.chatList.length,
                  controller: chatSentController.scrollController.value,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10),
                  itemBuilder: (context, index) {
                    return chatBubbles(
                        context,
                        chatSentController.chatList[index]['user_id']
                            .toString() ==
                            chatSentController.userId.value,
                        chatSentController.chatList,
                        index);
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
                        // height: 60,
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
                          chatSentController.charController.value,
                          onChanged: (value) {},
                          textInputAction: TextInputAction.send,
                          style: TextStyle(
                            fontSize: 20,
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
                                fontSize: 18,
                                color: ConstantColor.grayColor,
                                fontWeight: FontWeight.w400),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(100.0),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(100.0),
                              borderSide: BorderSide.none,
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(100.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
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
                        if (chatSentController.charController.value.text
                            .trim()
                            .isEmpty) {
                          ShowToast.showToast(
                            'Please Enter Message',
                            showSuccess: false,
                          );
                        } else {
                          chatSentController.isLoading(true);

                          chatSentController.postSendChatApi();
                          chatSentController.scrollController.value
                              .animateTo(
                            chatSentController.scrollController.value
                                .position.maxScrollExtent,
                            duration: const Duration(
                                milliseconds: 800),
                            curve: Curves.fastOutSlowIn,
                          );
                          chatSentController.charController.value
                              .clear();
                          chatSentController.isLoading(false);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: ConstantColor.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.send,
                          color: ConstantColor.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox()
            ],
          ),
        ),);
  }

  Widget chatBubbles(BuildContext context, bool isMe, data, index) {
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
                    color: const Color(0xffD5EDFB),
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
                    ],
                  ),
                  child: Text(
                    data[index]['text'] ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    DateFormat('hh:mm a').format(DateTime.parse(
                        data[index]['created_at'] ?? DateTime.now())),
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
                    data[index]['text'] ?? "",
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
                    DateFormat('hh:mm a').format(DateTime.parse(
                        data[index]['created_at'] ?? DateTime.now())),
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
}

class Responsive {

  static double width(double size, BuildContext context) {
    return MediaQuery.of(context).size.width * (size / 100);
  }

  static double height(double size, BuildContext context) {
    return MediaQuery.of(context).size.height * (size / 100);
  }

}
