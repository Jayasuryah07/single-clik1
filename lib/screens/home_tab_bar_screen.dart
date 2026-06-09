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
import 'package:single_clik/controller/home_controller/profile_controller.dart';
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
    {"title": "Home", "image": "assets/icons/hm1.png"},
    {"title": "Received", "image": "assets/icons/rec.png"},
    {"title": "My Enquiries", "image": "assets/icons/sen.png"},
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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        homeController.selectTab.value = widget.selectTab ?? 0;
      }
    });
    if (homeController.userData.isNotEmpty) {
      if (homeController.userData['user_type'] != 2) {
        homeTabBarList[1] = {
          "title": "Join as",
          "image": "assets/icons/logo (1).png"
        };
        homeTabBarList[2] = {
          "title": "My Enquiries",
          "image": "assets/icons/sen.png"
        };
      } else {
        homeTabBarList[1] = {
          "title": "Received",
          "image": "assets/icons/rec.png"
        };
        homeTabBarList[2] = {
          "title": "Send Enquiry",
          "image": "assets/icons/sen.png"
        };
      }
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        getUserData();
      }
    });
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
              homeTabBarList[2] = {
                "title": "My Enquiries",
                "image": "assets/icons/sen.png"
              };
            });
          }
        } else {
          if (mounted) {
            setState(() {
              homeTabBarList[1] = {
                "title": "Received",
                "image": "assets/icons/rec.png"
              };
              homeTabBarList[2] = {
                "title": "Send Enquiry",
                "image": "assets/icons/sen.png"
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
                              final rawUrl = (homeController.allAdvPopUpSliderList[0]['slider_url'] ?? '').toString().trim();
                              if (rawUrl.isNotEmpty) {
                                Uri url = Uri.parse(rawUrl);
                                try {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                } catch (e) {
                                  ShowToast.showToast(
                                    'Could not launch URL',
                                    showSuccess: false,
                                  );
                                }
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
                                final rawUrl = (homeController.allAdvPopUpSliderList[index]['slider_url'] ?? '').toString().trim();
                                if (rawUrl.isNotEmpty) {
                                  Uri url = Uri.parse(rawUrl);
                                  try {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  } catch (e) {
                                    ShowToast.showToast(
                                      'Could not launch URL',
                                      showSuccess: false,
                                    );
                                  }
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
  ProfileController profileController = Get.put(ProfileController());
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: Obx(() {
            return AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: ConstantColor.primaryGradient,
                ),
              ),
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
                // ── Refresh button (all tabs, both user & business) ──────────────
                Obx(() {
                  final spinning = homeController.isFullRefreshing.value;
                  return Tooltip(
                    message: 'Refresh App',
                    child: IconButton(
                      icon: AnimatedRotation(
                        turns: spinning ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 800),
                        child: Icon(
                          Icons.refresh_rounded,
                          color: spinning
                              ? Colors.white54
                              : Colors.white,
                        ),
                      ),
                      onPressed: spinning
                          ? null
                          : () async {
                              await homeController.fullAppRefresh();
                            },
                    ),
                  );
                }),
                // ── Search button (home tab only) ─────────────────────────────────
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
              bottom: _buildTabBarForCurrentTab(),
            );
          }),
        ),
        bottomNavigationBar: Container(
  height: 65,
  decoration: BoxDecoration(
    gradient: ConstantColor.primaryGradient,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10 ),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(23),
        blurRadius: 10,
        spreadRadius: 10,
      ),
    ],
  ),
  child: ClipRRect(
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(10),
      topRight: Radius.circular(10),
    ),
    child: Container(
      color: const Color.fromARGB(0, 201, 59, 59), // Make the clipped area transparent to show gradient
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
                          EasyLoading.show(
                            status: ConstantString.pleaseWaitLabel,
                          );

                          // Call new API to check business profile status
                          final checkResult = await businessSignUpController.checkProfileBusinessProfileApi();
                          EasyLoading.dismiss();

                          if (checkResult['status'] == true) {
                            if (context.mounted) {
                              _showAlreadySubmittedDialog(context);
                            }
                          } else {
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
                          }
                        } else {
                          // Business user tapping Received tab — mark as seen
                          enquiriesReceivedController.markOpenEnquiriesAsSeen();
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
                              ? Obx(() {
                                  final newCount = enquiriesReceivedController.newOpenCount.value;
                                  final unreadCount = homeController.receivedUnreadCount.value;
                                  // Show badge if either new enquiries arrived or there are unread
                                  final badgeCount = newCount > 0 ? newCount : unreadCount;
                                  return badgeCount == 0
                                      ? SizedBox(
                                          height: 25,
                                          width: 25,
                                          child: Image.asset(
                                            homeTabBarList[index]['image'],
                                            color: homeController.selectTab.value == index
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
                                          ),
                                        )
                                      : badges.Badge(
                                          badgeContent: Text(
                                            badgeCount.toString(),
                                            style: TextStyle(
                                              color: ConstantColor.whiteColor,
                                              fontSize: 10,
                                            ),
                                          ),
                                          badgeStyle: const badges.BadgeStyle(
                                            badgeColor: Colors.red,
                                            padding: EdgeInsets.all(5),
                                          ),
                                          child: SizedBox(
                                            height: 25,
                                            width: 25,
                                            child: Image.asset(
                                              homeTabBarList[index]['image'],
                                              color: homeController.selectTab.value == index
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.6),
                                            ),
                                          ),
                                        );
                                })
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
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
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
                                                  ? Colors.white
                                                  : Colors.white.withOpacity(0.6),
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
                                                ? Colors.white
                                                : Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                          const SizedBox(height: 2),
                          Text(
                            homeTabBarList[index]['title'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: homeController.selectTab.value == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.6),
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
),
      ),
    );
  }

  PreferredSizeWidget _buildTabBarForCurrentTab() {
    final int selectTab = homeController.selectTab.value;
    if (selectTab == 0) {
      return TabBar(
        controller: homeController.tabController,
        indicatorColor: ConstantColor.whiteColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 4,
        onTap: (value) async {
          homeController.tabIndex.value = value;
          homeController.isSearchOpen.value = false;
          if (value == 0) {
            await homeController.getSentEnquiriesUnreadCount("1");
          } else if (value == 1) {
            await homeController.getSentEnquiriesUnreadCount("1");
          } else if (value == 2) {
            await homeController.getSentEnquiriesUnreadCount("1");
          }
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
      );
    } else if (selectTab == 1) {
      return TabBar(
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
      );
    } else {
      return TabBar(
        controller: enquiriesSentController.tabController,
        indicatorColor: ConstantColor.whiteColor,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 4,
        onTap: (value) async {
          if (value == 0) {
            await enquiriesSentController.postSentApi("1", isAutoRefresh: false);
            await homeController.getSentEnquiriesUnreadCount("1");
          } else if (value == 1) {
            await enquiriesSentController.postSentApi("2", isAutoRefresh: false);
          }
        },
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Open",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: ConstantColor.whiteColor,
                  ),
                ),
                Obx(() {
                  if (enquiriesSentController.getUnreadCount() > 0) {
                    return Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        enquiriesSentController.getUnreadCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
              ],
            ),
          ),
          Tab(
            child: Text(
              "Closed",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: ConstantColor.whiteColor,
              ),
            ),
          ),
        ],
      );
    }
  }

  void _showAlreadySubmittedDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: EdgeInsets.symmetric(horizontal: Get.width / 15),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ConstantColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pending_actions_rounded,
                    color: ConstantColor.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Request Already Submitted",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Your business account request is already submitted. Please wait for admin approval, or contact our support team for immediate assistance.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Get.back();
                          EasyLoading.show(status: 'Loading support...');
                          try {
                            final value =
                                await profileController.postDeveloperApi();
                            EasyLoading.dismiss();
                            if (value['code'] == 200) {
                              final phone =
                                  value['data']['company_mobile'] ?? '';
                              Uri url = Uri.parse('tel:+$phone');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                ShowToast.showToast(
                                    "Could not launch dialer",
                                    showSuccess: false);
                              }
                            }
                          } catch (e) {
                            EasyLoading.dismiss();
                            debugPrint(e.toString());
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstantColor.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Call Support"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}