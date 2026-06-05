import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/auth_controller/business_sign_up_controller.dart';
import 'package:single_clik/controller/auth_controller/mobile_number_controller.dart';
import 'package:single_clik/controller/auth_controller/otp_controller.dart';
import 'package:single_clik/screens/auth_screens/business_sign_up_page.dart';
import 'package:single_clik/screens/auth_screens/otp_screen.dart';
import 'package:single_clik/screens/auth_screens/sign_name_screen.dart';
import 'package:single_clik/screens/home_tab_bar_screen.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:single_clik/widget/app_text_field.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  State<MobileNumberScreen> createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {

  final controller = WebViewController();
  RxBool checkTermsCondition = false.obs;
  
  late BusinessSignUpController businessSignUpController;
  late OTPController otpController;
  late MobileNumberController mobileNumberController;

  @override
  void initState() {
    super.initState();
    debugPrint('=== MobileNumberScreen Initialized ===');
    // Initialize controllers
    businessSignUpController = Get.put(BusinessSignUpController());
    otpController = Get.put(OTPController());
    mobileNumberController = Get.put(MobileNumberController());
  }

  @override
  void dispose() {
    debugPrint('=== MobileNumberScreen Disposed ===');
    super.dispose();
  }

  Future<void> _handleLogin() async {
    debugPrint('=== _handleLogin Started ===');
    try {
      if (!checkTermsCondition.value) {
        debugPrint('Terms & Conditions not accepted');
        ShowToast.showToast("Please agree to terms & conditions", showSuccess: false);
        return;
      }

      String mobileNumber = mobileNumberController.mobileNumberController.value.text.trim();
      debugPrint('Mobile Number entered: $mobileNumber');
      
      if (mobileNumber.isEmpty) {
        debugPrint('Mobile number is empty');
        ShowToast.showToast("Please Enter Mobile Number", showSuccess: false);
        return;
      }
      
      if (mobileNumber.length < 10) {
        debugPrint('Mobile number length: ${mobileNumber.length} - Invalid');
        ShowToast.showToast("Please Enter Valid Mobile Number", showSuccess: false);
        return;
      }
      
      if (!(await ConstantString.checkInternet())) {
        debugPrint('No internet connection');
        Get.snackbar("Check Internet", 'You lost your connection', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      
      debugPrint('Starting login process for: $mobileNumber');
      mobileNumberController.isButtonLoading.value = true;
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Check if the number exists in API
      debugPrint('Calling postCheckMobileApi for: $mobileNumber');
      final response = await otpController.postCheckMobileApi({"mobile": mobileNumber});
      
      debugPrint('CheckMobile Response: $response');
      debugPrint('Response code: ${response['code']}');
      debugPrint('Response data: ${response['data']}');
      
      if (response['code'] == 182) {
        debugPrint('Error 182: ${response['msg']}');
        mobileNumberController.isButtonLoading.value = false;
        ShowToast.showToast(response['msg'].toString(), showSuccess: false);
        return;
      } 
      else if (response['code'] == 200) {
        // Existing user - store password and send OTP
        debugPrint('Existing user detected. Password from API: ${response['data']}');
        mobileNumberController.password.value = response['data'].toString();
        await _sendOTP(mobileNumber);
        debugPrint('OTP sending initiated');
      } 
      else {
        // New user - navigate to signup
        debugPrint('New user detected. Navigating to SignNameScreen');
        mobileNumberController.isButtonLoading.value = false;
        Get.to(() => SignNameScreen(phoneNumber: mobileNumber));
      }
    } catch (e) {
      debugPrint('=== Error in _handleLogin ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      mobileNumberController.isButtonLoading.value = false;
      ShowToast.showToast("Something went wrong. Try again.", showSuccess: false);
    }
  }

  Future<void> _sendOTP(String mobileNumber) async {
    debugPrint('=== _sendOTP Started for: $mobileNumber ===');
    debugPrint('Starting OTP sending process for real users');
    
    try {
      // REMOVED the problematic line - No setSettings needed for production
      // Just call verifyPhoneNumber directly for real users
      
      debugPrint('Calling verifyPhoneNumber for: +91$mobileNumber');
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$mobileNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('=== verificationCompleted triggered ===');
          try {
            debugPrint('Auto-signing in with credential');
            await FirebaseAuth.instance.signInWithCredential(credential);
            debugPrint('Auto-login successful');
            // Auto login successful
            await _performLogin(
              mobileNumberController.mobileNumberController.value.text.trim(), 
              mobileNumberController.password.value
            );
          } catch (e) {
            debugPrint('Auto verification error: $e');
            debugPrint('Stack trace: ${StackTrace.current}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('=== verificationFailed triggered ===');
          debugPrint('Error code: ${e.code}');
          debugPrint('Error message: ${e.message}');
          debugPrint('Full error: $e');
          mobileNumberController.isButtonLoading.value = false;
          
          if (e.code == 'invalid-phone-number') {
            debugPrint('Invalid phone number');
            ShowToast.showToast("Invalid phone number", showSuccess: false);
          } else if (e.code == 'too-many-requests') {
            debugPrint('Too many requests');
            ShowToast.showToast("Too many requests, try again later.", showSuccess: false);
          } else if (e.code == 'network-error') {
            debugPrint('Network error');
            ShowToast.showToast("Network error. Check your connection.", showSuccess: false);
          } else if (e.code == 'firebase_error') {
            debugPrint('Firebase configuration error');
            ShowToast.showToast("Firebase configuration error. Please check app settings.", showSuccess: false);
          } else if (e.code == 'app-not-authorized') {
            debugPrint('App not authorized - Check Firebase console');
            ShowToast.showToast("App authorization failed. Please contact support.", showSuccess: false);
          } else {
            debugPrint('Unknown verification error');
            ShowToast.showToast("Verification failed: ${e.message}", showSuccess: false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('=== codeSent triggered ===');
          debugPrint('Verification ID: $verificationId');
          debugPrint('Resend Token: $resendToken');
          debugPrint('Mobile Number: $mobileNumber');
          
          otpController.resendToken.value = resendToken ?? 0;
          otpController.verify.value = verificationId;
          mobileNumberController.isButtonLoading.value = false;
          
          debugPrint('Stored verificationId in OTPController: ${otpController.verify.value}');
          debugPrint('Stored resendToken in OTPController: ${otpController.resendToken.value}');
          
          ShowToast.showToast("OTP Sent Successfully", showSuccess: true);
          debugPrint('Navigating to OtpScreen');
          Get.to(() => const OtpScreen());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('=== codeAutoRetrievalTimeout triggered ===');
          debugPrint('Verification ID timeout: $verificationId');
          mobileNumberController.isButtonLoading.value = false;
        },
      );
    } catch (e) {
      debugPrint('=== Error in _sendOTP ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      mobileNumberController.isButtonLoading.value = false;
      ShowToast.showToast("Failed to send OTP. Please try again.", showSuccess: false);
    }
  }

  Future<void> _performLogin(String mobileNumber, String password) async {
    debugPrint('=== _performLogin Started ===');
    debugPrint('Mobile: $mobileNumber');
    debugPrint('Password: $password');
    
    try {
      debugPrint('Calling postLoginApi');
      final response = await otpController.postLoginApi({
        "mobile": mobileNumber,
        "password": password,
        "device_id": await SharPreferences.getString(SharPreferences.fcmToken) ?? "Unknown_Device",
      });
      
      debugPrint('Login API Response: $response');
      debugPrint('Response code: ${response['code']}');
      debugPrint('Response message: ${response['msg']}');
      
      if (response['code'] == 200) {
        debugPrint('Login successful! Navigating to HomeTabBarScreen');
        ShowToast.showToast("Login Successful!", showSuccess: true);
        Get.offAll(() => const HomeTabBarScreen());
      } else {
        debugPrint('Login failed with code: ${response['code']}');
        ShowToast.showToast(response['msg'] ?? "Login failed", showSuccess: false);
      }
    } catch (e) {
      debugPrint('=== Error in _performLogin ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      ShowToast.showToast("Login failed. Please try again.", showSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return KeyboardVisibilityBuilder(
        builder: (p0, isKeyboardVisible) => Scaffold(
          backgroundColor: ConstantColor.whiteColor,
          body: Obx(
            () => mobileNumberController.isLoading.value
                ? Center(
              child: CircularProgressIndicator(
                  color: ConstantColor.primary),
            )
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: height * 0.07),
                    Center(
                      child: Image.asset(
                        "assets/images/sc_logo_new.png",
                        height: height * 0.25,
                      ),
                    ),
                    SizedBox(height: height * 0.04),
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
                    SizedBox(height: height * 0.04),
                    Text(
                      "Enter your Mobile number\nto Log in",
                      style: TextStyle(
                        fontSize: 24,
                        color: ConstantColor.blackColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "We will send you confirmation code",
                      style: TextStyle(
                        fontSize: 16,
                        color: ConstantColor.grayColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: height * 0.03),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: appTextFormField(
                        style: TextStyle(
                          color: ConstantColor.blackColor,
                          fontSize: 21,
                        ),
                        keyboardType: TextInputType.number,
                        hintText: "Enter your mobile number",
                        hintStyle: TextStyle(
                          fontSize: 14,
                        ),
                        maxLength: 10,
                        counterText: '',
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9]'))
                        ],
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              top: 5, bottom: 5, right: 20),
                          child: Text(
                            "+91",
                            style: TextStyle(
                              fontSize: 22,
                              color: ConstantColor.primary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        textInputAction: TextInputAction.done,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 5),
                        controller:
                        mobileNumberController.mobileNumberController.value,
                      ),
                    ),
                    SizedBox(height: height * 0.018),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: checkTermsCondition.value,
                          onChanged: (value) =>
                          checkTermsCondition.value = value ?? false,
                        ),
                        GestureDetector(
                          onTap: () {
                            controller
                              ..setJavaScriptMode(JavaScriptMode.unrestricted)
                              ..loadRequest(Uri.parse(ConstantString.loginTermsUrl));
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
                                    width: 430,
                                    child: WebViewWidget(controller: controller),
                                  ),
                                );
                              },
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'I read & agree to ',
                              style: TextStyle(
                                color: ConstantColor.blackColor,
                                fontSize: Get.width*0.03,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: TextStyle(
                                    color: ConstantColor.primary,
                                    fontSize: Get.width*0.03,
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
                    SizedBox(height: height * 0.02),
                    Center(
                      child: AppButton(
                        onTap: _handleLogin, // Using the new method
                        title: "Next",
                        isLoading: mobileNumberController.isButtonLoading.value,
                        myWidth: Get.width / 1.8,
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(6),
                        onTap: () async {
                          debugPrint('=== Business/Service Signup Started ===');
                          EasyLoading.show(
                            status: ConstantString.pleaseWaitLabel,
                          );
                          businessSignUpController
                              .isButtonLoading.value = false;
                          businessSignUpController.txtFullName.value
                              .clear();
                          businessSignUpController
                              .txtCompanyName.value
                              .clear();
                          businessSignUpController.txtMobileNo.value
                              .clear();
                          businessSignUpController.txtEmailId.value
                              .clear();
                          businessSignUpController.txtWhatsappNo.value
                              .clear();
                          businessSignUpController.txtWebsite.value
                              .clear();
                          businessSignUpController.txtAbout.value
                              .clear();
                          businessSignUpController.txtArea.value
                              .clear();
                          businessSignUpController
                              .txtReferredCode.value
                              .clear();
                          businessSignUpController
                              .txtOtherCategory.value
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
                          businessSignUpController.filePath.value =
                          '';
                          try {
                            debugPrint('Fetching category data');
                            businessSignUpController
                                .categoryDataList.value =
                            await businessSignUpController
                                .getCategoryDataApi();
                            businessSignUpController
                                .subCategoryDataList.value = [];
                            debugPrint('Category data fetched successfully');
                            EasyLoading.dismiss();
                          } on TimeoutException catch (error) {
                            debugPrint('Timeout error: ${error.message}');
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
                            debugPrint('Socket error: ${error.message}');
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
                            debugPrint('General error: $error');
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

                          debugPrint('Navigating to BusinessSignUpPage');
                          Get.to(
                            BusinessSignUpPage(
                              newAccount: true,
                            ),
                          );
                          EasyLoading.dismiss();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppImageAsset(
                              image: 'assets/icons/join_as_bs.png',
                              height: Get.width / 15,
                              width: Get.width / 15,
                              fit: BoxFit.cover,
                            ),
                            SizedBox(
                              width: Get.width / 30,
                            ),
                            Text(
                              'Join as\nBusiness/Service',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: ConstantColor.primaryDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}