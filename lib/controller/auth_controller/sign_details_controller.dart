import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/auth_controller/mobile_number_controller.dart';
import 'package:single_clik/controller/auth_controller/otp_controller.dart';
import 'package:single_clik/screens/auth_screens/mobile_number_screen.dart';
import 'package:single_clik/services/api.dart';

import '../../constants/constant_color.dart';
import '../../constants/constant_string.dart';
import '../../screens/auth_screens/otp_screen.dart';
import '../../screens/home_tab_bar_screen.dart';
import '../../utils/shar_preferences.dart';

class SignDetailsController extends GetxController {
  final isLoading = false.obs;
  final isButtonLoading = false.obs;

  final emailController = TextEditingController().obs;
  final areaController = TextEditingController().obs;
  final referredCodeController = TextEditingController().obs;

  final filePath = "".obs;
  Rx<CroppedFile>? croppedProfileFile = CroppedFile("").obs;

  Future<void> cropImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,

        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: ConstantColor.primaryDark,
              toolbarWidgetColor: ConstantColor.primary,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        croppedProfileFile!.value = croppedFile;
      }
    }
    update();
  }

 
  Future postSignUpApi(Map<String, String> bodyParams, String photo) async {
    try {
      isButtonLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.signUp));
      request.fields.addAll(bodyParams);
      
      if (photo.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo),
        );
      }
      
      debugPrint('bodyParams: $bodyParams');
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint('SignUp Response: ${responseDone.body}');
        
        if (responseData['code'] == 200) {
          ShowToast.showToast(
            responseData['msg'] ?? ConstantString.dataSubmittedSuccessfullyMsg,
            showSuccess: true,
          );
          
          // Store the password from response
          String userPassword = responseData['data']['cpassword'].toString();
          
          // Navigate to MobileNumberScreen with necessary data
          Get.offAll(() => const MobileNumberScreen());
          
          // Get controllers
          MobileNumberController mobileNumberController = Get.find<MobileNumberController>();
          OTPController otpController = Get.find<OTPController>();
          
          // Set mobile number
          mobileNumberController.mobileNumberController.value = 
              TextEditingController(text: bodyParams['person_mobile'].toString());
          mobileNumberController.password.value = userPassword;
          
          // Auto-trigger OTP after successful signup
          await _triggerOTPVerification(
            mobileNumberController, 
            otpController, 
            bodyParams['person_mobile'].toString()
          );
          
          isButtonLoading.value = false;
        } else {
          isButtonLoading.value = false;
          ShowToast.showToast(
            responseData['msg'] ?? ConstantString.somethingWantWrongMsg,
            showSuccess: false,
          );
        }
      } else {
        isButtonLoading.value = false;
        ShowToast.showToast(ConstantString.somethingWantWrongMsg, showSuccess: false);
      }
    } catch (e) {
      isButtonLoading.value = false;
      ShowToast.showToast(e.toString(), showSuccess: false);
      debugPrint(e.toString());
    }
  }

  Future<void> _triggerOTPVerification(
    MobileNumberController mobileNumberController,
    OTPController otpController,
    String mobileNumber
  ) async {
    try {
      // Bypassing / setting appVerificationDisabledForTesting to true causes verification to fail on real devices.
      // We call verifyPhoneNumber directly to allow standard Play Integrity / reCAPTCHA fallback verification.
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: "+91$mobileNumber",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            // Auto-login successful
            final response = await otpController.postLoginApi({
              "mobile": mobileNumber,
              "password": mobileNumberController.password.value,
              "device_id": await SharPreferences.getString(SharPreferences.fcmToken) ?? "Unknown_Device",
            });
            if (response['code'] == 200) {
              ShowToast.showToast("Login Successful!", showSuccess: true);
              Get.offAll(() => const HomeTabBarScreen());
            } else {
              ShowToast.showToast(response['msg'] ?? "Login failed", showSuccess: false);
            }
          } catch (e) {
            debugPrint('Auto verification error: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification Failed: ${e.code} - ${e.message}');
          ShowToast.showToast("OTP verification failed. Please try login manually.", showSuccess: false);
        },
        codeSent: (String verificationId, int? resendToken) {
          otpController.resendToken.value = resendToken ?? 0;
          otpController.verify.value = verificationId;
          ShowToast.showToast("OTP Sent Successfully", showSuccess: true);
          Get.to(() => const OtpScreen());
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto retrieval timeout');
        },
      );
    } catch (e) {
      debugPrint('Error triggering OTP: $e');
      ShowToast.showToast("Failed to send OTP. Please try login manually.", showSuccess: false);
    }
  }
}

