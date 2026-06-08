import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/widget/app_image_assets.dart';

import '../../constants/constant_string.dart';
import 'home_controller.dart';

class ProfileController extends GetxController {
  final isLoading = false.obs;
  final isButtonLoading = false.obs;
  final profileMap = {}.obs;
  final nameController = TextEditingController().obs;
  final emailController = TextEditingController().obs;
  final areaController = TextEditingController().obs;
  final referredCodeController = TextEditingController().obs;
  final filePath = "".obs;
  RxString beforeImgPath = ''.obs;
  RxString aboutUsBGImgFilePath = "".obs;
  Rx<CroppedFile>? croppedProfileFile = CroppedFile("").obs;

  @override
  void onInit() {
    postFetchProfileApi();
    super.onInit();
  }

  Future<void> cropImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 50,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: ConstantColor.primary,
            toolbarWidgetColor: Colors.white,
            statusBarColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );
      if (croppedFile != null) {
        croppedProfileFile!.value = croppedFile;
      }
    }
    update();
  }

  Future<void> autoUploadProfilePhoto() async {
    isButtonLoading.value = true;
    try {
      HomeController homeController = Get.find<HomeController>();
      Map<String, String> bodyParams = {
        'name': (profileMap['name'] ?? homeController.userData['name'] ?? '').toString().trim(),
        'company_name': (profileMap['company_name'] ?? homeController.userData['company_name'] ?? '').toString().trim(),
        'email': (profileMap['email'] ?? homeController.userData['email'] ?? '').toString().trim(),
        'area': (areaController.value.text.isNotEmpty 
            ? areaController.value.text 
            : (profileMap['area'] ?? homeController.userData['area'] ?? '')).toString().trim(),
        'referred_by_code': (profileMap['referred_by_code'] ?? homeController.userData['referred_by_code'] ?? '').toString().trim(),
        'profile_type': (profileMap['profile_type'] ?? homeController.userData['profile_type'] ?? '0').toString(),
        'category': (profileMap['category'] ?? homeController.userData['category'] ?? '0').toString(),
        'sub_category': (profileMap['sub_category'] ?? homeController.userData['sub_category'] ?? '0').toString(),
        'whatsapp': (profileMap['whatsapp'] ?? homeController.userData['whatsapp'] ?? '').toString(),
        'website': (profileMap['website'] ?? homeController.userData['website'] ?? '').toString(),
        'about_us': (profileMap['about_us'] ?? homeController.userData['about_us'] ?? '').toString(),
      };

      final value = await postUpdateProfileApi(
        bodyParams,
        croppedProfileFile!.value.path.trim(),
      );

      if (value != null && value['code'] == 200) {
        await postFetchProfileApi();
        await AppImageCacheManager.clearImageCache();
        homeController.photoVersion.value++;
        await homeController.postFetchProfileApi(forceRefresh: true);
        ShowToast.showToast(
          value['msg'] ?? ConstantString.dataUpdatedSuccessfullyMsg,
          showSuccess: true,
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      ShowToast.showToast('Failed to upload profile photo.', showSuccess: false);
    } finally {
      isButtonLoading.value = false;
    }
  }

  Future postFetchProfileApi() async {
    HomeController homeController = Get.put(HomeController());

    isLoading.value = true;
    debugPrint("Token::::${await SharPreferences.getString(SharPreferences.token)}");
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(API.fetchProfile));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      debugPrint(await SharPreferences.getString(SharPreferences.token));

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        log(responseData.toString());
        log("assureds${responseData['data'][0].toString()}");

        profileMap.value =  homeController.userData['user_type'] != 2 ? responseData['data'][0] : responseData['data'];
         filePath.value =
            '${ConstantString.userImgUrlPath}${profileMap['photo'] ?? ""}';
        beforeImgPath.value = filePath.value;
        homeController.userData['user_type'] != 2 ?  areaController.value.text =
            (profileMap['area'] ??
                '')
                .toString() : null;
        homeController.userData['user_type'] != 2 ?  nameController.value.text =
            (profileMap['name'] ??
                '')
                .toString() : null;
        homeController.userData.value = responseData['data'];
        debugPrint('responseData ${responseData['data']}');
        isLoading.value = false;
      } else {
        isLoading.value = false;
      }
    }
    catch (e) {
      isLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      debugPrint(e.toString());
    }
  }

  Future postUpdateProfileApi(Map<String, String> body, String photo) async {
    isButtonLoading.value = true;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(API.updateProfile));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll(body);
      (photo.isEmpty || photo.startsWith("http")) ? null : request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photo,
        ),
      );
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      debugPrint('ResponseDone:,$body $responseDone');
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseData.runtimeType.toString());
        debugPrint('Response Data: $responseData');
        if (responseData['code'] == 200) {
          debugPrint('Response: $responseData');
          return responseData;
        } else {
          throw '${responseData['msg'] ?? ConstantString.somethingWantWrongMsg}';
        }
      } else {
        debugPrint('Status: ${responseDone.statusCode} ${responseDone.body}');
        isButtonLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: true,);
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on SocketException catch (e) {
      isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on Error catch (e) {
      debugPrint('Error: $e');
      isButtonLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      // debugPrint(e.toString());
      throw e.toString();
    }
  }

  Future postDeveloperApi() async {
    isButtonLoading.value = true;
    try {
      final request = http.MultipartRequest('POST', Uri.parse(API.developer));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseData.runtimeType.toString());
        debugPrint('Response Data: $responseData');
        if (responseData['code'] == 200) {
          debugPrint('Success: $responseData');
          return responseData;
        } else {
          throw '${responseData['msg'] ?? ConstantString.somethingWantWrongMsg}';
        }
      } else {
        debugPrint('Response: ${responseDone.statusCode} ${responseDone.body}');
        isButtonLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: true,);
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on SocketException catch (e) {
      isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on Error catch (e) {
      debugPrint('Error: $e');
      isButtonLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      // debugPrint(e.toString());
      throw e.toString();
    }
  }
}
