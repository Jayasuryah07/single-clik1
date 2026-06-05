import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/auth_controller/business_sign_up_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_tab_bar_screen.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../constants/constant_string.dart';
import '../../widget/app_image_assets.dart';

class BusinessSignUpPage extends StatefulWidget {
  final bool? newAccount;

  const BusinessSignUpPage({super.key, this.newAccount});

  @override
  State<BusinessSignUpPage> createState() => _BusinessSignUpPageState();
}

class _BusinessSignUpPageState extends State<BusinessSignUpPage> {
  double height = Get.height;
  double width = Get.width;
  RxBool checkTermsCondition = false.obs;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  MultiSelectController<Map> multiSelectController =
      MultiSelectController<Map>();

  BusinessSignUpController businessSignUpController =
      Get.put(BusinessSignUpController());
  HomeController homeController = Get.put(HomeController());
  final controller = WebViewController();

  FocusNode nameFocusNode = FocusNode();
  FocusNode mobileNumberFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode categoryFocusNode = FocusNode();
  FocusNode subCategoryFocusNode = FocusNode();
  FocusNode whatsappNumberFocusNode = FocusNode();
  FocusNode aboutFocusNode = FocusNode();
  FocusNode areaFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    falseIsButtonLoading();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Form(
        key: formKey,
        child: Scaffold(
          body: Obx(
            () => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.04),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              //   "Single Clik",
                              //   style: TextStyle(
                              //     fontSize: 38,
                              //     color: ConstantColor.primary,
                              //     fontWeight: FontWeight.w400,
                              //     height: 0,
                              //   ),
                              // ),
                              Text(
                                "WELCOME TO",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: ConstantColor.grayColor,
                                  fontWeight: FontWeight.w400,
                                  height: 0,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SINGLE",
                                    style: TextStyle(
                                      fontSize: 35,
                                      color: ConstantColor.primary,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                  Text(
                                    " CLIK",
                                    style: TextStyle(
                                      fontSize: 35,
                                      color: ConstantColor.primaryDark,
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Image.asset(
                          "assets/images/sc_logo_new.png",
                          height: width * 0.28,
                          width: width * 0.28,
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    // Text(
                    //   "Hello!👋",
                    //   style: TextStyle(
                    //     fontSize: 24,
                    //     color: ConstantColor.primary,
                    //     fontWeight: FontWeight.w400,
                    //     height: 0,
                    //   ),
                    // ),
                    Text(
                      widget.newAccount == true
                          ? "Create your Business Account":"Add My Business / Services",
                      style: TextStyle(
                        fontSize: 24,
                        color: ConstantColor.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    widget.newAccount == true
                        ? SizedBox(height: height * 0.03) : Container(),
                    widget.newAccount == true
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Full Name",
                                      style: textFieldLabelTextStyle, // Style for "Full Name"
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: height * 0.005),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtFullName.value,
                                keyboardType: TextInputType.name,
                                focusNode: nameFocusNode,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: inputDecoration(
                                  hintText: "Enter your full name",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Company Name",
                                style: textFieldLabelTextStyle,
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller: businessSignUpController
                                    .txtCompanyName.value,
                                keyboardType: TextInputType.name,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                textCapitalization: TextCapitalization.words,
                                decoration: inputDecoration(
                                  hintText: "Enter your Company name",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Mobile Number",
                                      style: textFieldLabelTextStyle, // Style for "Full Name"
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtMobileNo.value,
                                keyboardType: TextInputType.number,
                                focusNode: mobileNumberFocusNode,
                                style: textFieldTextStyle,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Mobile number",
                                  hintTextStyle: textFieldHintTextStyle,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, right: 20),
                                    child: Text(
                                      "+91",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: ConstantColor.blackColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your mobile number';
                                  } else if (value.trim().length != 10) {
                                    return 'Please enter your valid mobile number';
                                  }
                                  return null;
                                },
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
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtEmailId.value,
                                keyboardType: TextInputType.emailAddress,
                                focusNode: emailFocusNode,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Email id",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email id';
                                  } else if (!RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value.trim())) {
                                    return 'Please enter your valid email id';
                                  }
                                  return null;
                                },
                              ),

                              /// Drop Down Start

                              SizedBox(height: height * 0.03),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Profile Type",
                                      style: textFieldLabelTextStyle, // Style for "Full Name"
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: height * 0.03),
                              InputDecorator(
                                decoration: inputDecoration(
                                  hintText: "Select one",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    dropdownColor: ConstantColor.whiteColor,
                                    style: textFieldTextStyle,
                                    hint: Text(
                                      "Select one",
                                      style: textFieldHintTextStyle,
                                    ),
                                    isExpanded: true,
                                    items:
                                        businessSignUpController.profileTypeList
                                            .map(
                                              (element) => DropdownMenuItem(
                                                value: element,
                                                child: Text(
                                                  element,
                                                  style: textFieldTextStyle,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    value: businessSignUpController
                                            .selectedProfileType.value
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : businessSignUpController
                                            .selectedProfileType.value,
                                    onChanged: (value) {
                                      businessSignUpController
                                              .selectedProfileType.value =
                                          value ??
                                              businessSignUpController
                                                  .selectedProfileType.value;
                                    },
                                  ),
                                ),
                              ),

                              if (businessSignUpController
                                  .categoryDataList.isNotEmpty) ...[
                                SizedBox(height: height * 0.03),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Category",
                                        style: textFieldLabelTextStyle, // Style for "Full Name"
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: height * 0.03),
                                InputDecorator(
                                  decoration: inputDecoration(
                                    hintText: "Select one",
                                    hintTextStyle: textFieldHintTextStyle,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton(
                                      dropdownColor: ConstantColor.whiteColor,
                                      style: textFieldTextStyle,
                                      hint: Text(
                                        "Select one",
                                        style: textFieldHintTextStyle,
                                      ),
                                      isExpanded: true,
                                      items: businessSignUpController
                                          .categoryDataList
                                          .map(
                                            (element) => DropdownMenuItem(
                                              value: element,
                                              child: Text(
                                                element['category'].toString(),
                                                style: textFieldTextStyle,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      value: businessSignUpController
                                                          .selectedCategory[
                                                      'category'] ==
                                                  null ||
                                              businessSignUpController
                                                  .selectedCategory['category']
                                                  .toString()
                                                  .trim()
                                                  .isEmpty
                                          ? null
                                          : businessSignUpController.selectedCategory['category_id'],
                                      onChanged: (value) async {
                                        // debugPrint('Value selected: $value');
                                        try {
                                          EasyLoading.show(
                                            status:
                                                ConstantString.pleaseWaitLabel,
                                          );
                                          await Future.delayed(
                                            Duration(
                                              milliseconds: 100,
                                            ),
                                          );
                                          businessSignUpController
                                                  .subCategoryDataList.value =
                                              await businessSignUpController
                                                  .getSubCategoryDataCategoryIdWiseApi(
                                                      parameters: {
                                                'category_id':
                                                    ((value as Map)['id'] ??
                                                            '0')
                                                        .toString(),
                                              });
                                          multiSelectController.setItems(
                                              businessSignUpController
                                                  .subCategoryDataList
                                                  .map(
                                                    (element) => DropdownItem(
                                                      value: (element as Map),
                                                      label:
                                                          element['subcategory']
                                                              .toString(),
                                                    ),
                                                  )
                                                  .toList());
                                          businessSignUpController
                                              .selectedSubCategory.value = {};
                                          businessSignUpController
                                                  .selectedCategory.value =
                                              (value);
                                          EasyLoading.dismiss();
                                        } on TimeoutException catch (error) {
                                          EasyLoading.dismiss();
                                          ShowToast.showToast(
                                            error.message.toString(),
                                            showSuccess: false,
                                          );
                                        } on SocketException catch (error) {
                                          EasyLoading.dismiss();
                                          ShowToast.showToast(
                                            error.message.toString(),
                                            showSuccess: false,
                                          );
                                        } catch (error) {
                                          EasyLoading.dismiss();
                                          ShowToast.showToast(
                                            ConstantString
                                                .somethingWantWrongMsg,
                                            showSuccess: false,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: height * 0.03),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Sub Category",
                                        style: textFieldLabelTextStyle, // Style for "Full Name"
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: height * 0.03),
                                (businessSignUpController.selectedCategory[
                                                    'category'] !=
                                                null &&
                                            businessSignUpController
                                                .selectedCategory['category']
                                                .toString()
                                                .trim()
                                                .isNotEmpty) &&
                                        businessSignUpController
                                            .subCategoryDataList.isEmpty
                                    ? TextFormField(
                                        controller: businessSignUpController
                                            .txtOtherSubCategory.value,
                                        keyboardType: TextInputType.text,
                                        focusNode: subCategoryFocusNode,
                                        style: textFieldTextStyle,
                                        textInputAction: TextInputAction.next,
                                        textCapitalization:
                                            TextCapitalization.words,
                                        decoration: inputDecoration(
                                          hintText: "Enter your Sub Category",
                                          hintTextStyle: textFieldHintTextStyle,
                                        ),
                                        validator: (value) {
                                          if (((businessSignUpController
                                                                  .selectedCategory[
                                                              'category'] !=
                                                          null &&
                                                      businessSignUpController
                                                          .selectedCategory[
                                                              'category']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty) &&
                                                  businessSignUpController
                                                      .subCategoryDataList
                                                      .isEmpty) &&
                                              (value == null ||
                                                  value.trim().isEmpty)) {
                                            return 'Please enter your sub category';
                                          }
                                          return null;
                                        },
                                      )
                                    :
                                    // InputDecorator(
                                    //         decoration: inputDecoration(
                                    //           hintText: "Select one",
                                    //           hintTextStyle: textFieldHintTextStyle,
                                    //         ),
                                    //         child: DropdownButtonHideUnderline(
                                    //           child: DropdownButton(
                                    //             dropdownColor:
                                    //                 ConstantColor.whiteColor,
                                    //             style: textFieldTextStyle,
                                    //             hint: Text(
                                    //               "Select one",
                                    //               style: textFieldHintTextStyle,
                                    //             ),
                                    //             isExpanded: true,
                                    //             items: businessSignUpController
                                    //                 .subCategoryDataList
                                    //                 .map(
                                    //                   (element) => DropdownMenuItem(
                                    //                     value: element,
                                    //                     child: Text(
                                    //                       element['subcategory']
                                    //                           .toString(),
                                    //                       style: textFieldTextStyle,
                                    //                     ),
                                    //                   ),
                                    //                 )
                                    //                 .toList(),
                                    //             value: businessSignUpController
                                    //                                 .selectedSubCategory[
                                    //                             'subcategory'] ==
                                    //                         null ||
                                    //                     businessSignUpController
                                    //                         .selectedSubCategory[
                                    //                             'subcategory']
                                    //                         .toString()
                                    //                         .trim()
                                    //                         .isEmpty
                                    //                 ? null
                                    //                 : businessSignUpController
                                    //                     .selectedSubCategory.value,
                                    //             onChanged: (value) {
                                    //               businessSignUpController
                                    //                       .selectedSubCategory
                                    //                       .value =
                                    //                   (value ??
                                    //                       businessSignUpController
                                    //                           .selectedSubCategory
                                    //                           .value) as Map;
                                    //             },
                                    //           ),
                                    //         ),
                                    //       ),
                                    MultiDropdown<Map>(
                                        items: businessSignUpController
                                            .subCategoryDataList
                                            .map(
                                              (element) => DropdownItem(
                                                value: (element as Map),
                                                label: element['subcategory']
                                                    .toString(),
                                              ),
                                            )
                                            .toList(),
                                        controller: multiSelectController,
                                        chipDecoration: ChipDecoration(
                                          backgroundColor:
                                              ConstantColor.primary,
                                          labelStyle: TextStyle(
                                            color: ConstantColor.whiteColor,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: Get.width / 70,
                                            vertical: Get.width / 150,
                                          ),
                                          deleteIcon: Icon(
                                            Icons.close_rounded,
                                            color: ConstantColor.whiteColor,
                                            size: Get.width / 20,
                                          ),
                                          wrap: true,
                                          runSpacing: 6,
                                          spacing: 10,
                                        ),
                                        dropdownItemDecoration:
                                            DropdownItemDecoration(
                                          selectedIcon: Icon(
                                            Icons.check_box_rounded,
                                            color: ConstantColor.whiteColor,
                                          ),
                                          selectedTextColor:
                                              ConstantColor.whiteColor,
                                          backgroundColor: ConstantColor.primary
                                              .withAlpha(77),
                                          selectedBackgroundColor: ConstantColor
                                              .primary
                                              .withAlpha(230),
                                        ),
                                        fieldDecoration: FieldDecoration(
                                          hintText: "Select one",
                                          hintStyle: textFieldHintTextStyle,
                                          border: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              width: 1,
                                              color: ConstantColor.grayColor,
                                            ),
                                          ),
                                        ),
                                        // controller: multiSelectController,
                                      ),
                              ] else ...[
                                SizedBox(height: height * 0.03),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Category",
                                        style: textFieldLabelTextStyle, // Style for "Full Name"
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: height * 0.03),
                                TextFormField(
                                  controller: businessSignUpController
                                      .txtOtherCategory.value,
                                  keyboardType: TextInputType.name,
                                  focusNode: categoryFocusNode,
                                  style: textFieldTextStyle,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: inputDecoration(
                                    hintText: "Enter your Category",
                                    hintTextStyle: textFieldHintTextStyle,
                                  ),
                                  validator: (value) {
                                    if (businessSignUpController
                                            .categoryDataList.isEmpty &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Please enter your category';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: height * 0.03),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Sub Category",
                                        style: textFieldLabelTextStyle, // Style for "Full Name"
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                      ),
                                    ],
                                  ),
                                ),
                                // SizedBox(height: height * 0.03),
                                TextFormField(
                                  controller: businessSignUpController
                                      .txtOtherSubCategory.value,
                                  keyboardType: TextInputType.name,
                                  focusNode: subCategoryFocusNode,
                                  style: textFieldTextStyle,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  decoration: inputDecoration(
                                    hintText: "Enter your Sub Category",
                                    hintTextStyle: textFieldHintTextStyle,
                                  ),
                                  validator: (value) {
                                    if (businessSignUpController
                                            .categoryDataList.isEmpty &&
                                        (value == null ||
                                            value.trim().isEmpty)) {
                                      return 'Please enter your sub category';
                                    }
                                    return null;
                                  },
                                ),
                              ],

                              /// Drop Down End

                              SizedBox(height: height * 0.03),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Whatsapp Number",
                                      style: textFieldLabelTextStyle, // Style for "Full Name"
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller: businessSignUpController
                                    .txtWhatsappNo.value,
                                keyboardType: TextInputType.number,
                                focusNode: whatsappNumberFocusNode,
                                style: textFieldTextStyle,
                                maxLength: 10,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Whatsapp number",
                                  hintTextStyle: textFieldHintTextStyle,
                                  prefixIcon: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, right: 20),
                                    child: Text(
                                      "+91",
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: ConstantColor.blackColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your whatsapp number';
                                  } else if (value.trim().length != 10) {
                                    return 'Please enter your valid whatsapp number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Website",
                                style: textFieldLabelTextStyle,
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtWebsite.value,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Website",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "About",
                                      style: textFieldLabelTextStyle, // Style for "Full Name"
                                    ),
                                    TextSpan(
                                      text: "*",
                                      style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                    ),
                                  ],
                                ),
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtAbout.value,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                focusNode: aboutFocusNode,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your About",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your about';
                                  }
                                  return null;
                                },
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
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller:
                                    businessSignUpController.txtArea.value,
                                keyboardType: TextInputType.name,
                                focusNode: areaFocusNode,
                                textCapitalization: TextCapitalization.words,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Area",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your area';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Referred Code",
                                style: textFieldLabelTextStyle,
                              ),
                              // SizedBox(height: height * 0.03),
                              TextFormField(
                                controller: businessSignUpController
                                    .txtReferredCode.value,
                                keyboardType: TextInputType.name,
                                textCapitalization: TextCapitalization.words,
                                style: textFieldTextStyle,
                                textInputAction: TextInputAction.next,
                                decoration: inputDecoration(
                                  hintText: "Enter your Referred code",
                                  hintTextStyle: textFieldHintTextStyle,
                                ),
                              ),
                              SizedBox(height: height * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                            await picker.pickImage(source: ImageSource.gallery);
                                        if(image != null){
                                          businessSignUpController.cropImage(image);

                                        }
                                        // if (image != null) {
                                        //   businessSignUpController
                                        //       .filePath.value = image.path;
                                        // }
                                      },
                                      child: Container(
                                        height: 160,
                                        width: 160,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFF0E9),
                                          borderRadius:
                                              BorderRadius.circular(7),
                                        ),
                                        child: businessSignUpController
                                                    .croppedProfileFile!.value.path !=
                                                ""
                                            ? AppImageAsset(
                                                image: businessSignUpController
                                                    .croppedProfileFile!.value.path
                                                        .contains("cache")
                                                    ? businessSignUpController
                                                    .croppedProfileFile!.value.path
                                                    : "${businessSignUpController
                                                    .croppedProfileFile!.value}",
                                                isFile: businessSignUpController
                                                    .croppedProfileFile!.value.path
                                                    .contains("cache"),
                                                // fit: BoxFit.cover,
                                                // height: 100,
                                                // width: 100,
                                              )
                                            // Image.file(
                                            //         File(businessSignUpController
                                            //             .filePath.value),
                                            //         width: width,
                                            //         height: height,
                                            //         fit: BoxFit.fill,
                                            //       )
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
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              widget.newAccount == true ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: Get.width / 2.5,
                                    width: Get.width / 2.5,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(7),
                                            child: Container(
                                              height: Get.width / 3,
                                              width: Get.width / 3,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffFFF0E9),
                                                borderRadius:
                                                    BorderRadius.circular(7),
                                              ),
                                              child: businessSignUpController
                                                          .filePath.value !=
                                                      ""
                                                  ? AppImageAsset(
                                                      image: businessSignUpController
                                                              .filePath
                                                              .contains("cache")
                                                          ? businessSignUpController
                                                              .filePath.value
                                                          : "${ConstantString.userImgUrlPath}${businessSignUpController.filePath}",
                                                      isFile:
                                                          businessSignUpController
                                                              .filePath
                                                              .contains(
                                                                  "cache"),
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
                                              final ImagePicker picker =
                                                  ImagePicker();

                                              final XFile? image =
                                                  await picker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              if (image != null) {
                                                businessSignUpController
                                                    .filePath
                                                    .value = image.path;
                                              }
                                            },
                                            child: Container(
                                              height: Get.width / 10,
                                              width: Get.width / 10,
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
                                  ),
                                  SizedBox(width: width * 0.02),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Full Name",
                                          style: userConstHeadingTextStyle,
                                        ),
                                        Text(
                                          homeController.userData['name'] ==
                                                      null ||
                                                  homeController
                                                      .userData['name']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? ConstantString.naLabel
                                              : homeController.userData['name']
                                                  .toString(),
                                          style: userConstValueTextStyle,
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Text(
                                          "Mobile",
                                          style: userConstHeadingTextStyle,
                                        ),
                                        Text(
                                          homeController.userData['mobile'] ==
                                                      null ||
                                                  homeController
                                                      .userData['mobile']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? ConstantString.naLabel
                                              : homeController
                                                  .userData['mobile']
                                                  .toString(),
                                          style: userConstValueTextStyle,
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Text(
                                          "Email",
                                          style: userConstHeadingTextStyle,
                                        ),
                                        Text(
                                          homeController.userData['email'] ==
                                                      null ||
                                                  homeController
                                                      .userData['email']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? ConstantString.naLabel
                                              : homeController.userData['email']
                                                  .toString(),
                                          style: userConstValueTextStyle,
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Text(
                                          "Area",
                                          style: userConstHeadingTextStyle,
                                        ),
                                        Text(
                                          homeController.userData['area'] ==
                                                      null ||
                                                  homeController
                                                      .userData['area']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? ConstantString.naLabel
                                              : homeController.userData['area']
                                                  .toString(),
                                          style: userConstValueTextStyle,
                                        ),
                                        SizedBox(height: height * 0.01),
                                        Text(
                                          "Referred Code",
                                          style: userConstHeadingTextStyle,
                                        ),
                                        Text(
                                          homeController.userData[
                                                          'referred_by_code'] ==
                                                      null ||
                                                  homeController.userData[
                                                          'referred_by_code']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? ConstantString.naLabel
                                              : homeController
                                                  .userData['referred_by_code']
                                                  .toString(),
                                          style: userConstValueTextStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ) : Container(),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: height * 0.03),
                                  Text(
                                    "Company Name",
                                    style: textFieldLabelTextStyle,
                                  ),
                                  // SizedBox(height: height * 0.03),
                                  TextFormField(
                                    controller: businessSignUpController
                                        .txtCompanyName.value,
                                    keyboardType: TextInputType.name,
                                    style: textFieldTextStyle,
                                    textInputAction: TextInputAction.next,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: inputDecoration(
                                      hintText: "Enter your Company name",
                                      hintTextStyle: textFieldHintTextStyle,
                                    ),
                                  ),

                                  /// Drop Down Start

                                  SizedBox(height: height * 0.03),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Profile Type",
                                          style: textFieldLabelTextStyle, // Style for "Full Name"
                                        ),
                                        TextSpan(
                                          text: "*",
                                          style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: height * 0.03),
                                  InputDecorator(
                                    decoration: inputDecoration(
                                      hintText: "Select one",
                                      hintTextStyle: textFieldHintTextStyle,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        dropdownColor: ConstantColor.whiteColor,
                                        style: textFieldTextStyle,
                                        hint: Text(
                                          "Select one",
                                          style: textFieldHintTextStyle,
                                        ),
                                        isExpanded: true,
                                        items: businessSignUpController
                                            .profileTypeList
                                            .map(
                                              (element) => DropdownMenuItem(
                                                value: element,
                                                child: Text(
                                                  element,
                                                  style: textFieldTextStyle,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        value: businessSignUpController
                                                .selectedProfileType.value
                                                .trim()
                                                .isEmpty
                                            ? null
                                            : businessSignUpController
                                                .selectedProfileType.value,
                                        onChanged: (value) {
                                          businessSignUpController
                                                  .selectedProfileType.value =
                                              value ??
                                                  businessSignUpController
                                                      .selectedProfileType
                                                      .value;
                                        },
                                      ),
                                    ),
                                  ),

                                  if (businessSignUpController
                                      .categoryDataList.isNotEmpty) ...[
                                    SizedBox(height: height * 0.03),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Category",
                                            style: textFieldLabelTextStyle, // Style for "Full Name"
                                          ),
                                          TextSpan(
                                            text: "*",
                                            style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: height * 0.03),
                                    InputDecorator(
                                      decoration: inputDecoration(
                                        hintText: "Select one",
                                        hintTextStyle: textFieldHintTextStyle,
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton(
                                          dropdownColor:
                                              ConstantColor.whiteColor,
                                          style: textFieldTextStyle,
                                          hint: Text(
                                            "Select one",
                                            style: textFieldHintTextStyle,
                                          ),
                                          isExpanded: true,
                                          items: businessSignUpController
                                              .categoryDataList
                                              .map(
                                                (element) => DropdownMenuItem(
                                                  value: element,
                                                  child: Text(
                                                    element['category']
                                                        .toString(),
                                                    style: textFieldTextStyle,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          value: businessSignUpController
                                                              .selectedCategory[
                                                          'category'] ==
                                                      null ||
                                                  businessSignUpController
                                                      .selectedCategory[
                                                          'category']
                                                      .toString()
                                                      .trim()
                                                      .isEmpty
                                              ? null
                                              : businessSignUpController.selectedCategory['category_id'],
                                          onChanged: (value) async {
                                            // print('Value: $value');
                                            try {
                                              EasyLoading.show(
                                                status: ConstantString
                                                    .pleaseWaitLabel,
                                              );
                                              await Future.delayed(
                                                Duration(
                                                  milliseconds: 100,
                                                ),
                                              );
                                              businessSignUpController
                                                      .subCategoryDataList
                                                      .value =
                                                  await businessSignUpController
                                                      .getSubCategoryDataCategoryIdWiseApi(
                                                          parameters: {
                                                    'category_id':
                                                        ((value as Map)['id'] ??
                                                                '0')
                                                            .toString(),
                                                  });
                                              multiSelectController.setItems(
                                                  businessSignUpController
                                                      .subCategoryDataList
                                                      .map(
                                                        (element) =>
                                                            DropdownItem(
                                                          value:
                                                              (element as Map),
                                                          label: element[
                                                                  'subcategory']
                                                              .toString(),
                                                        ),
                                                      )
                                                      .toList());
                                              businessSignUpController
                                                  .selectedSubCategory
                                                  .value = {};
                                              businessSignUpController
                                                      .selectedCategory.value = (value);
                                              EasyLoading.dismiss();
                                            } on TimeoutException catch (error) {
                                              EasyLoading.dismiss();
                                              ShowToast.showToast(
                                                error.message.toString(),
                                                showSuccess: false,
                                              );
                                            } on SocketException catch (error) {
                                              EasyLoading.dismiss();
                                              ShowToast.showToast(
                                                error.message.toString(),
                                                showSuccess: false,
                                              );
                                            } catch (error) {
                                              EasyLoading.dismiss();
                                              ShowToast.showToast(
                                                ConstantString
                                                    .somethingWantWrongMsg,
                                                showSuccess: false,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: height * 0.03),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Sub Category",
                                            style: textFieldLabelTextStyle, // Style for "Full Name"
                                          ),
                                          TextSpan(
                                            text: "*",
                                            style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: height * 0.03),
                                    (businessSignUpController.selectedCategory[
                                                        'category'] !=
                                                    null &&
                                                businessSignUpController
                                                    .selectedCategory[
                                                        'category']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty) &&
                                            businessSignUpController
                                                .subCategoryDataList.isEmpty
                                        ? TextFormField(
                                            controller: businessSignUpController
                                                .txtOtherSubCategory.value,
                                            keyboardType: TextInputType.name,
                                            style: textFieldTextStyle,
                                            focusNode: subCategoryFocusNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            textCapitalization:
                                                TextCapitalization.words,
                                            decoration: inputDecoration(
                                              hintText:
                                                  "Enter your Sub Category",
                                              hintTextStyle:
                                                  textFieldHintTextStyle,
                                            ),
                                            validator: (value) {
                                              if (((businessSignUpController
                                                                      .selectedCategory[
                                                                  'category'] !=
                                                              null &&
                                                          businessSignUpController
                                                              .selectedCategory[
                                                                  'category']
                                                              .toString()
                                                              .trim()
                                                              .isNotEmpty) &&
                                                      businessSignUpController
                                                          .subCategoryDataList
                                                          .isEmpty) &&
                                                  (value == null ||
                                                      value.trim().isEmpty)) {
                                                return 'Please enter your sub category';
                                              }
                                              return null;
                                            },
                                          )
                                        :
                                        // InputDecorator(
                                        //         decoration: inputDecoration(
                                        //           hintText: "Select one",
                                        //           hintTextStyle:
                                        //               textFieldHintTextStyle,
                                        //         ),
                                        //         child: DropdownButtonHideUnderline(
                                        //           child: DropdownButton(
                                        //             dropdownColor:
                                        //                 ConstantColor.whiteColor,
                                        //             style: textFieldTextStyle,
                                        //             hint: Text(
                                        //               "Select one",
                                        //               style: textFieldHintTextStyle,
                                        //             ),
                                        //             isExpanded: true,
                                        //             items: businessSignUpController
                                        //                 .subCategoryDataList
                                        //                 .map(
                                        //                   (element) =>
                                        //                       DropdownMenuItem(
                                        //                     value: element,
                                        //                     child: Text(
                                        //                       element['subcategory']
                                        //                           .toString(),
                                        //                       style:
                                        //                           textFieldTextStyle,
                                        //                     ),
                                        //                   ),
                                        //                 )
                                        //                 .toList(),
                                        //             value: businessSignUpController
                                        //                                 .selectedSubCategory[
                                        //                             'subcategory'] ==
                                        //                         null ||
                                        //                     businessSignUpController
                                        //                         .selectedSubCategory[
                                        //                             'subcategory']
                                        //                         .toString()
                                        //                         .trim()
                                        //                         .isEmpty
                                        //                 ? null
                                        //                 : businessSignUpController
                                        //                     .selectedSubCategory
                                        //                     .value,
                                        //             onChanged: (value) {
                                        //               businessSignUpController
                                        //                       .selectedSubCategory
                                        //                       .value =
                                        //                   (value ??
                                        //                       businessSignUpController
                                        //                           .selectedSubCategory
                                        //                           .value) as Map;
                                        //             },
                                        //           ),
                                        //         ),
                                        //       ),
                                        MultiDropdown<Map>(
                                            items: businessSignUpController
                                                .subCategoryDataList
                                                .map(
                                                  (element) => DropdownItem(
                                                    value: (element as Map),
                                                    label:
                                                        element['subcategory']
                                                            .toString(),
                                                  ),
                                                )
                                                .toList(),
                                            controller: multiSelectController,
                                            chipDecoration: ChipDecoration(
                                              backgroundColor:
                                                  ConstantColor.primary,
                                              labelStyle: TextStyle(
                                                color: ConstantColor.whiteColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              padding: EdgeInsets.symmetric(
                                                horizontal: Get.width / 70,
                                                vertical: Get.width / 150,
                                              ),
                                              deleteIcon: Icon(
                                                Icons.close_rounded,
                                                color: ConstantColor.whiteColor,
                                                size: Get.width / 20,
                                              ),
                                              wrap: true,
                                              runSpacing: 6,
                                              spacing: 10,
                                            ),
                                            dropdownItemDecoration:
                                                DropdownItemDecoration(
                                              selectedIcon: Icon(
                                                Icons.check_box_rounded,
                                                color: ConstantColor.whiteColor,
                                              ),
                                              selectedTextColor:
                                                  ConstantColor.whiteColor,
                                              backgroundColor: ConstantColor
                                                  .primary
                                                  .withAlpha(77),
                                              selectedBackgroundColor:
                                                  ConstantColor.primary
                                                      .withAlpha(230),
                                            ),
                                            fieldDecoration: FieldDecoration(
                                              hintText: "Select one",
                                              hintStyle: textFieldHintTextStyle,
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 1,
                                                  color:
                                                      ConstantColor.grayColor,
                                                ),
                                              ),
                                            ),
                                            // controller: multiSelectController,
                                          ),
                                  ] else ...[
                                    SizedBox(height: height * 0.03),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Category",
                                            style: textFieldLabelTextStyle, // Style for "Full Name"
                                          ),
                                          TextSpan(
                                            text: "*",
                                            style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: height * 0.03),
                                    TextFormField(
                                      controller: businessSignUpController
                                          .txtOtherCategory.value,
                                      keyboardType: TextInputType.name,
                                      style: textFieldTextStyle,
                                      focusNode: categoryFocusNode,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: inputDecoration(
                                        hintText: "Enter your Category",
                                        hintTextStyle: textFieldHintTextStyle,
                                      ),
                                      validator: (value) {
                                        if (businessSignUpController
                                                .categoryDataList.isEmpty &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return 'Please enter your category';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: height * 0.03),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Sub Category",
                                            style: textFieldLabelTextStyle, // Style for "Full Name"
                                          ),
                                          TextSpan(
                                            text: "*",
                                            style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                          ),
                                        ],
                                      ),
                                    ),
                                    // SizedBox(height: height * 0.03),
                                    TextFormField(
                                      controller: businessSignUpController
                                          .txtOtherSubCategory.value,
                                      keyboardType: TextInputType.name,
                                      focusNode: subCategoryFocusNode,
                                      style: textFieldTextStyle,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.words,
                                      decoration: inputDecoration(
                                        hintText: "Enter your Sub Category",
                                        hintTextStyle: textFieldHintTextStyle,
                                      ),
                                      validator: (value) {
                                        if (businessSignUpController
                                                .categoryDataList.isEmpty &&
                                            (value == null ||
                                                value.trim().isEmpty)) {
                                          return 'Please enter your sub category';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],

                                  /// Drop Down End

                                  SizedBox(height: height * 0.03),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Whatsapp Number",
                                          style: textFieldLabelTextStyle, // Style for "Full Name"
                                        ),
                                        TextSpan(
                                          text: "*",
                                          style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: height * 0.03),
                                  TextFormField(
                                    controller: businessSignUpController
                                        .txtWhatsappNo.value,
                                    keyboardType: TextInputType.number,
                                    focusNode: whatsappNumberFocusNode,
                                    style: textFieldTextStyle,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    textInputAction: TextInputAction.next,
                                    decoration: inputDecoration(
                                      hintText: "Enter your Whatsapp number",
                                      hintTextStyle: textFieldHintTextStyle,
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5, bottom: 5, right: 20),
                                        child: Text(
                                          "+91",
                                          style: TextStyle(
                                            fontSize: 22,
                                            color: ConstantColor.blackColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your whatsapp number';
                                      } else if (value.trim().length != 10) {
                                        return 'Please enter your valid whatsapp number';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(height: height * 0.03),
                                  Text(
                                    "Website",
                                    style: textFieldLabelTextStyle,
                                  ),
                                  // SizedBox(height: height * 0.03),
                                  TextFormField(
                                    controller: businessSignUpController
                                        .txtWebsite.value,
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: textFieldTextStyle,
                                    textInputAction: TextInputAction.next,
                                    decoration: inputDecoration(
                                      hintText: "Enter your Website",
                                      hintTextStyle: textFieldHintTextStyle,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.03),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "About",
                                          style: textFieldLabelTextStyle, // Style for "Full Name"
                                        ),
                                        TextSpan(
                                          text: "*",
                                          style: textFieldLabelTextStyle.copyWith(color: Colors.red), // Red color for "*"
                                        ),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: height * 0.03),
                                  TextFormField(
                                    controller:
                                        businessSignUpController.txtAbout.value,
                                    keyboardType: TextInputType.name,
                                    focusNode: aboutFocusNode,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: textFieldTextStyle,
                                    textInputAction: TextInputAction.next,
                                    decoration: inputDecoration(
                                      hintText: "Enter your About",
                                      hintTextStyle: textFieldHintTextStyle,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your about';
                                      }
                                      return null;
                                    },
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
                                  // SizedBox(height: height * 0.03),
                                  TextFormField(
                                    controller:
                                        businessSignUpController.txtArea.value,
                                    keyboardType: TextInputType.name,
                                    focusNode: areaFocusNode,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    style: textFieldTextStyle,
                                    textInputAction: TextInputAction.next,
                                    decoration: inputDecoration(
                                      hintText: "Enter your Area",
                                      hintTextStyle: textFieldHintTextStyle,
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Please enter your area';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                            ],
                          ),
                    SizedBox(height: height * 0.03),
                    Center(
                      child: Obx(
                            () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: checkTermsCondition.value,
                              onChanged: (value) =>
                              checkTermsCondition.value = value ?? false,
                            ),
                            // SizedBox(width: width * 0.03,),
                            GestureDetector(
                              onTap: () {
                                controller
                                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                  ..loadRequest(Uri.parse(ConstantString.businessTermsUrl));
                                showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      titlePadding: EdgeInsets.only(top: 10,right: 10,bottom: 0),
                                      title: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                            onTap: (){
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                                padding: EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: ConstantColor.grayColor.withAlpha(128)
                                                ),
                                                child: Icon(Icons.close,color: ConstantColor.blackColor,)),
                                          ),
                                        ],
                                      ),
                                      contentPadding: EdgeInsets.all(0),
                                      content: SizedBox(
                                        width: 430, // Adjust the width here
                                        child: WebViewWidget(controller: controller),
                                      ),
                                    );
                                  },
                                );
                                // Get.to(
                                //   TermsAndConditionPage(
                                //     url: ConstantString.businessTermsUrl,
                                //   ),
                                // );
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'I read & agree to ',
                                      style: TextStyle(
                                        color: ConstantColor.blackColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(
                                        color: ConstantColor.primary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Center(
                      child: AppButton(
                        onTap: () async {
                          // print(
                          //     'SelectedItem ${multiSelectController.selectedItems.map((e) => e.value,)}');
                          businessSignUpController.isButtonLoading.value = true;
                          await Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                          );
                          nameFocusNode.unfocus();
                          mobileNumberFocusNode.unfocus();
                          emailFocusNode.unfocus();
                          categoryFocusNode.unfocus();
                          subCategoryFocusNode.unfocus();
                          whatsappNumberFocusNode.unfocus();
                          aboutFocusNode.unfocus();
                          areaFocusNode.unfocus();
                          if ((widget.newAccount == true) &&
                              businessSignUpController.txtFullName.value.text
                                  .trim()
                                  .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            nameFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Full Name",
                            //   showSuccess: false,
                            // );
                          }
                          // else if (businessSignUpController
                          //     .txtCompanyName.value.text
                          //     .trim()
                          //     .isEmpty) {
                          //   falseIsButtonLoading();
                          //   ShowToast.showToast(
                          //     "Please Enter Company Name",
                          //     showSuccess: false,
                          //   );
                          // }
                          else if ((widget.newAccount == true) &&
                              businessSignUpController.txtMobileNo.value.text
                                  .trim()
                                  .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            mobileNumberFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Mobile Number",
                            //   showSuccess: false,
                            // );
                          } else if ((widget.newAccount == true) &&
                              businessSignUpController.txtMobileNo.value.text.trim().length !=
                                  10) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            mobileNumberFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Valid Mobile Number",
                            //   showSuccess: false,
                            // );
                          } else if ((widget.newAccount == true) &&
                              businessSignUpController.txtEmailId.value.text
                                  .trim()
                                  .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            emailFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Email ID",
                            //   showSuccess: false,
                            // );
                          } else if ((widget.newAccount == true) &&
                              !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(businessSignUpController
                                      .txtEmailId.value.text
                                      .trim())) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            emailFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Valid Email ID",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController
                              .selectedProfileType.value
                              .trim()
                              .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            ShowToast.showToast(
                              "Please Select Profile Type",
                              showSuccess: false,
                            );
                          } else if (businessSignUpController.categoryDataList.isEmpty &&
                              businessSignUpController.txtOtherCategory.value.text
                                  .trim()
                                  .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            categoryFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Your Category",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController.categoryDataList.isEmpty &&
                              businessSignUpController.txtOtherSubCategory.value.text
                                  .trim()
                                  .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            subCategoryFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Your Sub Category",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController.categoryDataList.isNotEmpty &&
                              (businessSignUpController.selectedCategory['category'] == null ||
                                  businessSignUpController
                                      .selectedCategory['category']
                                      .toString()
                                      .trim()
                                      .isEmpty)) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            ShowToast.showToast(
                              "Please Select Category",
                              showSuccess: false,
                            );
                          }
                          // else if (businessSignUpController.subCategoryDataList.isNotEmpty && (businessSignUpController.selectedSubCategory['subcategory'] == null || businessSignUpController.selectedSubCategory['subcategory'].toString().trim().isEmpty))
                          else if (businessSignUpController
                                  .subCategoryDataList.isNotEmpty &&
                              (multiSelectController.selectedItems.isEmpty)) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            ShowToast.showToast(
                              "Please Select Sub Category",
                              showSuccess: false,
                            );
                          } else if (businessSignUpController
                                  .subCategoryDataList.isEmpty &&
                              (businessSignUpController
                                  .txtOtherSubCategory.value.text
                                  .trim()
                                  .isEmpty)) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            subCategoryFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Your Sub Category",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController
                              .txtWhatsappNo.value.text
                              .trim()
                              .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            whatsappNumberFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Whatsapp Number",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController
                                  .txtWhatsappNo.value.text
                                  .trim()
                                  .length !=
                              10) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            whatsappNumberFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Valid Whatsapp Number",
                            //   showSuccess: false,
                            // );
                          }
                          // else if (businessSignUpController.txtWebsite.value.text
                          //     .trim()
                          //     .isEmpty) {
                          //   falseIsButtonLoading();
                          //   ShowToast.showToast(
                          //     "Please Enter Website",
                          //     showSuccess: false,
                          //   );
                          // }
                          else if (businessSignUpController.txtAbout.value.text
                              .trim()
                              .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            aboutFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter About",
                            //   showSuccess: false,
                            // );
                          } else if (businessSignUpController.txtArea.value.text
                              .trim()
                              .isEmpty) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            areaFocusNode.requestFocus();
                            // ShowToast.showToast(
                            //   "Please Enter Area",
                            //   showSuccess: false,
                            // );
                          }
                          // else if (businessSignUpController.filePath
                          //     .trim()
                          //     .isEmpty) {
                          //   falseIsButtonLoading();
                          //   ShowToast.showToast(
                          //     "Please Upload Your Photo",
                          //     showSuccess: false,
                          //   );
                          // }
                          else if (!checkTermsCondition.value) {
                            falseIsButtonLoading();
                            formKey.currentState!.validate();
                            ShowToast.showToast(
                              "Please Accept our terms & conditions",
                              showSuccess: false,
                            );
                          } else {
                            try {
                              bool updateProfile = widget.newAccount != true;
                              Map<String, String> bodyParams = {
                                'name': updateProfile
                                    ? (homeController.userData['name'] ?? '')
                                        .toString()
                                    : businessSignUpController
                                        .txtFullName.value.text
                                        .trim(),
                                'company_name': businessSignUpController
                                    .txtCompanyName.value.text
                                    .trim(),
                                'mobile': updateProfile
                                    ? (homeController.userData['mobile'] ?? '')
                                        .toString()
                                    : businessSignUpController
                                        .txtMobileNo.value.text
                                        .trim(),
                                'email': updateProfile
                                    ? (homeController.userData['email'] ?? '')
                                        .toString()
                                    : businessSignUpController
                                        .txtEmailId.value.text
                                        .trim(),
                                'profile_type': businessSignUpController
                                            .selectedProfileType.value
                                            .trim()
                                            .toLowerCase() ==
                                        'Business'.trim().toLowerCase()
                                    ? '0'
                                    : businessSignUpController
                                                .selectedProfileType.value
                                                .trim()
                                                .toLowerCase() ==
                                            'Service'.trim().toLowerCase()
                                        ? '1'
                                        : businessSignUpController
                                                    .selectedProfileType.value
                                                    .trim()
                                                    .toLowerCase() ==
                                                'Business/Service'
                                                    .trim()
                                                    .toLowerCase()
                                            ? '0,1'
                                            : '',
                                'category': businessSignUpController
                                        .categoryDataList.isEmpty
                                    ? ''
                                    : (businessSignUpController
                                                .selectedCategory['id'] ??
                                            '')
                                        .toString(),
                                'other_category': businessSignUpController
                                        .categoryDataList.isNotEmpty
                                    ? ''
                                    : businessSignUpController
                                        .txtOtherCategory.value.text
                                        .trim(),
                                'sub_category': businessSignUpController
                                            .categoryDataList.isEmpty ||
                                        businessSignUpController
                                            .subCategoryDataList.isEmpty
                                    ? ''
                                    : (multiSelectController.selectedItems
                                            .map(
                                              (e) => e.value['id'] ?? '0',
                                            )
                                            .toList()
                                            .join(','))
                                        .toString(),
                                // (businessSignUpController
                                //                 .selectedSubCategory['id'] ??
                                //             '')
                                //         .toString(),
                                'other_sub_category': businessSignUpController
                                            .categoryDataList.isNotEmpty &&
                                        businessSignUpController
                                            .subCategoryDataList.isNotEmpty
                                    ? ''
                                    : businessSignUpController
                                        .txtOtherSubCategory.value.text
                                        .trim(),
                                'whatsapp': businessSignUpController
                                    .txtWhatsappNo.value.text
                                    .trim(),
                                'website': businessSignUpController
                                    .txtWebsite.value.text
                                    .trim(),
                                'about_us': businessSignUpController
                                    .txtAbout.value.text
                                    .trim(),
                                'area': updateProfile
                                    ? (homeController.userData['area'] ?? '')
                                        .toString()
                                    : businessSignUpController
                                        .txtArea.value.text
                                        .trim(),
                                'referred_by_code': updateProfile
                                    ? (homeController
                                                .userData['referred_by_code'] ??
                                            '')
                                        .toString()
                                    : businessSignUpController
                                        .txtReferredCode.value.text
                                        .trim(),
                              };
                              debugPrint('Update Profile: -$updateProfile : $bodyParams');
                              if (updateProfile) {
                                await businessSignUpController
                                    .postUpdateProfileApi(
                                  bodyParams,
                                  businessSignUpController.croppedProfileFile!.value.path.trim(),
                                )
                                    .then(
                                  (value) {
                                    debugPrint('Value: $value');
                                    if (value['code'] == 200) {
                                      falseIsButtonLoading();
                                      ShowToast.showToast(
                                        value['msg'] ??
                                            'Business Account Created Successfully.',
                                        showSuccess: true,
                                      );
                                      Get.offAll(
                                        HomeTabBarScreen(),
                                      );
                                    } else {
                                      falseIsButtonLoading();
                                      ShowToast.showToast(
                                        value['msg'] ??
                                            ConstantString
                                                .somethingWantWrongMsg,
                                        showSuccess: false,
                                      );
                                    }
                                  },
                                ).catchError((error) {
                                  debugPrint('Error: $error');
                                  falseIsButtonLoading();
                                  ShowToast.showToast(
                                    error.toString(),
                                    showSuccess: false,
                                  );
                                });
                              } else {
                                await businessSignUpController
                                    .postBusinessSignUpApi(
                                        bodyParams,
                                        businessSignUpController.filePath
                                            .trim())
                                    .then(
                                  (value) {
                                    if (value['code'] == 200) {
                                      falseIsButtonLoading();
                                      ShowToast.showToast(
                                        value['msg'] ??
                                            'Business Account Created Successfully.',
                                        showSuccess: true,
                                      );
                                      Get.back();
                                    } else {
                                      falseIsButtonLoading();
                                      ShowToast.showToast(
                                        value['msg'] ??
                                            ConstantString
                                                .somethingWantWrongMsg,
                                        showSuccess: false,
                                      );
                                    }
                                  },
                                ).catchError((error) {
                                  falseIsButtonLoading();
                                  ShowToast.showToast(
                                    error.toString(),
                                    showSuccess: false,
                                  );
                                });
                              }
                            } catch (error) {
                              falseIsButtonLoading();
                              ShowToast.showToast(
                                error.toString(),
                                showSuccess: false,
                              );
                            }
                            // Get.to(() => SignDetailsScreen(
                            //   name: controller.nameController.value.text,
                            //   phoneNumber: phoneNumber,
                            // ));
                          }
                        },
                        title: "Submit",
                        isLoading:
                            businessSignUpController.isButtonLoading.value,
                        myWidth: Get.width / 2,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void falseIsButtonLoading() =>
      businessSignUpController.isButtonLoading.value = false;

  TextStyle textFieldLabelTextStyle = TextStyle(
    fontSize: 20,
    color: ConstantColor.blackColor,
    fontWeight: FontWeight.w500,
  );

  TextStyle textFieldHintTextStyle = TextStyle(
    fontSize: 14,
    // color: ConstantColor.grayColor,
    // fontWeight: FontWeight.w400,
  );
  TextStyle textFieldTextStyle = TextStyle(
    fontSize: 21,
    color: ConstantColor.blackColor,
    // fontWeight: FontWeight.w500,
  );

  TextStyle userConstHeadingTextStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: ConstantColor.grayColor,
  );

  TextStyle userConstValueTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ConstantColor.blackColor,
  );

  InputDecoration inputDecoration({
    required String hintText,
    TextStyle? hintTextStyle,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      border: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: ConstantColor.grayColor,
        ),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: ConstantColor.grayColor,
        ),
      ),
      disabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: ConstantColor.grayColor,
        ),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          width: 1,
          color: ConstantColor.grayColor,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      hintText: hintText,
      hintStyle: hintTextStyle,
      counterText: '',
      prefixIcon: prefixIcon,
    );
  }
}
