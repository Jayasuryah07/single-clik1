import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/network_to_file_image.dart';
import 'package:single_clik/controller/auth_controller/business_sign_up_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/auth_screens/business_sign_up_page.dart';
import 'package:single_clik/screens/home_screens/enquiries_received_screens/enquiries_received_screen.dart';
import 'package:single_clik/screens/home_screens/enquiries_sent_screens/enquiries_sent_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/home_screen.dart';
import 'package:single_clik/widget/drawer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:url_launcher/url_launcher.dart';

import '../constants/show_toast.dart';
import '../controller/home_controller/enquiries_received_controller.dart';
import '../controller/home_controller/enquiries_sent_controller.dart';
import '../widget/app_image_assets.dart';

class HomeTabBarScreen extends StatefulWidget {
  final int? selectTab;

  const HomeTabBarScreen({
    super.key,
    this.selectTab = 0,
  });

  @override
  State<HomeTabBarScreen> createState() => HomeTabBarScreenState();
}

class HomeTabBarScreenState extends State<HomeTabBarScreen> {

  List homeTabBarList = [
    {"title": "Home", "image": "assets/icons/icon_home.png"},
    {"title": "Received", "image": "assets/icons/recevied_dr_icon.png"},
    {"title": "My Enquiries", "image": "assets/icons/my_enquiries_dr_icon.png"},
  ];

  HomeController homeController = Get.put(HomeController());
  EnquiriesReceivedController enquiriesReceivedController = Get.put(EnquiriesReceivedController());
  EnquiriesSentController enquiriesSentController = Get.put(EnquiriesSentController());

