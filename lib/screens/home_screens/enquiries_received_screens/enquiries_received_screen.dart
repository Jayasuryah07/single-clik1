import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/controller/home_controller/enquiries_received_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_screens/enquiries_received_screens/chat_received_screen.dart';
import 'package:single_clik/widget/app_image_assets.dart';

class EnquiriesReceivedScreen extends StatefulWidget {
  const EnquiriesReceivedScreen({super.key});

  @override
  State<EnquiriesReceivedScreen> createState() =>
      EnquiriesReceivedScreenState();
}

class EnquiriesReceivedScreenState extends State<EnquiriesReceivedScreen> {

  EnquiriesReceivedController enquiriesReceivedController = Get.put(EnquiriesReceivedController());
  HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    if(enquiriesReceivedController.tabController.index == 0)
      {
        getData('1');
      }
    else
      {
        getData('2');
      }
    super.initState();
  }

  Future<void> getData(String status) async {
    await enquiriesReceivedController.postReceivedApi(status);
    await homeController
        .getSentEnquiriesUnreadCount("1");
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      body: Obx(
        () => Column(
          children: [
            Container(
              color: ConstantColor.primary,
              child: TabBar(
                controller: enquiriesReceivedController.tabController,
                indicatorColor: ConstantColor.whiteColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 4,
                onTap: (value) async {
                  if (value == 0) {
                    await enquiriesReceivedController.postReceivedApi("1");
                    await homeController.getSentEnquiriesUnreadCount("1");
                  } else if (value == 1) {
                    await enquiriesReceivedController.postReceivedApi("2");
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
              child: enquiriesReceivedController.isLoading.value
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : TabBarView(
                controller: enquiriesReceivedController.tabController,
                children: [
                  RefreshIndicator(
                    onRefresh: () async {
                      await enquiriesReceivedController.postReceivedApi("1");
                      await homeController
                          .getSentEnquiriesUnreadCount("1");
                    },
                    backgroundColor: ConstantColor.whiteColor,
                    color: ConstantColor.primary,
                    child: enquiriesReceivedController.openReceivedList.isEmpty
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
                      enquiriesReceivedController.openReceivedList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        debugPrint(
                            'Enquiries : ${enquiriesReceivedController.openReceivedList[index]}');

                        return GestureDetector(
                          onTap: () async {
                            await Get.to(
                                  () => ChatReceivedScreen(
                                  userData: enquiriesReceivedController
                                      .openReceivedList[index],
                                  isChat: true),
                              arguments: enquiriesReceivedController
                                  .openReceivedList[index],
                            )?.then((value) async {
                              await enquiriesReceivedController
                                  .postReceivedApi("1");
                              await homeController
                                  .getSentEnquiriesUnreadCount(
                                  "1");
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                Get.width / 30,
                                Get.width / 120,
                                Get.width / 50,
                                Get.width / 30),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center,
                                      children: [
                                        SizedBox(
                                          height:
                                          Get.width / 50,
                                        ),
                                        Container(
                                          decoration:
                                          BoxDecoration(
                                            border: Border.all(
                                              color:
                                              ConstantColor
                                                  .primary,
                                              width: 1.5,
                                            ),
                                            shape:
                                            BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child:
                                            AppImageAsset(
                                              image:
                                              "${ConstantString.userImgUrlPath}${enquiriesReceivedController.openReceivedList[index]['photo']}",
                                              isFile: false,
                                              fit: BoxFit.cover,
                                              height:
                                              Get.width /
                                                  5.6,
                                              width: Get.width /
                                                  5.6,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                          Get.width / 90,
                                        ),
                                        Text(
                                          "${enquiriesReceivedController.openReceivedList[index]['name'] == null || enquiriesReceivedController.openReceivedList[index]['name'].toString().trim().isEmpty ? 'Name ${ConstantString.naLabel}' : enquiriesReceivedController.openReceivedList[index]['name']}",
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                      Get.width /
                                                          50,
                                                    ),
                                                    Text(
                                                      "${enquiriesReceivedController.openReceivedList[index]['category'] == null || enquiriesReceivedController.openReceivedList[index]['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiriesReceivedController.openReceivedList[index]['category']} (${enquiriesReceivedController.openReceivedList[index]['subcategory'] == null || enquiriesReceivedController.openReceivedList[index]['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiriesReceivedController.openReceivedList[index]['subcategory']})",
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        15,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color: ConstantColor
                                                            .blackColor,
                                                      ),
                                                    ),

                                                    Text(
                                                      enquiriesReceivedController.openReceivedList[index]
                                                      [
                                                      'enq_text'] ??
                                                          "",
                                                      style:
                                                      TextStyle(
                                                        color: ConstantColor
                                                            .blackColor,
                                                        fontSize:
                                                        13,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              (enquiriesReceivedController.openReceivedList[index]
                                              [
                                              'unread_reply_count'] ??
                                                  0) ==
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
                                                padding: const EdgeInsets
                                                    .all(
                                                    10),
                                                child:
                                                Center(
                                                  child:
                                                  Text(
                                                    "${enquiriesReceivedController.openReceivedList[index]['unread_reply_count'] ?? ""}",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      13,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color:
                                                      ConstantColor.whiteColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                            Get.width / 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat(
                                                    'dd-MM-yyyy')
                                                    .format(DateTime.parse(enquiriesReceivedController.openReceivedList[index]
                                                [
                                                'created_at'] ??
                                                    DateTime
                                                        .now())),
                                                style:
                                                TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight
                                                      .w400,
                                                  color: ConstantColor
                                                      .grayColor,
                                                ),
                                              ),
                                              Container(
                                                decoration:
                                                BoxDecoration(
                                                  color: ConstantColor
                                                      .primary,
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      30),
                                                ),
                                                padding: EdgeInsets
                                                    .symmetric(
                                                  vertical:
                                                  Get.width /
                                                      120,
                                                  horizontal: Get.width/90,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                                  children: [
                                                    Text(
                                                      " View",
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        12,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: ConstantColor
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: ConstantColor
                                                          .whiteColor,
                                                      size:
                                                      Get.width /
                                                          30,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
                        );
                      },
                    ),
                  ),
                  RefreshIndicator(
                    onRefresh: () async {
                      await enquiriesReceivedController.postReceivedApi("2");
                      await homeController
                          .getSentEnquiriesUnreadCount("1");
                    },
                    backgroundColor: ConstantColor.whiteColor,
                    color: ConstantColor.primary,
                    child: enquiriesReceivedController.closeReceivedList.isEmpty
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
                      enquiriesReceivedController.closeReceivedList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // List categoryDataList = homeController
                        //     .categoryList
                        //     .where(
                        //       (element) =>
                        //           element['id'].toString() ==
                        //           controller
                        //               .closeReceivedList[index]
                        //                   ['category']
                        //               .toString(),
                        //     )
                        //     .toList();
                        // Map categoryData =
                        //     categoryDataList.isEmpty
                        //         ? {}
                        //         : categoryDataList.first;
                        // String categoryName =
                        //     categoryData['category'] ?? '';
                        return GestureDetector(
                          onTap: () {
                            Get.to(
                                    () => ChatReceivedScreen(
                                    userData: enquiriesReceivedController
                                        .closeReceivedList[
                                    index],
                                    isChat: false),
                                arguments: enquiriesReceivedController
                                    .closeReceivedList[
                                index])
                                ?.then((value) async {

                              await enquiriesReceivedController
                                  .postReceivedApi("2");
                              await homeController
                                  .getSentEnquiriesUnreadCount(
                                  "1");
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                Get.width / 30,
                                Get.width / 120,
                                Get.width / 50,
                                Get.width / 30),
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .center,
                                      children: [
                                        SizedBox(
                                          height:
                                          Get.width / 50,
                                        ),
                                        Container(
                                          decoration:
                                          BoxDecoration(
                                            border: Border.all(
                                              color:
                                              ConstantColor
                                                  .primary,
                                              width: 1.5,
                                            ),
                                            shape:
                                            BoxShape.circle,
                                          ),
                                          child: ClipOval(
                                            child:
                                            AppImageAsset(
                                              image:
                                              "${ConstantString.userImgUrlPath}${enquiriesReceivedController.closeReceivedList[index]['photo']}",
                                              isFile: false,
                                              fit: BoxFit.cover,
                                              height:
                                              Get.width /
                                                  5.6,
                                              width: Get.width /
                                                  5.6,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                          Get.width / 90,
                                        ),
                                        Text(
                                          "${enquiriesReceivedController.closeReceivedList[index]['name'] == null || enquiriesReceivedController.closeReceivedList[index]['name'].toString().trim().isEmpty ? 'Name ${ConstantString.naLabel}' : enquiriesReceivedController.closeReceivedList[index]['name']}",
                                          maxLines: 2,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
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
                                        crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                      Get.width /
                                                          50,
                                                    ),
                                                    Text(
                                                      "${enquiriesReceivedController.closeReceivedList[index]['category'] == null || enquiriesReceivedController.closeReceivedList[index]['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiriesReceivedController.closeReceivedList[index]['category']} (${enquiriesReceivedController.closeReceivedList[index]['subcategory'] == null || enquiriesReceivedController.closeReceivedList[index]['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiriesReceivedController.closeReceivedList[index]['subcategory']})",
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        15,
                                                        fontWeight:
                                                        FontWeight.w600,
                                                        color: ConstantColor
                                                            .blackColor,
                                                      ),
                                                    ),

                                                    Text(
                                                      enquiriesReceivedController.closeReceivedList[index]
                                                      [
                                                      'enq_text'] ??
                                                          "",
                                                      style:
                                                      TextStyle(
                                                        color: ConstantColor
                                                            .blackColor,
                                                        fontSize:
                                                        13,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              (enquiriesReceivedController.closeReceivedList[index]
                                              [
                                              'unread_reply_count'] ??
                                                  0) ==
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
                                                padding: const EdgeInsets
                                                    .all(
                                                    10),
                                                child:
                                                Center(
                                                  child:
                                                  Text(
                                                    "${enquiriesReceivedController.closeReceivedList[index]['unread_reply_count'] ?? ""}",
                                                    style:
                                                    TextStyle(
                                                      fontSize:
                                                      13,
                                                      fontWeight:
                                                      FontWeight.w400,
                                                      color:
                                                      ConstantColor.whiteColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height:
                                            Get.width / 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat(
                                                    'dd-MM-yyyy')
                                                    .format(DateTime.parse(enquiriesReceivedController.closeReceivedList[index]
                                                [
                                                'created_at'] ??
                                                    DateTime
                                                        .now())),
                                                style:
                                                TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight
                                                      .w400,
                                                  color: ConstantColor
                                                      .grayColor,
                                                ),
                                              ),
                                              Container(
                                                decoration:
                                                BoxDecoration(
                                                  color: ConstantColor
                                                      .primary,
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      30),
                                                ),
                                                padding: EdgeInsets
                                                    .symmetric(
                                                  vertical:
                                                  Get.width /
                                                      120,
                                                  horizontal: Get.width/90,
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                                  children: [
                                                    Text(
                                                      " View",
                                                      style:
                                                      TextStyle(
                                                        fontSize:
                                                        12,
                                                        fontWeight:
                                                        FontWeight.w400,
                                                        color: ConstantColor
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .arrow_forward_ios_rounded,
                                                      color: ConstantColor
                                                          .whiteColor,
                                                      size:
                                                      Get.width /
                                                          30,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
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
