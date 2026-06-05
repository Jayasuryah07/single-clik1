import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/controller/home_controller/profile_controller.dart';
import 'package:single_clik/screens/auth_screens/business_sign_up_page.dart';
import 'package:single_clik/screens/auth_screens/mobile_number_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/drawer_screens/about_us_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/drawer_screens/feedback_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/drawer_screens/notification_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/drawer_screens/profile_screen.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../constants/constant_string.dart';
import '../constants/network_to_file_image.dart';
import '../controller/auth_controller/business_sign_up_controller.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => AppDrawerState();
}

class AppDrawerState extends State<AppDrawer> {
  // Map? userData = {};
  String versionCode = "";
  HomeController homeController = Get.put(HomeController());
  ProfileController profileController = Get.put(ProfileController());
  BusinessSignUpController businessSignUpController =
  Get.put(BusinessSignUpController());

  @override
  void initState() {
    userDataGet();
    super.initState();
  }

  Future<void> userDataGet() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionCode = packageInfo.version;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;

    return Drawer(
      child: SingleChildScrollView(
        child: Obx(
              () => Column(
            children: [
              SizedBox(height: height * 0.07),
              ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: AppImageAsset(
                  image:
                  "${ConstantString.userImgUrlPath}${homeController.userData['photo']}",
                  isFile: false,
                  cache: true,
                  fit: BoxFit.cover,
                  height: 100,
                  width: 100,
                ),
              ),
              SizedBox(height: height * 0.02),
              Text(
                (homeController.userData['name'] ?? ""),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ConstantColor.blackColor,
                ),
              ),
              Divider(color: ConstantColor.blackColor, thickness: 1.2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    drawerButton(
                      icon: "assets/icons/home_dr_icon.png",
                      title: "Home",
                      padding: 4,
                      onTap: () {
                        homeController.selectTab.value = 0;
                        Get.back();
                        // Get.offAll(() => HomeTabBarScreen());
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/profile_dr_icon.png",
                      title: "My Profile",
                      padding: 4,
                      onTap: () {
                        ProfileController profileController = Get.put(ProfileController());
                        profileController.postFetchProfileApi();
                        Get.back();
                        Get.to(() => const ProfileScreen())!
                            .then((value) => null);
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/my_enquiries_dr_icon.png",
                      title: "My Enquiries",
                      padding: 4,
                      onTap: () {
                        homeController.selectTab.value = 2;
                        Get.back();
                        // Get.offAll(() => HomeTabBarScreen(selectTab: 2));
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: homeController.userData['user_type'] != 2
                          ? "assets/icons/logo.svg"
                          : "assets/icons/recevied_dr_icon.png",
                      title: homeController.userData['user_type'] != 2
                          ? "Join as a Seller"
                          : "Received Enquiries",
                      padding: 4,
                      onTap: () async {
                        Get.back();
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
                            // businessSignUpController
                            //     .isButtonLoading.value = false;
                            businessSignUpController.txtFullName.value.clear();
                            businessSignUpController.txtCompanyName.value
                                .clear();
                            businessSignUpController.txtMobileNo.value.clear();
                            businessSignUpController.txtEmailId.value.clear();
                            businessSignUpController.txtWhatsappNo.value
                                .clear();
                            businessSignUpController.txtWebsite.value.clear();
                            businessSignUpController.txtAbout.value.clear();
                            businessSignUpController.txtArea.value.clear();
                            businessSignUpController.txtReferredCode.value
                                .clear();
                            businessSignUpController.txtOtherCategory.value
                                .clear();
                            businessSignUpController.txtOtherSubCategory.value
                                .clear();
                            businessSignUpController.selectedProfileType.value =
                            '';
                            businessSignUpController.selectedCategory.value =
                            {};
                            businessSignUpController.selectedSubCategory.value =
                            {};
                            String photoPath = await NetworkToFileImage
                                .networkToFileImage
                                .getNetworkToFileImage(
                                url:
                                '${ConstantString.userImgUrlPath}${homeController.userData['photo']}');
                            businessSignUpController.filePath.value = photoPath;
                            try {
                              businessSignUpController.categoryDataList.value =
                              await businessSignUpController
                                  .getCategoryDataApi();
                              businessSignUpController
                                  .subCategoryDataList.value = [];
                              EasyLoading.dismiss();
                            } on TimeoutException catch (error) {
                              businessSignUpController.categoryDataList.value =
                              [];
                              businessSignUpController
                                  .subCategoryDataList.value = [];
                              EasyLoading.dismiss();
                              ShowToast.showToast(
                                error.message.toString(),
                                showSuccess: false,
                              );
                            } on SocketException catch (error) {
                              businessSignUpController.categoryDataList.value =
                              [];
                              businessSignUpController
                                  .subCategoryDataList.value = [];
                              EasyLoading.dismiss();
                              ShowToast.showToast(
                                error.message.toString(),
                                showSuccess: false,
                              );
                            } catch (error) {
                              businessSignUpController.categoryDataList.value =
                              [];
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
                            Get.to(
                              BusinessSignUpPage(),
                            );
                          }
                        } else {
                          homeController.selectTab.value = 1;
                          // Get.offAll(() => HomeTabBarScreen(selectTab: 1));
                        }
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/reward_dr_icon.png",
                      title: "Reward Points",
                      textColor: ConstantColor.grayColor,
                      padding: 4,
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/notification_dr_icon.png",
                      title: "Notification",
                      padding: 4,
                      onTap: () {
                        Get.back();
                        Get.to(() => const NotificationScreen());
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/feedback_dr_icon.png",
                      title: "Feedback",
                      padding: 4,
                      onTap: () {
                        Get.back();
                        Get.to(() => const FeedbackScreen());
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/about_us_dr_icon.png",
                      title: "About Us",
                      padding: 4,
                      onTap: () async {
                        EasyLoading.show(
                          status: ConstantString.pleaseWaitLabel,
                        );
                        try {
                          String path = await NetworkToFileImage
                              .networkToFileImage
                              .getNetworkToFileImage(
                            url: ConstantString.aboutUsBGPath,
                          );
                          profileController.aboutUsBGImgFilePath.value = path;
                        } catch (error) {
                          debugPrint('Error : $error');
                        }
                        EasyLoading.dismiss();
                        Get.back();
                        Get.to(() => const AboutUsScreen());
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    drawerButton(
                      icon: "assets/icons/logout_dr_icon.png",
                      title: "Logout",
                      padding: 4,
                      onTap: () async {
                        areYouSureWantAlertDialog(
                          context,
                          title: 'Log out now?',
                          description: 'Are you sure you want to log out?',
                          onPressed: () async {
                            Get.back();
                            await SharPreferences.clearSharPreference();
                            Get.offAll(() => const MobileNumberScreen());
                          },
                        );
                      },
                    ),
                    Divider(color: ConstantColor.grayColor, thickness: 1),
                    SizedBox(height: height * 0.03),
                    Text(
                      "Version : $versionCode",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: ConstantColor.grayColor,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  InkWell drawerButton(
      {String? icon,
        String? title,
        Function()? onTap,
        double? padding,
        Color? textColor}) {

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: padding ?? 10),
        child: Row(
          children: [
            icon.toString().contains(".svg")
                ? SvgPicture.asset(
              icon ?? "",
              height: 25,
              width: 25,
              colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            )
                : AppImageAsset(
              image: icon ?? "",
              isFile: false,
              height: 25,
              width: 25,
              color: textColor,
            ),
            const SizedBox(width: 15),
            Flexible(
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? ConstantColor.primary,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  void areYouSureWantAlertDialog(BuildContext context, {
    required String title,
    required String description,
    required void Function() onPressed,}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          actionsPadding: EdgeInsets.symmetric(
              horizontal: Get.width * 0.02, vertical: Get.height * 0.01),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ConstantColor.primary,
                        fontSize: Get.width * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Get.height * 0.015,
              ),
              Text(
                description,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: ConstantColor.blackColor,
                  fontSize: Get.width * 0.045,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantColor.whiteColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: ConstantColor.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: Get.width * 0.02,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ConstantColor.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6))),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: ConstantColor.whiteColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future logoutDialog(BuildContext context, double height, double width) {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
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
                SizedBox(height: height * 0.02),
                Text(
                  "Are You sure want to log out ?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: ConstantColor.blackColor,
                  ),
                ),
                SizedBox(height: height * 0.03),
                SizedBox(
                  height: 58,
                  width: width / 1.8,
                  child: AppButton(
                    onTap: () async {
                      await SharPreferences.clearSharPreference();
                      Get.offAll(() => const MobileNumberScreen());
                    },
                    title: "Logout",
                  ),
                ),
                SizedBox(height: height * 0.02),
                /*  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        "Delete My Account ?? ",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ConstantColor.grayColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        deleteDialog(context, height, width);
                      },
                      child:  Text(
                        "Click Here",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:  ConstantColor.primary,
                        ),
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future deleteDialog(BuildContext context, double height, double width) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
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
              SizedBox(height: height * 0.02),
              Text(
                "Are you sure you want to delete your account? This will permanently erase your account.",
                style: TextStyle(
                  fontSize: Get.width*0.04,
                  fontWeight: FontWeight.w600,
                  color: ConstantColor.blackColor,
                ),
              ),
              SizedBox(height: height * 0.03),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => postDeleteProfileApi(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Delete"),
                    ),
                  ),
                  SizedBox(width: Get.width*0.04,),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      child:  Text("Cancel",style: TextStyle(color: Colors.black,),),
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
            ],
          ),
        ),
      ),
    ),
  );
}

Future postDeleteProfileApi() async {
  try {
    final request =
    http.MultipartRequest('POST', Uri.parse(API.deleteProfile));
    request.headers.addAll({
      'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
    });
    var res = await request.send();
    var responseDone = await http.Response.fromStream(res);

    if (res.statusCode == 200) {
      final responseData = json.decode(responseDone.body);
      debugPrint(responseData.toString());
      if (responseData['code'] == 200) {
        await SharPreferences.clearSharPreference();
        Get.offAll(() => const MobileNumberScreen());
        ShowToast.showToast(
          responseData['msg'] ?? ConstantString.dataDeletedSuccessfullyMsg,
          showSuccess: true,
        );
      } else {
        ShowToast.showToast(
          responseData['msg'] ?? ConstantString.somethingWantWrongMsg,
          showSuccess: false,
        );
      }
    } else {
      ShowToast.showToast(
        ConstantString.somethingWantWrongMsg,
        showSuccess: false,
      );
    }
  } on TimeoutException catch (e) {
    ShowToast.showToast(
      e.message.toString(),
      showSuccess: false,
    );
  } on SocketException catch (e) {
    ShowToast.showToast(
      e.message.toString(),
      showSuccess: false,
    );
  } on Error catch (e) {
    ShowToast.showToast(
      ConstantString.somethingWantWrongMsg,
      showSuccess: false,
    );
    debugPrint(e.toString());
  }
}