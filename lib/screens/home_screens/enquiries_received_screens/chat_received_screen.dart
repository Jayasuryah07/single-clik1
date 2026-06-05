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

  @override
  void dispose() {
    // TODO: implement dispose
    chatReceivedController.timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
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
          () => chatReceivedController.isLoading.value
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : Column(
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
                    // SizedBox(
                    //   height: Get.width / 90,
                    // ),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         "${controller.openReceivedList[index]['name'] == null || controller.openReceivedList[index]['name'].toString().trim().isEmpty ? 'Name ${ConstantString.naLabel}' : controller.openReceivedList[index]['name']}",
                    //         // maxLines: 2,
                    //         // overflow:
                    //         //     TextOverflow
                    //         //         .ellipsis,
                    //         style: TextStyle(
                    //           fontSize: 13,
                    //           fontWeight:
                    //               FontWeight.w800,
                    //           color: ConstantColor
                    //               .primaryDark,
                    //         ),
                    //       ),
                    //     ),
                    //     Text(
                    //       controller.openReceivedList[
                    //                   index]
                    //               ['status'] ??
                    //           "",
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         fontWeight:
                    //             FontWeight.w400,
                    //         color: ConstantColor
                    //             .grayColor,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: Get.width / 90,
                    // ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: chatReceivedController.chatList.length,
                  controller: chatReceivedController.scrollController.value,
                  shrinkWrap: true,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20.0),
                  itemBuilder: (context, index) {
                    debugPrint('data : ${chatReceivedController.chatList[index]}');
                    return chatBubbles(
                        context,
                        chatReceivedController.chatList[index]['user_id']
                            .toString() ==
                            chatReceivedController.userId.value,
                        chatReceivedController.chatList,
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
                          chatReceivedController.charController.value,
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
                        if (chatReceivedController.charController.value.text
                            .trim()
                            .isEmpty) {
                          ShowToast.showToast(
                            'Please Enter Message',
                            showSuccess: false,
                          );
                        } else {
                          chatReceivedController.isLoading(true);

                          chatReceivedController.postSendChatApi(
                              Map<String, dynamic>.from(widget.userData)
                          );
                          chatReceivedController.scrollController.value
                              .animateTo(
                            chatReceivedController.scrollController.value
                                .position.maxScrollExtent,
                            duration: const Duration(
                                milliseconds: 800),
                            curve: Curves.fastOutSlowIn,
                          );
                          chatReceivedController.charController.value
                              .clear();
                          chatReceivedController.isLoading(false);
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
        ));
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