  List screenList = [
    const HomeScreen(),
    const EnquiriesReceivedScreen(),
    const EnquiriesSentScreen(),
  ];
  @override
  void initState() {
    homeController.selectTab.value = 0;
    if (homeController.userData.isNotEmpty && homeController.userData['user_type'] != 2) {
      homeTabBarList[1] = {
        "title": "Join as",
        "image": "assets/icons/logo (1).png"
      };
    }
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async {
    await homeController.postFetchProfileApi().then(
      (value) async {
        debugPrint(homeController.userData['user_type'].toString());
        if (homeController.userData['user_type'] != 2) {
          if (mounted) {
            setState(() {
              homeTabBarList[1] = {
                "title": "Join as",
                "image": "assets/icons/logo (1).png"
              };
            });
          }
        } else {
          if (mounted) {
            setState(() {
              homeTabBarList[1] = {
                "title": "Received",
                "image": "assets/icons/recevied_dr_icon.png"
              };
            });
          }
        }

        debugPrint("list length${homeTabBarList.length}");

        if (homeController.selectTab.value == 0) {
          await openPopupSliderList();
          await homeController.postDashboardApi("");
          await homeController.postDashboardSliderApi("");
          await homeController.postDashboardAdvSliderApi();
          // await homeController.postBusinessDashboardApi("0");
          // await homeController.postBusinessDashboardApi("1");
          await homeController.getSentEnquiriesUnreadCount("1");
          await homeController.postCategoriesApi();
        }
      },
    );
  }

  Future<void> openPopupSliderList() async {
    await homeController.postDashboardAdvPopUpSliderApi().then((value) {
      if (homeController.allAdvPopUpSliderList.isNotEmpty) {

        if(!mounted) return;

        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: Get.width / 30,
              ),
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        Get.back();
                        await homeController.postBusinessDashboardApi("0");
                        await homeController.postBusinessDashboardApi("1");
                      },
                      child: Container(
                        height: Get.width / 12,
                        width: Get.width / 12,
                        decoration: BoxDecoration(
                          color: ConstantColor.whiteColor,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                          size: Get.width / 18,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Get.width / 30,
                  ),
                  homeController.allAdvPopUpSliderList.length == 1
                      ? SizedBox(
                          height: Get.height / 1.2,
                          child: GestureDetector(
                            onTap: () async {
                              Uri url = Uri.parse(
                                  (homeController.allAdvPopUpSliderList[0]
                                              ['slider_url'] ??
                                          '')
                                      .toString());
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                ShowToast.showToast(
                                  'Url ${ConstantString.notAvailableLabel}',
                                  showSuccess: false,
                                );
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: AppImageAsset(
                                image:
                                    "${ConstantString.sliderImgUrlPath}${homeController.allAdvPopUpSliderList[0]['slider_images']}",
                                isFile: false,
                                height: Get.height / 1.3,
                                width: Get.width / 1.1,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : CarouselSlider(
                          options: CarouselOptions(
                            height: Get.height / 1.2,
                            autoPlay: true,
                            viewportFraction: 1,
                            enlargeCenterPage: false,
                            autoPlayInterval: const Duration(seconds: 6),
                          ),
                          items: List.generate(
                            homeController.allAdvPopUpSliderList.length,
                            (index) => GestureDetector(
                              onTap: () async {
                                Uri url = Uri.parse(
                                    (homeController.allAdvPopUpSliderList[index]
                                                ['slider_url'] ??
                                            '')
                                        .toString());
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  ShowToast.showToast(
                                    'Url ${ConstantString.notAvailableLabel}',
                                    showSuccess: false,
                                  );
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: AppImageAsset(
                                  image:
                                      "${ConstantString.sliderImgUrlPath}${homeController.allAdvPopUpSliderList[index]['slider_images']}",
                                  isFile: false,
                                  height: Get.height / 1.3,
                                  width: Get.width / 1.1,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            );
          },
        );
      }
    });
  }

  BusinessSignUpController businessSignUpController =
      Get.put(BusinessSignUpController());
  RxBool searchClick = true.obs;
  RxBool showText = true.obs;

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    debugPrint('currentBackPressTime $currentBackPressTime $now');
    debugPrint('selectTab ${homeController.selectTab.value}');
    debugPrint('tabIndex ${homeController.tabIndex.value}');
    if (homeController.selectTab.value == 0 &&
        homeController.tabIndex.value == 0) {
      homeController.searchController.value.clear();
      homeController.searchProduct('');
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        ShowToast.showToast(
          'Press back again to exit',
          position: EasyLoadingToastPosition.bottom,
        );
        return Future.value(false);
      }
    } else {
      homeController.selectTab.value = 0;
      homeController.tabController.index = 0;
      homeController.update();
      return Future.value(false);
    }

    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Future.microtask(() async {
            final shouldPop = await onWillPop();
            if (shouldPop && context.mounted) {
              Navigator.of(context).maybePop();
            }
          });
        }
      },

      child: Scaffold(
        key: homeController.scaffoldKey,
        backgroundColor: Colors.white,
        body: Obx(
          () => screenList[homeController.selectTab.value],
        ),
        drawer: const AppDrawer(),
        appBar: AppBar(
          backgroundColor: ConstantColor.primary,
          leading: GestureDetector(
            onTap: () {
              homeController.scaffoldKey.currentState!.openDrawer();
            },
            child: Center(
              child: Image.asset(
                "assets/icons/icon_menu.png",
                height: 20,
                width: 20,
              ),
            ),
          ),
          actions: [
            Obx(() => homeController.selectTab.value == 0 &&
                    homeController.tabIndex.value == 0 &&
                    !homeController.isLoading.value
                ? IconButton(
                    icon: Icon(homeController.isSearchOpen.value ? Icons.close : Icons.search),
                    onPressed: () {
                      setState(() {
                        if (homeController.isSearchOpen.value) {
                          homeController.searchController.value.clear();
                          homeController.searchProduct("");
                        }
                        homeController.isSearchOpen.value = !homeController.isSearchOpen.value;
                      });
                    },
                  )
                : Container()),
          ],
          title: Obx(
            () => homeController.selectTab.value == 0 &&
                    homeController.tabIndex.value == 0 &&
                    !homeController.isLoading.value
                ?

                AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: homeController.isSearchOpen.value
                        ? SizedBox(
                          height: 35,
                          child: TextField(
                              key: ValueKey(1), // Unique key for animation
                              controller: homeController.searchController.value,
                              onChanged: (value) {
                                debugPrint('value on Change : $value');
                                homeController.searchProduct(value);
                              },
                              onSubmitted: (value) {
                                debugPrint('value on Change : $value');
                                homeController.searchProduct(value);
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 0, horizontal: 15),
                                hintText: "Search",
                                hintStyle: TextStyle(
                                    fontSize: 18,
                                    color: ConstantColor.grayColor,
                                    fontWeight: FontWeight.w400),
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(100.0),
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                  ),
                                ),
                              ),
                            ),
                        )
                        : Text('Single Clik',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: ConstantColor.whiteColor,
                            ),
                            key: ValueKey(2)),
                  )

                : Text(
                    homeController.selectTab.value == 0
                        ? "Single Clik"
                        : homeController.selectTab.value == 1
                            ? "Enquiries Received"
                            : "My Enquiries",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: ConstantColor.whiteColor,
                    ),
                  ),
          ),
          elevation: 0,
        ),
        bottomNavigationBar: Container(
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff555E58).withAlpha(23),
                // blurRadius: 0.1,
                blurRadius: 10,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: List.generate(
                    homeTabBarList.length,
                    (index) => Expanded(
                      child: InkWell(
                        onTap: () async {
                          homeController.isSearchOpen.value = false;
                          homeController.tabController.index = 0;
                          enquiriesReceivedController.tabController.index = 0;
                          enquiriesSentController.tabController.index = 0;
                          if (homeController.selectTab.value != 0) {
                            homeController.searchController.value.clear();
                            homeController.searchProduct('');
                          }
                          if (index == 1) {
                            if (homeController.userData['user_type'] != 2) {
                              if (homeController.userData['category'] != null &&
                                  homeController.userData['category']
                                      .toString()
                                      .trim()
                                      .isNotEmpty) {
                                EasyLoading.showError(
                                    ConstantString.alreadyJoinAsMsg);
                              } else {
                                EasyLoading.show(
                                  status: ConstantString.pleaseWaitLabel,
                                );
                                businessSignUpController.isButtonLoading.value =
                                    false;
                                businessSignUpController.txtFullName.value
                                    .clear();
                                businessSignUpController.txtCompanyName.value
                                    .clear();
                                businessSignUpController.txtMobileNo.value
                                    .clear();
                                businessSignUpController.txtEmailId.value
                                    .clear();
                                businessSignUpController.txtWhatsappNo.value
                                    .clear();
                                businessSignUpController.txtWebsite.value
                                    .clear();
                                businessSignUpController.txtAbout.value.clear();
                                businessSignUpController.txtArea.value.clear();
                                businessSignUpController.txtReferredCode.value
                                    .clear();
                                businessSignUpController.txtOtherCategory.value
                                    .clear();
                                businessSignUpController
                                    .txtOtherSubCategory.value
                                    .clear();
                                businessSignUpController
                                    .selectedProfileType.value = '';
                                businessSignUpController
                                    .selectedCategory.value = {};
                                businessSignUpController
                                    .selectedSubCategory.value = {};
                                String photoPath = await NetworkToFileImage
                                    .networkToFileImage
                                    .getNetworkToFileImage(
                                        url:
                                            '${ConstantString.userImgUrlPath}${homeController.userData['photo']}');
                                businessSignUpController.filePath.value =
                                    photoPath;
                                try {
                                  businessSignUpController
                                          .categoryDataList.value =
                                      await businessSignUpController
                                          .getCategoryDataApi();
                                  businessSignUpController
                                      .subCategoryDataList.value = [];
                                  EasyLoading.dismiss();
                                } on TimeoutException catch (error) {
                                  businessSignUpController
                                      .categoryDataList.value = [];
                                  businessSignUpController
                                      .subCategoryDataList.value = [];
                                  EasyLoading.dismiss();
                                  ShowToast.showToast(
                                    error.message.toString(),
                                    showSuccess: false,
                                  );
                                } on SocketException catch (error) {
                                  businessSignUpController
                                      .categoryDataList.value = [];
                                  businessSignUpController
                                      .subCategoryDataList.value = [];
                                  EasyLoading.dismiss();
                                  ShowToast.showToast(
                                    error.message.toString(),
                                    showSuccess: false,
                                  );
                                } catch (error) {
                                  businessSignUpController
                                      .categoryDataList.value = [];
                                  businessSignUpController
                                      .subCategoryDataList.value = [];
                                  debugPrint(error.toString());
                                  EasyLoading.dismiss();
                                  ShowToast.showToast(
                                    'Something went wrong.',
                                    showSuccess: false,
                                  );
                                }
                                EasyLoading.dismiss();
                                 await Get.to(
                                   () => const BusinessSignUpPage(),
                                 );
                                 await getUserData();
                              }
                            } else {
                              homeController.selectTab.value = index;
                              // setState(() {});
                            }
                          } else {
                            homeController.selectTab.value = index;
                            // setState(() {});
                          }
                          if (homeController.userData['user_type'] == 2) {
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          }
                        },
                        child: Container(
                          width: Get.width,
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              index == 1 && homeController.userData['user_type'] == 2
                                  ? homeController.receivedUnreadCount.value.toString() == "0"
                                      ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: Image.asset(
                                            homeTabBarList[index]['image'],
                                            color: homeController
                                                        .selectTab.value ==
                                                    index
                                                ? ConstantColor.primary
                                                : ConstantColor.grayColor,
                                          ),
                                        )
                                      : Obx(() => badges.Badge(
                                            badgeContent: Text(
                                              homeController
                                                  .receivedUnreadCount.value
                                                  .toString(),
                                              style: TextStyle(
                                                color: ConstantColor.whiteColor,
                                                fontSize: 10,
                                              ),
                                            ),
                                            child: SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: Image.asset(
                                                homeTabBarList[index]['image'],
                                                color: homeController
                                                            .selectTab.value ==
                                                        index
                                                    ? ConstantColor.primary
                                                    : ConstantColor.grayColor,
                                              ),
                                            ),
                                          ))
                                  : index == 2
                                      ? homeController.pendingOpenInquiriesCount
                                                  .value
                                                  .toString() ==
                                              "0"
                                          ? SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: Image.asset(
                                                homeTabBarList[index]['image'],
                                                color: homeController
                                                            .selectTab.value ==
                                                        index
                                                    ? ConstantColor.primary
                                                    : ConstantColor.grayColor,
                                              ),
                                            )
                                          : badges.Badge(
                                              badgeContent: Obx(
                                                () => Text(
                                                  homeController
                                                      .pendingOpenInquiriesCount
                                                      .value
                                                      .toString(),
                                                  style: TextStyle(
                                                    color: ConstantColor
                                                        .whiteColor,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              child: SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: Image.asset(
                                                  homeTabBarList[index]
                                                      ['image'],
                                                  color: homeController
                                                              .selectTab
                                                              .value ==
                                                          index
                                                      ? ConstantColor.primary
                                                      : ConstantColor.grayColor,
                                                ),
                                              ),
                                            )
                                      : SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: Image.asset(
                                            homeTabBarList[index]['image'],
                                            color: index == 1 &&
                                                    homeController.userData[
                                                            'user_type'] !=
                                                        2
                                                ? null
                                                : homeController
                                                            .selectTab.value ==
                                                        index
                                                    ? ConstantColor.primary
                                                    : ConstantColor.grayColor,
                                          ),
                                        ),
                              const SizedBox(height: 2),
                              Text(
                                homeTabBarList[index]['title'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: homeController.selectTab.value == index
                                      ? ConstantColor.primary
                                      : ConstantColor.grayColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

}
