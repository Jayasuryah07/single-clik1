import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/controller/home_controller/user_list_controller.dart';
import 'package:single_clik/screens/home_screens/home_screens/user_details_screen.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../../constants/constant_string.dart';

class UserListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const UserListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<UserListScreen> createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  UserListController userListController = Get.put(UserListController());

  @override
  void initState() {
    // TODO: implement initState
    userListController.postUserListApi(widget.categoryId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      appBar: AppBar(
        backgroundColor: ConstantColor.bgColor,
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_outlined,
            color: ConstantColor.blackColor,
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ConstantColor.blackColor,
          ),
        ),
      ),
      body: Obx(
        () => userListController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await userListController.postUserListApi(widget.categoryId);
                },
                backgroundColor: ConstantColor.whiteColor,
                color: ConstantColor.primary,
                child: userListController.userList.isEmpty
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
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          itemCount: userListController.userList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {

                            return GestureDetector(
                              onTap: () {
                                Get.to(() => UserDetailsScreen(
                                      id: userListController.userList[index]
                                              ['id']
                                          .toString(),
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: ConstantColor.whiteColor,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ConstantColor.primary,
                                          width: 2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: AppImageAsset(
                                          image:
                                              "${ConstantString.userImgUrlPath}${userListController.userList[index]['photo']}",
                                          isFile: false,
                                          fit: BoxFit.cover,
                                          height: width / 3.5,
                                          width: width / 3.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userListController.userList[index]
                                                            ['name'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]['name']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Name ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]['name']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: ConstantColor.primary,
                                            ),
                                            // maxLines: 1,
                                            // overflow:
                                            //     TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: width / 90,
                                          ),
                                          // Text(
                                          //   "Company",
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     fontWeight:
                                          //         FontWeight
                                          //             .w400,
                                          //     color: ConstantColor
                                          //         .grayColor,
                                          //   ),
                                          //   // maxLines: 1,
                                          //   overflow:
                                          //       TextOverflow
                                          //           .ellipsis,
                                          // ),
                                          Text(
                                            userListController.userList[index]
                                                            ['company_name'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]
                                                            ['company_name']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Company Name ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]
                                                        ['company_name']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: ConstantColor.primaryDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                            height: width / 90,
                                          ),
                                          // Text(
                                          //   "Services",
                                          //   style: TextStyle(
                                          //     fontSize: 12,
                                          //     fontWeight:
                                          //         FontWeight
                                          //             .w400,
                                          //     color: ConstantColor
                                          //         .grayColor,
                                          //   ),
                                          //   maxLines: 1,
                                          //   overflow:
                                          //       TextOverflow
                                          //           .ellipsis,
                                          // ),
                                          Container(
                                            width: width,
                                            margin: EdgeInsets.only(
                                              right: Get.width / 30,
                                            ),
                                            decoration: BoxDecoration(
                                              // color: ConstantColor.primary.withOpacity(0.3),
                                              borderRadius:
                                                  BorderRadius.circular(1000),
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Colors.deepOrange
                                                      .withAlpha(0),
                                                  Colors.deepOrange.shade900
                                                      .withAlpha(128),
                                                ],
                                              ),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                              width / 90,
                                              width / 90,
                                              width / 40,
                                              width / 90,
                                            ),
                                            child: Text(
                                              userListController.userList[index]
                                                              ['category'] ==
                                                          null ||
                                                      userListController
                                                          .userList[index]
                                                              ['category']
                                                          .toString()
                                                          .trim()
                                                          .isEmpty
                                                  ? 'Category ${ConstantString.naLabel}'
                                                  : userListController
                                                      .userList[index]
                                                          ['category']
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                              // maxLines: 1,
                                              // overflow:
                                              //     TextOverflow
                                              //         .ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            height: width / 90,
                                          ),
                                          Text(
                                            userListController.userList[index]
                                                            ['subcategory'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]
                                                            ['subcategory']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Sub Category ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]
                                                        ['subcategory']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                            // maxLines: 1,
                                            // overflow:
                                            //     TextOverflow
                                            //         .ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Container(
                                    //   decoration: BoxDecoration(
                                    //     border: Border.all(
                                    //       color: ConstantColor.primary,
                                    //       width: 2,
                                    //     ),
                                    //     shape: BoxShape.circle,
                                    //   ),
                                    //   child: ClipOval(
                                    //     child: AppImageAsset(
                                    //       image:
                                    //           "${ConstantString.userImgUrlPath}${controller.userList[index]['photo']}",
                                    //       isFile: false,
                                    //       fit: BoxFit.cover,
                                    //       height: 80,
                                    //       width: 80,
                                    //     ),
                                    //   ),
                                    // ),
                                    // SizedBox(width: width * 0.04),
                                    // Expanded(
                                    //   child: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(
                                    //         controller.userList[index]
                                    //                 ['name'] ??
                                    //             "",
                                    //         style: TextStyle(
                                    //           fontSize: 18,
                                    //           fontWeight: FontWeight.w600,
                                    //           color: ConstantColor.blackColor,
                                    //         ),
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         "Company",
                                    //         style: TextStyle(
                                    //           fontSize: 12,
                                    //           fontWeight: FontWeight.w400,
                                    //           color: ConstantColor.grayColor,
                                    //         ),
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         controller.userList[index]
                                    //                 ['company_name'] ??
                                    //             "",
                                    //         style: TextStyle(
                                    //           fontSize: 14,
                                    //           fontWeight: FontWeight.w500,
                                    //           color: ConstantColor.blackColor,
                                    //         ),
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         "Services",
                                    //         style: TextStyle(
                                    //           fontSize: 12,
                                    //           fontWeight: FontWeight.w400,
                                    //           color: ConstantColor.grayColor,
                                    //         ),
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         controller.userList[index]
                                    //                 ['category'] ??
                                    //             "",
                                    //         style: TextStyle(
                                    //           fontSize: 14,
                                    //           fontWeight: FontWeight.w500,
                                    //           color: ConstantColor.blackColor,
                                    //         ),
                                    //         maxLines: 1,
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
      ),
    );
  }
}
