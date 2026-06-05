import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/controller/home_controller/enquiries_sent_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_screens/enquiries_sent_screens/enquiries_sent_group_screen.dart';
import '../../../widget/dialogs.dart';

class EnquiriesSentScreen extends StatefulWidget {
  const EnquiriesSentScreen({super.key});

  @override
  State<EnquiriesSentScreen> createState() => EnquiriesSentScreenState();
}

class EnquiriesSentScreenState extends State<EnquiriesSentScreen> {

  EnquiriesSentController enquiriesSentController = Get.put(EnquiriesSentController());
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    if (enquiriesSentController.tabController.index == 0) {
      getData('1');
    }
    else {
      getData('2');
    }
    super.initState();
  }

  Future<void> getData(String status) async {
    await enquiriesSentController.postSentApi(status);
    await homeController
        .getSentEnquiriesUnreadCount("1");
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      body: Obx(
            () => Column(
          children: [
            Container(
              color: ConstantColor.primary,
              child: TabBar(
                controller: enquiriesSentController.tabController,
                indicatorColor: ConstantColor.whiteColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 4,
                onTap: (value) async {
                  if (value == 0) {
                    await enquiriesSentController.postSentApi("1");
                    await homeController.getSentEnquiriesUnreadCount("1");
                  } else if (value == 1) {
                    await enquiriesSentController.postSentApi("2");
                    await homeController.getSentEnquiriesUnreadCount("1");
                  }
                },
                tabs: [
                  Tab(
                    child: Text(
                      "Open",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: ConstantColor.whiteColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Closed",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: ConstantColor.whiteColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: enquiriesSentController.isLoading.value
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : TabBarView(
                controller: enquiriesSentController.tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await enquiriesSentController.postSentApi("1");
                      await homeController
                          .getSentEnquiriesUnreadCount("1");
                    },
                    backgroundColor: ConstantColor.whiteColor,
                    color: ConstantColor.primary,
                    child: enquiriesSentController.openSentList.isEmpty
                        ? ListView(
                      children: [
                        SizedBox(
                          height: Get.height / 2.8,
                        ),
                        Center(
                          child: Text(
                            ConstantString.dataNotFoundLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      itemCount: enquiriesSentController.openSentList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // List categoryDataList = homeController.categoryList.where((element) => element['id'].toString() == controller.openSentList[index]['category'].toString(),).toList();
                        // Map categoryData = categoryDataList.isEmpty ? {} : categoryDataList.first;
                        // String categoryName = categoryData['category'] ?? '';
                        debugPrint(
                            'Enquiries Sent ${enquiriesSentController.openSentList[index]}');
                        return GestureDetector(
                          onTap: () async {
                            await Get.to(
                                    () => EnquiriesSentGroupScreen(
                                    userData: enquiriesSentController
                                        .openSentList[index],
                                    isChat: true),
                                arguments: {
                                  'enquiryId': enquiriesSentController
                                      .openSentList[index]['id']
                                      .toString()
                                })?.then((value) async {
                              await enquiriesSentController.postSentApi('1');
                              await homeController
                                  .getSentEnquiriesUnreadCount(
                                  "1");
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                                color: ConstantColor.whiteColor,
                                borderRadius:
                                BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        "${enquiriesSentController.openSentList[index]['category'] == null || enquiriesSentController.openSentList[index]['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiriesSentController.openSentList[index]['category']} (${enquiriesSentController.openSentList[index]['subcategory'] == null || enquiriesSentController.openSentList[index]['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiriesSentController.openSentList[index]['subcategory']})",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight:
                                          FontWeight.w600,
                                          color: ConstantColor
                                              .blackColor,
                                        ),
                                      ),

                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        Dialogs.dialogs
                                            .areYouSureAlertDialog(
                                            context:
                                            context,
                                            title:
                                            'Close Enquire?',
                                            description:
                                            'Do you want to close this enquire?',
                                            onPressed:
                                                () async {
                                              Get.back();
                                              await enquiriesSentController.postCloseSentApi(enquiriesSentController
                                                  .openSentList[
                                              index]
                                              ['id']
                                                  .toString());

                                              await homeController
                                                  .getSentEnquiriesUnreadCount(
                                                  "1");
                                            });
                                      },
                                      child: const SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Icon(
                                          Icons.close,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                    height: enquiriesSentController.openSentList[
                                    index][
                                    'enq_text'] ==
                                        null ||
                                        enquiriesSentController
                                            .openSentList[
                                        index]
                                        ['enq_text']
                                            .toString()
                                            .trim()
                                            .isEmpty
                                        ? 0
                                        : height * 0.01),
                                enquiriesSentController.openSentList[index]
                                ['enq_text'] ==
                                    null ||
                                    enquiriesSentController
                                        .openSentList[index]
                                    ['enq_text']
                                        .toString()
                                        .trim()
                                        .isEmpty
                                    ? const SizedBox()
                                    : Text(
                                  enquiriesSentController.openSentList[
                                  index]
                                  ['enq_text'] ??
                                      "",
                                  style: TextStyle(
                                    color: ConstantColor
                                        .blackColor,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      enquiriesSentController.openSentList[
                                      index]
                                      ['status'] ??
                                          "",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: ConstantColor
                                            .grayColor,
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        enquiriesSentController.openSentList[
                                        index]
                                        [
                                        'unread_reply_count'] ==
                                            null ||
                                            enquiriesSentController
                                                .openSentList[
                                            index][
                                            'unread_reply_count']
                                                .toString()
                                                .trim()
                                                .isEmpty ||
                                            enquiriesSentController.openSentList[
                                            index]
                                            [
                                            'unread_reply_count'] ==
                                                0
                                            ? const SizedBox()
                                            : Container(
                                          decoration:
                                          BoxDecoration(
                                            color: ConstantColor
                                                .greenColor,
                                            shape: BoxShape
                                                .circle,
                                          ),
                                          padding:
                                          EdgeInsets.all(
                                              Get.width /
                                                  60),
                                          margin:
                                          EdgeInsets
                                              .only(
                                            right:
                                            Get.width /
                                                60,
                                          ),
                                          child: Text(
                                            enquiriesSentController
                                                .openSentList[
                                            index]
                                            [
                                            'unread_reply_count']
                                                .toString(),
                                            style:
                                            TextStyle(
                                              fontSize:
                                              12,
                                              fontWeight:
                                              FontWeight
                                                  .w400,
                                              color: ConstantColor
                                                  .whiteColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat(
                                              'dd-MM-yyyy')
                                              .format(DateTime.parse(
                                              enquiriesSentController.openSentList[
                                              index]
                                              [
                                              'created_at'] ??
                                                  DateTime
                                                      .now())),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                            FontWeight.w400,
                                            color: ConstantColor
                                                .grayColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      await enquiriesSentController.postSentApi("2");
                      await homeController
                          .getSentEnquiriesUnreadCount("1");
                    },
                    backgroundColor: ConstantColor.whiteColor,
                    color: ConstantColor.primary,
                    child: enquiriesSentController.closeSentList.isEmpty
                        ? ListView(
                      children: [
                        SizedBox(
                          height: Get.height / 2.8,
                        ),
                        Center(
                          child: Text(
                            ConstantString.dataNotFoundLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    )
                        : ListView.builder(
                      itemCount:
                      enquiriesSentController.closeSentList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // List categoryDataList = homeController.categoryList.where((element) => element['id'].toString() == controller.closeSentList[index]['category'].toString(),).toList();
                        // Map categoryData = categoryDataList.isEmpty ? {} : categoryDataList.first;
                        // String categoryName = categoryData['category'] ?? '';
                        return GestureDetector(
                          onTap: () async {
                            await Get.to(
                                    () => EnquiriesSentGroupScreen(
                                    userData: enquiriesSentController
                                        .closeSentList[index],
                                    isChat: false),
                                arguments: {
                                  'enquiryId': enquiriesSentController
                                      .closeSentList[index]
                                  ['id']
                                      .toString()
                                })?.then((value) async {
                              await enquiriesSentController.postSentApi('2');
                              await homeController
                                  .getSentEnquiriesUnreadCount(
                                  "1");
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            decoration: BoxDecoration(
                                color: ConstantColor.whiteColor,
                                borderRadius:
                                BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${enquiriesSentController.closeSentList[index]['category'] == null || enquiriesSentController.closeSentList[index]['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiriesSentController.closeSentList[index]['category']} (${enquiriesSentController.closeSentList[index]['subcategory'] == null || enquiriesSentController.closeSentList[index]['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiriesSentController.closeSentList[index]['subcategory']})",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: ConstantColor
                                        .blackColor,
                                  ),
                                ),

                                SizedBox(
                                    height: enquiriesSentController.closeSentList[
                                    index][
                                    'enq_text'] ==
                                        null ||
                                        enquiriesSentController
                                            .closeSentList[
                                        index]
                                        ['enq_text']
                                            .toString()
                                            .trim()
                                            .isEmpty
                                        ? 0
                                        : height * 0.01),
                                enquiriesSentController.closeSentList[index]
                                ['enq_text'] ==
                                    null ||
                                    enquiriesSentController
                                        .closeSentList[
                                    index]
                                    ['enq_text']
                                        .toString()
                                        .trim()
                                        .isEmpty
                                    ? const SizedBox()
                                    : Text(
                                  enquiriesSentController.closeSentList[
                                  index]
                                  ['enq_text'] ??
                                      "",
                                  style: TextStyle(
                                    color: ConstantColor
                                        .blackColor,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Text(
                                      enquiriesSentController.closeSentList[
                                      index]
                                      ['status'] ??
                                          "",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: ConstantColor
                                            .grayColor,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('dd-MM-yyyy')
                                          .format(DateTime.parse(
                                          enquiriesSentController.closeSentList[
                                          index]
                                          [
                                          'created_at'] ??
                                              DateTime
                                                  .now())),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight:
                                        FontWeight.w400,
                                        color: ConstantColor
                                            .grayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
