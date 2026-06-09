import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/auth_controller/sign_details_controller.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_text_field.dart';

class SignDetailsScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const SignDetailsScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  @override
  State<SignDetailsScreen> createState() => _SignDetailsScreenState();
}

class _SignDetailsScreenState extends State<SignDetailsScreen> {
  SignDetailsController signDetailsController = Get.put(SignDetailsController());

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Obx(
            () => signDetailsController.isLoading.value
            ? Center(
          child:
          CircularProgressIndicator(color: ConstantColor.primary),
        )
            : SingleChildScrollView(
          child: StretchingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: height * 0.08),
                  Center(
                    child: Text(
                      "WELCOME TO",
                      style: TextStyle(
                        fontSize: 16,
                        color: ConstantColor.grayColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Center(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "SINGLE",
                            style: TextStyle(
                              fontSize: 40,
                              color: ConstantColor.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            " CLIK",
                            style: TextStyle(
                              fontSize: 40,
                              color: ConstantColor.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]),
                  ),
                  // Text(
                  //   "Welcome to",
                  //   style: TextStyle(
                  //     fontSize: 23,
                  //     color: ConstantColor.blackColor,
                  //     fontWeight: FontWeight.w400,
                  //     height: 0,
                  //   ),
                  // ),
                  // Text(
                  //   "Single Click",
                  //   style: TextStyle(
                  //     fontSize: 38,
                  //     color: ConstantColor.primary,
                  //     fontWeight: FontWeight.w400,
                  //     height: 0,
                  //   ),
                  // ),
                  SizedBox(height: height * 0.04),
                  Text(
                    "Hello!👋",
                    style: TextStyle(
                      fontSize: 24,
                      color: ConstantColor.primary,
                      fontWeight: FontWeight.w400,
                      height: 0,
                    ),
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 24,
                      color: ConstantColor.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Email ID",
                          style: textFieldLabelTextStyle, // Style for "Full Name"
                        ),
                        TextSpan(
                          text: "*",
                          style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   "Email ID",
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     color: ConstantColor.grayColor,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  // SizedBox(height: height * 0.02),
                  appTextFormField(
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Enter your Email id",
                    textInputAction: TextInputAction.done,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 5),
                    controller: signDetailsController.emailController.value,
                  ),
                  SizedBox(height: height * 0.03),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "Area",
                          style: textFieldLabelTextStyle, // Style for "Full Name"
                        ),
                        TextSpan(
                          text: "*",
                          style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                        ),
                      ],
                    ),
                  ),
                  // Text(
                  //   "Area (Bangalore)",
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     color: ConstantColor.grayColor,
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                  // SizedBox(height: height * 0.02),
                  appTextFormField(
                    keyboardType: TextInputType.name,
                    hintText: "Enter your area",
                    textInputAction: TextInputAction.done,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 5),
                    controller: signDetailsController.areaController.value,
                  ),
                  SizedBox(height: height * 0.03),
                  Text(
                    "Referred Code",
                    style: TextStyle(
                      fontSize: 20,
                      color: ConstantColor.grayColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // SizedBox(height: height * 0.02),
                  appTextFormField(
                    keyboardType: TextInputType.name,
                    hintText: "Enter your referred Code",
                    textInputAction: TextInputAction.done,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0, vertical: 5),
                    controller:
                    signDetailsController.referredCodeController.value,
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Upload your\nPhoto",
                        style: TextStyle(
                          fontSize: 18,
                          color: ConstantColor.blackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();

                            final XFile? image =
                            await picker.pickImage(
                                source: ImageSource.gallery);
                            if(image != null){
                              signDetailsController.cropImage(image);

                            }
                            // if (image != null) {
                            //   signDetailsController.filePath.value = image.path;
                            // }
                          },
                          child: Container(
                            height: 160,
                            width: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xffFFF0E9),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: signDetailsController.croppedProfileFile!.value.path != ""
                                ? Image.file(
                              File(signDetailsController.croppedProfileFile!.value.path),
                              width: width,
                              height: height,
                              fit: BoxFit.fill,
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
                      )
                    ],
                  ),
                  SizedBox(height: height * 0.1),
                  AppButton(
                    onTap: () async {
                      // showDialog(
                      //     barrierColor: Colors.transparent,
                      //     context: context,
                      //     builder: (context) => Dialog(
                      //           backgroundColor: Colors.transparent,
                      //           elevation: 0,
                      //           child: SizedBox(
                      //             width: width,
                      //             child: Stack(
                      //               clipBehavior: Clip.none,
                      //               children: [
                      //                 Image.asset(
                      //                   "assets/images/img_successful.png",
                      //                   width: width,
                      //                   fit: BoxFit.fill,
                      //                 ),
                      //                 Positioned(
                      //                   right: 40,
                      //                   top: 60,
                      //                   child: GestureDetector(
                      //                     onTap: () {
                      //                       Get.back();
                      //                     },
                      //                     child: Image.asset(
                      //                       "assets/icons/icon_close.png",
                      //                       height: 25,
                      //                       width: 25,
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         )).then((value) => Get.to(() => HomeTabBarScreen()));
                      if (signDetailsController
                          .emailController.value.text.isEmpty) {
                        ShowToast.showToast(
                          "Please Enter Email ID",
                          showSuccess: false,
                        );
                      } else if (!RegExp(
                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(signDetailsController
                          .emailController.value.text
                          .trim())) {
                        // falseIsButtonLoading();
                        ShowToast.showToast(
                          "Please Enter Valid Email ID",
                          showSuccess: false,
                        );
                      } else if (signDetailsController
                          .areaController.value.text.isEmpty) {
                        ShowToast.showToast(
                          "Please Enter Area",
                          showSuccess: false,
                        );
                      }
                      // else if (controller.filePath.value.isEmpty) {
                      //   ShowToast.showToast("Please Upload Your Photo");
                      // }
                      else {
                        Map<String, String> bodyParams = {
                          'person_name': widget.name.trim(),
                          'person_mobile': widget.phoneNumber.trim(),
                          'person_email': signDetailsController
                              .emailController.value.text
                              .trim(),
                          'person_area': signDetailsController
                              .areaController.value.text
                              .trim(),
                          'referred_by_code': signDetailsController
                              .referredCodeController.value.text
                              .trim(),
                          'user_type': '1',
                        };
                        await signDetailsController.postSignUpApi(bodyParams,signDetailsController.croppedProfileFile!.value.path != ""  ? signDetailsController.croppedProfileFile!.value.path.trim() : signDetailsController.filePath.value.trim(),);
                      }
                    },
                    isLoading: signDetailsController.isButtonLoading.value,
                    title: "Continue",
                  ),
                  SizedBox(height: height * 0.02),
                  // Center(
                  //   child: RichText(
                  //     text: TextSpan(
                  //       recognizer: TapGestureRecognizer()..onTap = () {},
                  //       text: 'Skip',
                  //       style: TextStyle(
                  //         color: ConstantColor.primary,
                  //         fontSize: 15,
                  //         decoration: TextDecoration.underline,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       children: [
                  //         TextSpan(
                  //           text: " for now (I'll do later)",
                  //           style: TextStyle(
                  //             color: ConstantColor.blackColor,
                  //             fontSize: 15,
                  //             fontWeight: FontWeight.w500,
                  //             decoration: TextDecoration.none,
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle textFieldLabelTextStyle = TextStyle(
    fontSize: 20,
    color: ConstantColor.blackColor,
    fontWeight: FontWeight.w500,
  );
}
