import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';

import 'package:single_clik/screens/home_screens/home_screens/user_details_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/user_list_screen.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    const quick = Duration(milliseconds: 1000);
    final scaleTween = Tween(begin: 0.0, end: 1.0);
    controller = AnimationController(duration: quick, vsync: this);
    animation = scaleTween.animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    )..addListener(() {
        scale.value = animation.value;
      });

    getData();
    getServices();
    // _animate();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

 Future<void> getServices() async {
  await homeController.postBusinessDashboardApi("0");
  await homeController.postBusinessDashboardApi("1");
 }

  RxDouble scale = 1.0.obs;

  HomeController homeController = Get.put(HomeController());

  void getData() {
    homeController.tabController.addListener(() {
      homeController.tabIndex.value = homeController.tabController.index;
      if (homeController.tabIndex.value != 0) {
        homeController.searchController.value.clear();
        homeController.searchProduct('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      floatingActionButton: SizedBox(
        width: Get.width,
        // color: Colors.red,
        child: Row(
          children: [

            const Spacer(),
            Obx(
              () => Transform.scale(
                scale: scale.value,
                child: GestureDetector(
                  onTap: () {
                    raiseInquiryDialog(context, homeController, height, width);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: ConstantColor.primary,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      "assets/icons/icon_add.png",
                      height: 25,
                      width: 25,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => Column(
          children: [
            Container(
              color: ConstantColor.primary,
              child: TabBar(
                controller: homeController.tabController,
                indicatorColor: ConstantColor.whiteColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 4,
                onTap: (value) async {
                  homeController.tabIndex.value = value;
                  homeController.isSearchOpen.value = false;
                  if (value == 0) {
                    // homeController.postDashboardApi("");
                    // homeController.postDashboardSliderApi("");
                    // homeController.postDashboardAdvSliderApi();
                    await homeController.getSentEnquiriesUnreadCount("1");
                  } else if (value == 1) {
                   // homeController.postBusinessDashboardApi("0");
                    await homeController.getSentEnquiriesUnreadCount("1");
                  } else if (value == 2) {
                    //omeController.postBusinessDashboardApi("1");
                    await homeController.getSentEnquiriesUnreadCount("1");
                  }
                  // await homeController.getSentEnquiriesUnreadCount("1");
                },
                tabs: [
                  Tab(
                    child: Text(
                      "All",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: ConstantColor.whiteColor,
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Business",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: ConstantColor.whiteColor),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "Services",
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
              child: homeController.isLoading.value
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : TabBarView(
                      controller: homeController.tabController,
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postDashboardApi("");
                            await homeController.postDashboardSliderApi("");
                            await homeController.postDashboardAdvSliderApi();
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.allList.isEmpty
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
                              : SingleChildScrollView(
                                  physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
                                  child: Column(
                                    children: [
                                      // Obx(
                                      //   () => !searchClick.value
                                      //       ? const SizedBox()
                                      //       : Padding(
                                      //           padding:
                                      //               const EdgeInsets.all(10.0),
                                      //           child: SizedBox(
                                      //             height: 50,
                                      //             child: TextFormField(
                                      //               controller: controller
                                      //                   .searchController.value,
                                      //               focusNode: controller
                                      //                   .searchFocusNode,
                                      //               onChanged: (value) {
                                      //                 controller
                                      //                     .searchProduct(value);
                                      //               },
                                      //               textInputAction:
                                      //                   TextInputAction.search,
                                      //               style: TextStyle(
                                      //                 fontSize: 20,
                                      //                 color: ConstantColor
                                      //                     .blackColor,
                                      //                 fontWeight: FontWeight.w500,
                                      //               ),
                                      //               keyboardType:
                                      //                   TextInputType.text,
                                      //               cursorColor:
                                      //                   ConstantColor.blackColor,
                                      //               decoration: InputDecoration(
                                      //                 fillColor: Colors.white,
                                      //                 contentPadding:
                                      //                     const EdgeInsets
                                      //                         .symmetric(
                                      //                         vertical: 10,
                                      //                         horizontal: 15),
                                      //                 hintText: "Search",
                                      //                 hintStyle: TextStyle(
                                      //                     fontSize: 18,
                                      //                     color: ConstantColor
                                      //                         .grayColor,
                                      //                     fontWeight:
                                      //                         FontWeight.w400),
                                      //                 filled: true,
                                      //                 border: OutlineInputBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius.circular(
                                      //                           100.0),
                                      //                 ),
                                      //                 focusedBorder:
                                      //                     OutlineInputBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius.circular(
                                      //                           100.0),
                                      //                 ),
                                      //                 disabledBorder:
                                      //                     OutlineInputBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius.circular(
                                      //                           100.0),
                                      //                 ),
                                      //                 enabledBorder:
                                      //                     OutlineInputBorder(
                                      //                   borderRadius:
                                      //                       BorderRadius.circular(
                                      //                           100.0),
                                      //                 ),
                                      //                 suffixIcon: IconButton(
                                      //                   onPressed: () {
                                      //                     searchClick.value =
                                      //                         false;
                                      //                     controller
                                      //                         .searchFocusNode
                                      //                         .unfocus();
                                      //                     controller
                                      //                         .searchProduct('');
                                      //                   },
                                      //                   icon: Icon(
                                      //                     Icons.close,
                                      //                     color: ConstantColor
                                      //                         .blackColor,
                                      //                     size: Get.width / 18,
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      // ),
                                      ListView.separated(
                                        itemCount:
                                            homeController.allList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) =>
                                            index == 0
                                                ? homeController
                                                        .allSliderList.isEmpty
                                                    ? const SizedBox()
                                                    : Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height:
                                                                Get.width / 150,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: Get.width /
                                                                  30,
                                                            ),
                                                            child: Text(
                                                              'Recently Joined Members',
                                                              style: TextStyle(
                                                                color: ConstantColor
                                                                    .blackColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 15,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                Get.width / 35,
                                                          ),
                                                          CarouselSlider(
                                                            options: CarouselOptions(
                                                                height:
                                                                    width / 2.5,
                                                                autoPlay: true,
                                                                initialPage: 0,
                                                                enlargeFactor:
                                                                    0,
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                viewportFraction:
                                                                    0.3),
                                                            items:
                                                                List.generate(
                                                              homeController
                                                                  .allSliderList
                                                                  .length,
                                                              (index) =>
                                                                  SizedBox(
                                                                width:
                                                                    width / 3.5,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(() =>
                                                                            UserDetailsScreen(
                                                                              id: homeController.allSliderList[index]['id'].toString(),
                                                                            ));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                ConstantColor.primary,
                                                                            width:
                                                                                2,
                                                                          ),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                        ),
                                                                        child:
                                                                            ClipOval(
                                                                          child:
                                                                              AppImageAsset(
                                                                            image:
                                                                                "${ConstantString.userImgUrlPath}${homeController.allSliderList[index]['photo']}",
                                                                            isFile:
                                                                                false,
                                                                            height:
                                                                                width / 4,
                                                                            width:
                                                                                width / 4,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height: height *
                                                                            0.01),
                                                                    Text(
                                                                      (homeController.allSliderList[index]
                                                                              [
                                                                              'name'] ??
                                                                          ""),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        color: ConstantColor
                                                                            .primary,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // SingleChildScrollView(
                                                          //   scrollDirection:
                                                          //       Axis.horizontal,
                                                          //   child: Padding(
                                                          //     padding:
                                                          //         EdgeInsets
                                                          //             .all(
                                                          //       width / 30,
                                                          //     ),
                                                          //     child: Row(
                                                          //         crossAxisAlignment:
                                                          //             CrossAxisAlignment
                                                          //                 .start,
                                                          //         children:
                                                          //             List.generate(
                                                          //           controller
                                                          //               .allSliderList
                                                          //               .length,
                                                          //           (index) =>
                                                          //               Padding(
                                                          //             padding:
                                                          //                 EdgeInsets.only(
                                                          //               left: index == 0
                                                          //                   ? 0
                                                          //                   : width / 60,
                                                          //             ),
                                                          //             child:
                                                          //                 SizedBox(
                                                          //               width:
                                                          //                   width / 3.5,
                                                          //               child:
                                                          //                   Column(
                                                          //                 crossAxisAlignment: CrossAxisAlignment.center,
                                                          //                 children: [
                                                          //                   GestureDetector(
                                                          //                     onTap: () {
                                                          //                       Get.to(() => UserDetailsScreen(
                                                          //                             id: homeController.allSliderList[index]['id'].toString(),
                                                          //                           ));
                                                          //                     },
                                                          //                     child: Container(
                                                          //                       decoration: BoxDecoration(
                                                          //                         border: Border.all(
                                                          //                           color: ConstantColor.primary,
                                                          //                           width: 2,
                                                          //                         ),
                                                          //                         shape: BoxShape.circle,
                                                          //                       ),
                                                          //                       child: ClipOval(
                                                          //                         child: AppImageAsset(
                                                          //                           image: "${ConstantString.userImgUrlPath}${homeController.allSliderList[index]['photo']}",
                                                          //                           isFile: false,
                                                          //                           height: width / 4,
                                                          //                           width: width / 4,
                                                          //                           fit: BoxFit.cover,
                                                          //                         ),
                                                          //                       ),
                                                          //                     ),
                                                          //                   ),
                                                          //                   SizedBox(height: height * 0.01),
                                                          //                   Text(
                                                          //                     homeController.allSliderList[index]['name'] ?? "",
                                                          //                     style: TextStyle(
                                                          //                       fontSize: 12,
                                                          //                       fontWeight: FontWeight.w500,
                                                          //                       color: ConstantColor.primary,
                                                          //                     ),
                                                          //                     // overflow:
                                                          //                     //     TextOverflow
                                                          //                     //         .ellipsis,
                                                          //                     textAlign: TextAlign.center,
                                                          //                     maxLines: 2,
                                                          //                   ),
                                                          //                 ],
                                                          //               ),
                                                          //             ),
                                                          //           ),
                                                          //         )),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      )
                                                : index == 8
                                                    ? homeController
                                                            .allAdvSliderList
                                                            .isEmpty
                                                        ? const SizedBox()
                                                        : Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    Get.width /
                                                                        30,
                                                              ),
                                                              CarouselSlider(
                                                                options:
                                                                    CarouselOptions(
                                                                  // height: width /
                                                                  //     2.5,
                                                                  autoPlay:
                                                                      true,
                                                                  initialPage:
                                                                      0,
                                                                  enlargeFactor:
                                                                      0,
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  viewportFraction:
                                                                      0.9,
                                                                  enlargeCenterPage:
                                                                      false,
                                                                ),
                                                                items: List
                                                                    .generate(
                                                                  homeController
                                                                      .allAdvSliderList
                                                                      .length,
                                                                  (index) =>
                                                                      SizedBox(
                                                                    width:
                                                                        width,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            debugPrint('slider_url : ${homeController.allAdvSliderList[index]['slider_url']}');
                                                                            Uri url = Uri.parse(homeController.allAdvSliderList[index]['slider_url'] ?? '');
                                                                            debugPrint('slider_url $url');
                                                                            if (await canLaunchUrl(url)) {
                                                                              await launchUrl(url);
                                                                            } else {
                                                                              // ShowToast.showToast(
                                                                              //   'Url ${ConstantString.notAvailableLabel}',
                                                                              //   showSuccess: false,
                                                                              // );
                                                                            }
                                                                            // Get.to(() =>
                                                                            //     UserDetailsScreen(
                                                                            //       id: controller.allAdvSliderList[index]['id'].toString(),
                                                                            //     ));
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: ConstantColor.primary,
                                                                                  width: 2,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(15)),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(13),
                                                                              child: AppImageAsset(
                                                                                image: "${ConstantString.sliderImgUrlPath}${homeController.allAdvSliderList[index]['slider_images']}",
                                                                                isFile: false,
                                                                                height: width / 2,
                                                                                width: width / 1.2,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        // SizedBox(
                                                                        //     height:
                                                                        //         height * 0.01),
                                                                        // Text(
                                                                        //   homeController.allAdvSliderList[index]['name'] ??
                                                                        //       "",
                                                                        //   style:
                                                                        //       TextStyle(
                                                                        //     fontSize:
                                                                        //         12,
                                                                        //     fontWeight:
                                                                        //         FontWeight.w500,
                                                                        //     color:
                                                                        //         ConstantColor.primary,
                                                                        //   ),
                                                                        //   // overflow:
                                                                        //   //     TextOverflow
                                                                        //   //         .ellipsis,
                                                                        //   textAlign:
                                                                        //       TextAlign.center,
                                                                        //   maxLines:
                                                                        //       2,
                                                                        // ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),

                                                            ],
                                                          )
                                                    : const SizedBox(),
                                        itemBuilder: (context, index) {
                                          debugPrint('data : ${homeController.allList[index]}');

                                          return GestureDetector(
                                            onTap: () {
                                              debugPrint('Id: ${homeController.allList[index]['id']}');
                                              Get.to(() => UserDetailsScreen(
                                                    id: homeController
                                                        .allList[index]['id']
                                                        .toString(),
                                                  ));
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: ConstantColor.whiteColor,
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: ConstantColor
                                                            .primary,
                                                        width: 2,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: ClipOval(
                                                      child: AppImageAsset(
                                                        image:
                                                            "${ConstantString.userImgUrlPath}${homeController.allList[index]['photo']}",
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          (homeController.allList[
                                                                      index]
                                                                  ['name'] ??
                                                              ""),
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: ConstantColor
                                                                .primary,
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
                                                          homeController.allList[
                                                                      index][
                                                                  'company_name'] ??
                                                              "",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: ConstantColor
                                                                .primaryDark,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                                          margin:
                                                              EdgeInsets.only(
                                                            right:
                                                                Get.width / 30,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            // color: ConstantColor.primary.withOpacity(0.3),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        1000),
                                                            gradient:
                                                                LinearGradient(
                                                              begin: Alignment
                                                                  .centerLeft,
                                                              end: Alignment
                                                                  .centerRight,
                                                              colors: [
                                                                Colors
                                                                    .deepOrange
                                                                    .withAlpha(0),
                                                                Colors
                                                                    .deepOrange
                                                                    .shade900
                                                                    .withAlpha(128),
                                                              ],
                                                            ),
                                                          ),
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                            width / 90,
                                                            width / 90,
                                                            width / 40,
                                                            width / 90,
                                                          ),
                                                          child: Text(
                                                            // categoryData
                                                            //         .isEmpty
                                                            //     ? (controller.allList[index]['category'] ??
                                                            //         "N/A")
                                                            //     : categoryData
                                                            //             .first[
                                                            //                 'category']
                                                            //             .toString()
                                                            //             .trim()
                                                            //             .isEmpty
                                                            //         ? 'N/A'
                                                            //         : controller.allList[index]
                                                            //                 [
                                                            //                 'category'] ??
                                                            //             "N/A",
                                                            homeController.allList[index]
                                                                            [
                                                                            'category'] ==
                                                                        null ||
                                                                    homeController
                                                                        .allList[
                                                                            index]
                                                                            [
                                                                            'category']
                                                                        .toString()
                                                                        .trim()
                                                                        .isEmpty
                                                                ? 'Category ${ConstantString.naLabel}'
                                                                : homeController
                                                                    .allList[
                                                                        index][
                                                                        'category']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                                color: Colors
                                                                    .deepOrange,
                                                                letterSpacing:
                                                                    2),
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
                                                          // categoryData
                                                          //         .isEmpty
                                                          //     ? (homeController.allList[index]['category'] ??
                                                          //         "N/A")
                                                          //     : categoryData
                                                          //             .first[
                                                          //                 'category']
                                                          //             .toString()
                                                          //             .trim()
                                                          //             .isEmpty
                                                          //         ? 'N/A'
                                                          //         : homeController.allList[index]
                                                          //                 [
                                                          //                 'category'] ??
                                                          //             "N/A",
                                                          homeController.allList[
                                                                              index]
                                                                          [
                                                                          'subcategory'] ==
                                                                      null ||
                                                                  homeController
                                                                      .allList[
                                                                          index]
                                                                          [
                                                                          'subcategory']
                                                                      .toString()
                                                                      .trim()
                                                                      .isEmpty
                                                              ? 'Sub Category ${ConstantString.naLabel}'
                                                              : homeController
                                                                  .allList[
                                                                      index][
                                                                      'subcategory']
                                                                  .toString(),
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .grey.shade600,
                                                          ),
                                                          // maxLines: 1,
                                                          // overflow:
                                                          //     TextOverflow
                                                          //         .ellipsis,
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
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postBusinessDashboardApi("0");
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.businessList.isEmpty
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
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: homeController.businessList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      if (homeController.businessList[index]
                                                  ['member_count'] ==
                                              null ||
                                          homeController.businessList[index]
                                                  ['member_count'] ==
                                              0) {
                                        EasyLoading.showError(
                                          ConstantString
                                              .businessServiceMembersEmptyMsg,
                                        );
                                      } else {
                                        Get.to(
                                          () => UserListScreen(
                                            categoryId: (homeController
                                                            .businessList[index]
                                                        ['id'] ??
                                                    "")
                                                .toString(),
                                            categoryName: (homeController
                                                            .businessList[index]
                                                        ['category'] ??
                                                    "")
                                                .toString(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 280.0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xffF6F5FA),
                                                    width: 2,
                                                  ),
                                                  shape: BoxShape.circle),
                                              child: AppImageAsset(
                                                image:
                                                    "${ConstantString.categoriesImgUrlPath}${homeController.businessList[index]['category_image']}",
                                                isFile: false,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                // color: (homeController.businessList[
                                                // index]['member_count'] ==
                                                //     null ||
                                                //     homeController.businessList[
                                                //     index][
                                                //     'member_count'] ==
                                                //         0)
                                                //     ? ConstantColor
                                                //         .grayColor
                                                //     : null,
                                                // width: 80,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            homeController.businessList[index]
                                                    ['category'] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: (homeController.businessList[
                                                                  index][
                                                              'member_count'] ==
                                                          null ||
                                                      homeController.businessList[
                                                                  index][
                                                              'member_count'] ==
                                                          0)
                                                  ? ConstantColor.grayColor
                                                  : ConstantColor.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postBusinessDashboardApi("1");
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.servicesList.isEmpty
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
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                  ),
                                  itemCount: homeController.servicesList.length,
                                  padding: const EdgeInsets.only(bottom: 80),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      // Get.to(() => ServicesScreen(
                                      //       categoryId: homeController.servicesList[index]['id'].toString(),
                                      //       title: homeController.servicesList[index]['category'].toString(),
                                      //     ));
                                      if (homeController.servicesList[index]
                                                  ['member_count'] ==
                                              null ||
                                          homeController.servicesList[index]
                                                  ['member_count'] ==
                                              0) {
                                        EasyLoading.showError(
                                          ConstantString
                                              .businessServiceMembersEmptyMsg,
                                        );
                                      } else {
                                        Get.to(() => UserListScreen(
                                              categoryId:
                                                  (homeController.servicesList[
                                                              index]['id'] ??
                                                          "")
                                                      .toString(),
                                              categoryName: (homeController
                                                              .servicesList[
                                                          index]['category'] ??
                                                      "")
                                                  .toString(),
                                            ));
                                      }
                                    },
                                    child: Container(
                                      height: 280.0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        const Color(0xffF6F5FA),
                                                    width: 2,
                                                  ),
                                                  shape: BoxShape.circle),
                                              child: AppImageAsset(
                                                image:
                                                    "${ConstantString.categoriesImgUrlPath}${homeController.servicesList[index]['category_image']}",
                                                isFile: false,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                // color: homeController.servicesList[
                                                //                 index][
                                                //             'member_count'] ==
                                                //         0
                                                //     ? ConstantColor
                                                //         .grayColor
                                                //         .withOpacity(0.1)
                                                //     : null,
                                                // width: 80,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            homeController.servicesList[index]
                                                    ['category'] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: (homeController.servicesList[
                                                                  index][
                                                              'member_count'] ==
                                                          null ||
                                                      homeController.servicesList[
                                                                  index][
                                                              'member_count'] ==
                                                          0)
                                                  ? ConstantColor.grayColor
                                                  : ConstantColor.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> raiseInquiryDialog(BuildContext context,
      HomeController controller,
      double height,
      double width) async {

    await controller.postCategoriesApi();
    controller.categorySelect.value = {};
    controller.subCategorySelect.value = {};
    controller.priorityTypeSelect.value = "";
    controller.subCategoryList.value = [];
    controller.inquiryController.value.clear();
    List categoryList = List.from(controller.categoryList);

    categoryList.removeWhere(
      (element) =>
          element['category'].toString().trim().toLowerCase() ==
          'Not in List'.trim().toLowerCase(),
    );

    if (!context.mounted) return;
    final dialogContext = context;

    return showDialog(
      context: dialogContext,
      builder: (context) => Obx(
        () => Dialog(
          backgroundColor: ConstantColor.whiteColor,
          surfaceTintColor: ConstantColor.whiteColor,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Get.back();
                        },
                        child: Image.asset(
                          "assets/icons/icon_close.png",
                          height: 25,
                          width: 25,
                        ),
                      )
                    ],
                  ),
                  Text(
                    "Raise Inquiry",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                  SizedBox(height: height * 0.05),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Category",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ConstantColor.blackColor,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: ConstantColor.bgColor,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xffDDDDDD),
                            )),
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        child: DropdownButton(
                          dropdownColor: ConstantColor.bgColor,
                          value:
                              controller.categorySelect['category'] == null ||
                                      controller.categorySelect['category']
                                          .toString()
                                          .trim()
                                          .isEmpty
                                  ? null
                                  : controller.categorySelect['category']
                                      .toString(),
                          padding: EdgeInsets.zero,
                          onChanged: (dynamic newValue) {
                            for (int i = 0; i < categoryList.length; i++) {
                              if (categoryList[i]['category'] == newValue) {
                                debugPrint('Data: ${categoryList[i]}');
                                controller.categorySelect.value =
                                    categoryList[i] ?? {};
                                controller.postSubCategoriesApi(
                                    controller.categorySelect['id'].toString());
                              }
                            }
                            controller.isAddLoading.value = true;
                          },
                          isExpanded: true,
                          items: categoryList.map(
                            (val) {
                              return DropdownMenuItem(
                                value: val['category'] ?? {},
                                child: Text(
                                  val['category'] ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ConstantColor.blackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                ),
                              );
                            },
                          ).toList(),
                          underline: const SizedBox(),
                          hint: Text(
                            "Select Category",
                            style: TextStyle(
                              fontSize: 16,
                              color: ConstantColor.grayColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down_sharp,
                            size: 25,
                            color: ConstantColor.blackColor,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        "Sub-Category",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ConstantColor.blackColor,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: ConstantColor.bgColor,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: const Color(0xffDDDDDD),
                            )),
                        padding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 10,
                        ),
                        child: DropdownButton(
                          dropdownColor: ConstantColor.bgColor,
                          value: controller.subCategorySelect['subcategory'] ==
                                      null ||
                                  controller.subCategorySelect['subcategory']
                                      .toString()
                                      .trim()
                                      .isEmpty
                              ? null
                              : controller.subCategorySelect['subcategory']
                                  .toString(),
                          padding: EdgeInsets.zero,
                          isExpanded: true,
                          onChanged: (dynamic newValue) {
                            for (int i = 0;
                                i < controller.subCategoryList.length;
                                i++) {
                              if (controller.subCategoryList[i]
                                      ['subcategory'] ==
                                  newValue) {
                                debugPrint('subCategoryList : ${controller.subCategoryList[i]}');
                                controller.subCategorySelect.value =
                                    controller.subCategoryList[i] ?? {};
                              }
                            }
                          },
                          hint: Text(
                            "Select SubCategory",
                            style: TextStyle(
                              fontSize: 16,
                              color: ConstantColor.grayColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          items: controller.subCategoryList.map(
                            (val) {
                              return DropdownMenuItem(
                                value: val['subcategory'] ?? "",
                                child: Text(
                                  val['subcategory'] ?? "",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: ConstantColor.blackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                ),
                              );
                            },
                          ).toList(),
                          underline: const SizedBox(),
                          icon: Icon(
                            Icons.arrow_drop_down_sharp,
                            size: 25,
                            color: ConstantColor.blackColor,
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Text(
                        "Priority type",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ConstantColor.blackColor,
                        ),
                      ),
                      SizedBox(height: height * 0.01),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.priorityTypeSelect.value = "Urgent";
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xffABAAAF),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      controller.priorityTypeSelect.value ==
                                              "Urgent"
                                          ? "assets/icons/icon_select_radio.png"
                                          : "assets/icons/icon_unselect_radio.png",
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "Urgent",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: controller
                                                    .priorityTypeSelect.value ==
                                                "Urgent"
                                            ? ConstantColor.blackColor
                                            : ConstantColor.grayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: width * 0.02),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                controller.priorityTypeSelect.value = "General";
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(0xffABAAAF),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      controller.priorityTypeSelect.value ==
                                              "General"
                                          ? "assets/icons/icon_select_radio.png"
                                          : "assets/icons/icon_unselect_radio.png",
                                      height: 20,
                                      width: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      "General",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: controller
                                                    .priorityTypeSelect.value ==
                                                "General"
                                            ? ConstantColor.blackColor
                                            : ConstantColor.grayColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.03),
                      SizedBox(
                        height: 130,
                        child: TextFormField(
                          controller: controller.inquiryController.value,
                          onChanged: (value) {},
                          textInputAction: TextInputAction.newline,
                          maxLines: 5,
                          style: TextStyle(
                            fontSize: 16,
                            color: ConstantColor.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                          keyboardType: TextInputType.multiline,
                          cursorColor: ConstantColor.blackColor,
                          decoration: InputDecoration(
                            fillColor: ConstantColor.bgColor,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            hintText: "Other inquiry type here (optional)",
                            hintStyle: TextStyle(
                                fontSize: 16,
                                color: ConstantColor.grayColor,
                                fontWeight: FontWeight.w400),
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Color(0xffDDDDDD),
                                )),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Color(0xffDDDDDD),
                                )),
                            disabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Color(0xffDDDDDD),
                                )),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                  color: Color(0xffDDDDDD),
                                )),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Center(
                    child: AppButton(
                      onTap: () {
                        if (controller.categorySelect.isEmpty) {
                          ShowToast.showToast(
                            'Please Select Category',
                            showSuccess: false,
                          );
                        } else if (controller.subCategorySelect.isEmpty) {
                          ShowToast.showToast(
                            'Please Select Sub-Category',
                            showSuccess: false,
                          );
                        } else if (controller.priorityTypeSelect.isEmpty) {
                          ShowToast.showToast(
                            'Please Select Priority Type',
                            showSuccess: false,
                          );
                        } else {
                          var bodyParams = {
                            'category':
                                controller.categorySelect['id'].toString(),
                            'sub_category':
                                controller.subCategorySelect['id'].toString(),
                            'type':
                                controller.priorityTypeSelect.value == "Urgent"
                                    ? "0"
                                    : "1",
                            'enq_text': controller.inquiryController.value.text,
                          };
                          debugPrint('bodyParams $bodyParams');
                          controller.postCreateEnquiryApi(bodyParams);
                        }
                      },
                      isLoading: controller.isButtonLoading.value,
                      title: "Submit",
                      myWidth: Get.width / 2,
                      arrowShow: false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
