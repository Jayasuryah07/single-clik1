import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/controller/home_controller/profile_controller.dart';
import 'package:single_clik/screens/home_screens/home_screens/drawer_screens/update_profile_screen.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/show_toast.dart';
import '../../../../controller/home_controller/update_profile_controller.dart';
import '../../../../widget/app_text_field.dart';
import '../../../../widget/drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  HomeController homeController = Get.put(HomeController());
  ProfileController profileController = Get.put(ProfileController());
  UpdateProfileController updateProfileController = Get.put(UpdateProfileController());

  RxBool businessLogin = true.obs;

  @override
  void initState() {
    // TODO: implement initState
    businessLogin.value = homeController.userData['user_type'] == 2;
    debugPrint(businessLogin.value.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
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
          "Profile",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ConstantColor.whiteColor,
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(15.0),
      //   child:
      // ),
      body: Obx(
        () => profileController.isLoading.value
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.03),
                !businessLogin.value
                    ? SizedBox(
                  height: Get.width / 2,
                  width: Get.width,
                  child: Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Container(
                            height: Get.width / 2.5,
                            width: Get.width / 2.5,
                            decoration: BoxDecoration(
                              color: const Color(0xffFFF0E9),
                              borderRadius:
                              BorderRadius.circular(7),
                            ),
                            child: profileController
                                .croppedProfileFile!.value.path !=
                                ""
                                ? AppImageAsset(
                              image: profileController
                                  .croppedProfileFile!.value.path
                                  .contains("cache")
                                  ? profileController
                                  .croppedProfileFile!.value.path
                                  : "${ConstantString.userImgUrlPath}${profileController.filePath}",
                              isFile: profileController
                                  .croppedProfileFile!.value.path
                                  .contains("cache"),
                              fit: BoxFit.cover,
                              height: 100,
                              width: 100,
                            )
                                : Center(
                              child: Image.asset(
                                "assets/icons/icon_camera.png",
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                            if(image != null){
                              profileController.cropImage(image);

                            }

                          },
                          child: Container(
                            height: Get.width / 10,
                            width: Get.width / 1.8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ConstantColor.primary,
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.photo_rounded,
                              color: ConstantColor.whiteColor,
                              size: Get.width / 15,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ) : Center(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ConstantColor.primary,
                        width: 4,
                      ),
                      shape: BoxShape.circle,
                    ),
                    // padding: EdgeInsets.all(Get.width / 100),
                    child: ClipOval(
                      // borderRadius: BorderRadius.circular(1000),
                      child: AppImageAsset(
                        image:
                        "${ConstantString.userImgUrlPath}${profileController.profileMap['photo']}",
                        isFile: false,
                        cache: true,
                        fit: BoxFit.cover,
                        height: Get.width / 3,
                        width: Get.width / 3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Center(
                  child: Text(
                    "${profileController.profileMap['name'] != null && profileController.profileMap['name'].toString().trim().isNotEmpty ? profileController.profileMap['name'] : 'Name ${ConstantString.notAvailableLabel}'}",
                    style: TextStyle(
                      fontSize: Get.width*0.055,
                      fontWeight: FontWeight.w600,
                      color: ConstantColor.primary,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.01),
                Row(
                  children: [
                    !businessLogin.value
                        ? const SizedBox()
                        : Expanded(
                      child: SizedBox(
                        //height: Get.height*0.04,
                        child: AppButton(
                          borderRadius: BorderRadius.circular(0),
                          onTap: () {
                            if (homeController.userData['user_type'] == 1) {
                              if (homeController.userData['category'] != null &&
                                  homeController.userData['category'].toString().trim().isNotEmpty) {
                                // EasyLoading.showError(
                                //     ConstantString.alreadyJoinAsMsg);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: Get.width / 30,
                                      ),
                                      child: Padding(
                                        padding:
                                        EdgeInsets.all(width / 30),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisSize:
                                          MainAxisSize.min,
                                          children: [
                                            Center(
                                              child: Text(
                                                ConstantString
                                                    .alreadyJoinAsMsg,
                                                textAlign:
                                                TextAlign.center,
                                                style: TextStyle(
                                                  color: ConstantColor
                                                      .primary,
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                                height: height * 0.06),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: AppButton(
                                                    title: "Cancel",
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        3),
                                                    onTap: () =>
                                                        Get.back(),
                                                    buttonColor:
                                                    ConstantColor
                                                        .whiteColor,
                                                    buttonTextColor:
                                                    ConstantColor
                                                        .primary,
                                                    arrowShow: false,
                                                  ),
                                                ),
                                                SizedBox(
                                                    width:
                                                    width * 0.03),
                                                Expanded(
                                                  child: Obx(
                                                        () => AppButton(
                                                      title: "Call us",
                                                      onTap: () async {
                                                        profileController
                                                            .isButtonLoading
                                                            .value = true;
                                                        await profileController
                                                            .postDeveloperApi()
                                                            .then(
                                                                (value) async {
                                                              if (value[
                                                              'code'] ==
                                                                  200) {
                                                                Uri url = Uri
                                                                    .parse(
                                                                    'tel:+${value['data']['company_mobile'] ?? ''}');
                                                                if (await canLaunchUrl(
                                                                    url)) {
                                                                  profileController
                                                                      .isButtonLoading
                                                                      .value = false;
                                                                  Get.back();
                                                                  await launchUrl(
                                                                      url);
                                                                } else {
                                                                  profileController
                                                                      .isButtonLoading
                                                                      .value = false;
                                                                  Get.back();
                                                                  ShowToast
                                                                      .showToast(
                                                                    ConstantString
                                                                        .somethingWantWrongMsg,
                                                                    showSuccess:
                                                                    false,
                                                                  );
                                                                }
                                                              } else {
                                                                profileController
                                                                    .isButtonLoading
                                                                    .value = false;
                                                                Get.back();
                                                                ShowToast
                                                                    .showToast(
                                                                  value['msg'] ??
                                                                      ConstantString
                                                                          .somethingWantWrongMsg,
                                                                  showSuccess:
                                                                  false,
                                                                );
                                                              }
                                                            }).catchError(
                                                                (error) {
                                                              debugPrint('Error: $error');
                                                              profileController
                                                                  .isButtonLoading
                                                                  .value = false;
                                                              Get.back();
                                                              ShowToast
                                                                  .showToast(
                                                                error
                                                                    .toString(),
                                                                showSuccess:
                                                                false,
                                                              );
                                                            });
                                                      },
                                                      arrowShow: false,
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          3),
                                                      buttonColor:
                                                      ConstantColor
                                                          .primary,
                                                      buttonTextColor:
                                                      ConstantColor
                                                          .whiteColor,
                                                      isLoading: profileController
                                                          .isButtonLoading
                                                          .value,
                                                    ),
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
                              } else {
                                profileController.nameController.value.text =
                                    (profileController.profileMap['name'] ??
                                        '')
                                        .toString();
                                profileController.emailController.value.text =
                                    (profileController.profileMap['email'] ??
                                        '')
                                        .toString();
                                profileController.areaController.value.text =
                                    (profileController.profileMap['area'] ??
                                        '')
                                        .toString();
                                profileController.referredCodeController.value
                                    .text = (profileController.profileMap[
                                'referred_by_code'] ??
                                    '')
                                    .toString();
                                profileController.filePath.value =
                                    (profileController.profileMap['photo'] ??
                                        '')
                                        .toString();
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return Dialog(
                                      insetPadding:
                                      EdgeInsets.symmetric(
                                        horizontal: Get.width / 30,
                                      ),
                                      child: Padding(
                                        padding:
                                        EdgeInsets.all(width / 30),
                                        child: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            mainAxisSize:
                                            MainAxisSize.min,
                                            children: [
                                              Center(
                                                child: Text(
                                                  "Edit Profile",
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    color: ConstantColor
                                                        .blackColor,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.02),
                                              Center(
                                                child: SizedBox(
                                                  height:
                                                  Get.width / 2.5,
                                                  width:
                                                  Get.width / 2.5,
                                                  child: Stack(
                                                    children: [
                                                      Center(
                                                        child:
                                                        ClipRRect(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              7),
                                                          child:
                                                          Container(
                                                            height:
                                                            Get.width /
                                                                3,
                                                            width:
                                                            Get.width /
                                                                3,
                                                            decoration:
                                                            BoxDecoration(
                                                              color: const Color(
                                                                  0xffFFF0E9),
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  7),
                                                            ),
                                                            child: profileController.filePath.value !=
                                                                ""
                                                                ? AppImageAsset(
                                                              image: profileController.filePath.contains("cache")
                                                                  ? profileController.filePath.value
                                                                  : "${ConstantString.userImgUrlPath}${profileController.filePath}",
                                                              cache: true,
                                                              isFile:
                                                              profileController.filePath.contains("cache"),
                                                              // fit: BoxFit.cover,
                                                              // height: 100,
                                                              // width: 100,
                                                            )
                                                            // Image.file(
                                                            //         File(
                                                            //             businessSignUpController
                                                            //                 .filePath.value),
                                                            //         width: width,
                                                            //         height: height,
                                                            //         fit: BoxFit.fill,
                                                            //       )
                                                                : Center(
                                                              child:
                                                              Image.asset(
                                                                "assets/icons/icon_camera.png",
                                                                height: 30,
                                                                width: 30,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Align(
                                                        alignment: Alignment
                                                            .bottomRight,
                                                        child:
                                                        GestureDetector(
                                                          onTap:
                                                              () async {
                                                            final ImagePicker
                                                            picker =
                                                            ImagePicker();

                                                            final XFile?
                                                            image =
                                                            await picker.pickImage(
                                                                source:
                                                                ImageSource.gallery);
                                                            if (image !=
                                                                null) {
                                                              profileController
                                                                  .filePath
                                                                  .value = image.path;
                                                            }
                                                          },
                                                          child:
                                                          Container(
                                                            height:
                                                            Get.width /
                                                                10,
                                                            width:
                                                            Get.width /
                                                                10,
                                                            decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: ConstantColor
                                                                  .primary,
                                                            ),
                                                            alignment:
                                                            Alignment
                                                                .center,
                                                            child: Icon(
                                                              Icons
                                                                  .photo_rounded,
                                                              color: ConstantColor
                                                                  .whiteColor,
                                                              size:
                                                              Get.width /
                                                                  15,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.02),
                                              Text(
                                                "Name",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: ConstantColor
                                                      .grayColor,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                              // SizedBox(height: height * 0.02),
                                              appTextFormField(
                                                keyboardType:
                                                TextInputType.name,
                                                hintText:
                                                "Enter your full name",
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 0,
                                                    vertical: 5),
                                                controller: profileController
                                                    .nameController
                                                    .value,
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.03),
                                              Text(
                                                "Email ID",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: ConstantColor
                                                      .grayColor,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                              // SizedBox(height: height * 0.02),
                                              appTextFormField(
                                                keyboardType:
                                                TextInputType.name,
                                                hintText:
                                                "Enter your email id",
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 0,
                                                    vertical: 5),
                                                controller: profileController
                                                    .emailController
                                                    .value,
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.03),
                                              Text(
                                                "Area",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: ConstantColor
                                                      .grayColor,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                              // SizedBox(height: height * 0.02),
                                              appTextFormField(
                                                keyboardType:
                                                TextInputType.name,
                                                hintText:
                                                "Enter your area",
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 0,
                                                    vertical: 5),
                                                controller: profileController
                                                    .areaController
                                                    .value,
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.03),
                                              Text(
                                                "Referred Code",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: ConstantColor
                                                      .grayColor,
                                                  fontWeight:
                                                  FontWeight.w400,
                                                ),
                                              ),
                                              // SizedBox(height: height * 0.02),
                                              appTextFormField(
                                                keyboardType:
                                                TextInputType.name,
                                                hintText:
                                                "Enter your referred code",
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                contentPadding:
                                                const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 0,
                                                    vertical: 5),
                                                controller: profileController
                                                    .referredCodeController
                                                    .value,
                                              ),
                                              SizedBox(
                                                  height:
                                                  height * 0.06),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: AppButton(
                                                      title: "Cancel",
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          3),
                                                      onTap: () =>
                                                          Get.back(),
                                                      buttonColor:
                                                      ConstantColor
                                                          .whiteColor,
                                                      buttonTextColor:
                                                      ConstantColor
                                                          .primary,
                                                      arrowShow: false,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width:
                                                      width * 0.03),
                                                  Expanded(
                                                    child: Obx(
                                                          () => AppButton(
                                                        title: "Submit",
                                                        onTap:
                                                            () async {
                                                          profileController
                                                              .isButtonLoading
                                                              .value = true;
                                                          Map<String,
                                                              String>
                                                          bodyParams =
                                                          {
                                                            'name': profileController
                                                                .nameController
                                                                .value
                                                                .text
                                                                .trim(),
                                                            'email': profileController
                                                                .emailController
                                                                .value
                                                                .text
                                                                .trim(),
                                                            'area': profileController
                                                                .areaController
                                                                .value
                                                                .text
                                                                .trim(),
                                                            'referred_by_code': profileController
                                                                .referredCodeController
                                                                .value
                                                                .text
                                                                .trim(),
                                                            'profile_type':
                                                            (profileController.profileMap['profile_type'] ??
                                                                '0')
                                                                .toString(),
                                                          };
                                                          await profileController
                                                              .postUpdateProfileApi(
                                                              bodyParams,
                                                              profileController
                                                                  .filePath
                                                                  .value
                                                                  .trim())
                                                              .then(
                                                                  (value) async {
                                                                debugPrint('Value $value');
                                                                if (value[
                                                                'code'] ==
                                                                    200) {
                                                                  await profileController
                                                                      .postFetchProfileApi()
                                                                      .then(
                                                                          (_) {
                                                                        profileController
                                                                            .isButtonLoading
                                                                            .value = false;
                                                                        Get.back();
                                                                        ShowToast
                                                                            .showToast(
                                                                          value['msg'] ??
                                                                              ConstantString.dataUpdatedSuccessfullyMsg,
                                                                          showSuccess:
                                                                          true,
                                                                        );
                                                                      });
                                                                } else {
                                                                  profileController
                                                                      .isButtonLoading
                                                                      .value = false;
                                                                  Get.back();
                                                                  ShowToast
                                                                      .showToast(
                                                                    value['msg'] ??
                                                                        ConstantString.somethingWantWrongMsg,
                                                                    showSuccess:
                                                                    false,
                                                                  );
                                                                }
                                                              }).catchError(
                                                                  (error) {
                                                                debugPrint('Error: $error');
                                                                profileController
                                                                    .isButtonLoading
                                                                    .value = false;
                                                                Get.back();
                                                                ShowToast
                                                                    .showToast(
                                                                  error
                                                                      .toString(),
                                                                  showSuccess:
                                                                  false,
                                                                );
                                                              });
                                                        },
                                                        arrowShow:
                                                        false,
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            3),
                                                        buttonColor:
                                                        ConstantColor
                                                            .primary,
                                                        buttonTextColor:
                                                        ConstantColor
                                                            .whiteColor,
                                                        isLoading:
                                                        profileController
                                                            .isButtonLoading
                                                            .value,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            } else {
                              Get.to(() => UpdateProfileScreen(
                                  userData: Map<String, dynamic>.from(profileController.profileMap)
                              ))!.then((value) {
                                if (value == true) {
                                  profileController.postFetchProfileApi();
                                }
                              });
                            }
                          },
                          title: "Edit Profile",
                          arrowShow: false,
                        ),
                      ),
                    ),


                    SizedBox(
                        width: !businessLogin.value ? 0 : width * 0.03),
                    !businessLogin.value
                        ? const SizedBox()
                        : Expanded(
                      child: SizedBox(
                        //height: 60,
                        child: AppButton(
                          borderRadius: BorderRadius.circular(0),
                          buttonColor: ConstantColor.grayColor,
                          title: "Add Product",
                          fontSize: 19.1,
                          arrowShow: false,
                        ),
                      ),
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.03),
                    Text(
                      "Company Name",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['company_name'] != null && profileController.profileMap['company_name'].toString().trim().isNotEmpty ? profileController.profileMap['company_name'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mobile",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['mobile'] != null && profileController.profileMap['mobile'].toString().trim().isNotEmpty ? profileController.profileMap['mobile'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
                    Text(
                      "Whatsapp",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['whatsapp'] != null && profileController.profileMap['whatsapp'].toString().trim().isNotEmpty ? profileController.profileMap['whatsapp'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['email'] != null && profileController.profileMap['email'].toString().trim().isNotEmpty ? profileController.profileMap['email'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    :  SizedBox(height: height * 0.01),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Website",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['website'] != null && profileController.profileMap['website'].toString().trim().isNotEmpty ? profileController.profileMap['website'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
                    Text(
                      "Category",
                      style: headingTextStyle,
                    ),
                    Text(
                      // "${profileController.profileMap['category'] != null && profileController.profileMap['category'].toString().trim().isNotEmpty ? profileController.profileMap['category'] : ConstantString.naLabel}",
                      "IT Company, Event Planner",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
                    Text(
                      "Sub Category",
                      style: headingTextStyle,
                    ),
                    Text(
                      // "${profileController.profileMap['subcategory'] != null && profileController.profileMap['subcategory'].toString().trim().isNotEmpty ? profileController.profileMap['subcategory'] : ConstantString.naLabel}",
                      "Mobile Apps, Web Developer, Event Planner",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                !businessLogin.value
                    ? const SizedBox()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.01),
                    Text(
                      "About Us",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['about_us'] != null && profileController.profileMap['about_us'].toString().trim().isNotEmpty ? profileController.profileMap['about_us'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                SizedBox(height: height * 0.01),
                !businessLogin.value ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Area",
                      style: headingTextStyle,
                    ),
                    // SizedBox(height: height * 0.02),
                    appTextFormField(
                      keyboardType:
                      TextInputType.name,
                      hintText:
                      "Enter your area",
                      textInputAction:
                      TextInputAction
                          .done,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          updateProfileController.postUpdateProfileApi(
                            {
                              'name': "${profileController.profileMap['name'] != null && profileController.profileMap['name'].toString().trim().isNotEmpty ? profileController.profileMap['name'] : 'Name ${ConstantString.notAvailableLabel}'}",
                              'company_name': "",
                              'email': profileController.profileMap['email'] != null && profileController.profileMap['email'].toString().trim().isNotEmpty ? profileController.profileMap['email'] : ConstantString.naLabel,
                              'profile_type': "0",
                              'category': "0",
                              'sub_category': "0",
                              'whatsapp': "",
                              'website': "",
                              'about_us': "",
                              'area': profileController
                                  .areaController.value.text,
                            },
                            profileController.croppedProfileFile!.value.path.trim(),
                          );
                      },
                        child: Container(
                          width: Get.width / 4.2,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: ConstantColor.primary
                          ),
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            top: 8
                          ),
                          child: updateProfileController.isButtonLoading.value ? LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white,
                            size: 26,
                          ): const Text("Update",style: TextStyle(color: Colors.white,fontSize: 16),),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 5),
                      controller: profileController.areaController.value,
                    ),
                  ],
                ):Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Area",
                      style: headingTextStyle,
                    ),
                    Text(
                      "${profileController.profileMap['area'] != null && profileController.profileMap['area'].toString().trim().isNotEmpty ? profileController.profileMap['area'] : ConstantString.naLabel}",
                      style: valueTextStyle,
                    ),
                  ],
                ),
                // SizedBox(height: height * 0.01),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Text(
                //       "Referred Code",
                //       style: headingTextStyle,
                //     ),
                //     Text(
                //       "${controller.profileMap['referred_by_code'] != null && controller.profileMap['referred_by_code'].toString().trim().isNotEmpty ? controller.profileMap['referred_by_code'] : ConstantString.naLabel}",
                //       style: valueTextStyle,
                //     ),
                //   ],
                // ),
                SizedBox(height: height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        deleteDialog(context, height, width);
                      },
                      child: const Text("Delete Account",style: TextStyle(decoration: TextDecoration.underline,color:  Colors.red),),),

                  /*  ElevatedButton(
                      onPressed: () =>deleteDialog(context, height, width),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Delete Account"),
                    ),*/
                  ],
                ),
                SizedBox(height: height * 0.04),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle headingTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: ConstantColor.blackColor.withAlpha(204),
  );

  TextStyle valueTextStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: ConstantColor.blackColor,
  );

}
