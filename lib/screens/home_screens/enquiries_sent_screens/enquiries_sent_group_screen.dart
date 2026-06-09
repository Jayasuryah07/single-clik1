import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/controller/home_controller/enquiries_received_group_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_screens/enquiries_sent_screens/chat_sent_screen.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../../controller/home_controller/enquiries_sent_controller.dart';

class EnquiriesSentGroupScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool isChat;

  const EnquiriesSentGroupScreen({
    super.key,
    required this.userData,
    required this.isChat,
  });

  @override
  State<EnquiriesSentGroupScreen> createState() =>
      EnquiriesSentGroupScreenState();
}

class EnquiriesSentGroupScreenState extends State<EnquiriesSentGroupScreen> {
  HomeController homeController = Get.put(HomeController());
  EnquiriesSentController enquiriesSentController =
      Get.put(EnquiriesSentController());
  EnquiriesSentGroupController enquiriesSentGroupController = Get.put(EnquiriesSentGroupController());

  @override
  void initState() {
    // TODO: implement initState
    enquiriesSentGroupController.postGroupSentApi(widget.userData['id'].toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
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
          "My Enquiries Group",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: ConstantColor.whiteColor,
          ),
        ),
      ),
      body: Obx(
        () => enquiriesSentGroupController.isLoading.value
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                  color: ConstantColor.whiteColor,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "${widget.userData['category'] == null || widget.userData['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : widget.userData['category']} (${widget.userData['subcategory'] == null || widget.userData['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : widget.userData['subcategory']})",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  SizedBox(
                      height: widget.userData['enq_text'] == null ||
                          widget.userData['enq_text']
                              .toString()
                              .trim()
                              .isEmpty
                          ? 0
                          : height * 0.01),
                  widget.userData['enq_text'] == null ||
                      widget.userData['enq_text']
                          .toString()
                          .trim()
                          .isEmpty
                      ? const SizedBox()
                      : Text(
                    widget.userData['enq_text'] ?? "",
                    style: TextStyle(
                      color: ConstantColor.blackColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.userData['status'] ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ConstantColor.grayColor,
                        ),
                      ),
                      Text(
                        DateFormat('dd-MM-yyyy').format(
                            DateTime.parse(
                                widget.userData['created_at'] ??
                                    DateTime.now())),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: ConstantColor.grayColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: height * 0.03),
            ListView.builder(
              itemCount: enquiriesSentGroupController.sentGroupList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                debugPrint('Enquiries Sent : ${enquiriesSentGroupController.sentGroupList[index]}');
                return GestureDetector(
                  onTap: () async {
                    await Get.to(
                            () => ChatSentScreen(
                            userData:
                            enquiriesSentGroupController.sentGroupList[index],
                            isChat: widget.isChat),
                        arguments:
                        enquiriesSentGroupController.sentGroupList[index])
                        ?.then((value) {
                      enquiriesSentGroupController.postGroupSentApi(
                          widget.userData['id'].toString());
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: ConstantColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 1),
                          blurRadius: 9,
                          color: Colors.black.withAlpha(64),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: ConstantColor.primary,
                              width: 1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: AppImageAsset(
                              image:
                              "${ConstantString.userImgUrlPath}${enquiriesSentGroupController.sentGroupList[index]['photo']}",
                              isFile: false,
                              fit: BoxFit.fitHeight,
                              height: 60,
                              width: 60,
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.03),
                        Expanded(
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                enquiriesSentGroupController.sentGroupList[index]
                                ['name'] ??
                                    "",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  enquiriesSentGroupController.sentGroupList[index][
                                  'unread_reply_count'] ==
                                      null ||
                                      enquiriesSentGroupController
                                          .sentGroupList[index][
                                      'unread_reply_count']
                                          .toString()
                                          .trim()
                                          .isEmpty ||
                                      enquiriesSentGroupController.sentGroupList[
                                      index][
                                      'unread_reply_count'] ==
                                          0
                                      ? const SizedBox()
                                      : Container(
                                    decoration: BoxDecoration(
                                      color: ConstantColor
                                          .greenColor,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(
                                        Get.width / 60),
                                    margin: EdgeInsets.only(
                                      right: Get.width / 60,
                                    ),
                                    child: Text(
                                      enquiriesSentGroupController
                                          .sentGroupList[index][
                                      'unread_reply_count']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: ConstantColor
                                            .whiteColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    "View  ->",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: ConstantColor.grayColor,
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }
}
