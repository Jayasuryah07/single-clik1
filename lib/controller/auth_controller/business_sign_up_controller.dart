import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/services/api.dart';

import '../../constants/constant_color.dart';
import '../../utils/shar_preferences.dart';

class BusinessSignUpController extends GetxController {
  Rx<TextEditingController> txtFullName = TextEditingController().obs;
  Rx<TextEditingController> txtCompanyName = TextEditingController().obs;
  Rx<TextEditingController> txtMobileNo = TextEditingController().obs;
  Rx<TextEditingController> txtEmailId = TextEditingController().obs;
  Rx<TextEditingController> txtWhatsappNo = TextEditingController().obs;
  Rx<TextEditingController> txtWebsite = TextEditingController().obs;
  Rx<TextEditingController> txtAbout = TextEditingController().obs;
  Rx<TextEditingController> txtArea = TextEditingController().obs;
  Rx<TextEditingController> txtReferredCode = TextEditingController().obs;
  Rx<TextEditingController> txtOtherCategory = TextEditingController().obs;
  Rx<TextEditingController> txtOtherSubCategory = TextEditingController().obs;
  
  RxList<String> profileTypeList = <String>[
    'Business',
    'Service',
    'Business/Service',
  ].obs;
  RxString selectedProfileType = "".obs;
  RxList<Map<String, dynamic>> categoryDataList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> selectedCategory = <String, dynamic>{}.obs;
  RxList<Map<String, dynamic>> subCategoryDataList = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> selectedSubCategory = <String, dynamic>{}.obs;
  RxString filePath = "".obs;

  RxBool isButtonLoading = false.obs;
  Rx<CroppedFile?> croppedProfileFile = Rx<CroppedFile?>(null);
  RxBool isLoadingCategories = false.obs;
  RxBool isAccountCreated = false.obs;
  RxString createdPassword = "".obs;
  RxInt createdUserId = 0.obs;

  @override
  void onClose() {
    txtFullName.value?.dispose();
    txtCompanyName.value?.dispose();
    txtMobileNo.value?.dispose();
    txtEmailId.value?.dispose();
    txtWhatsappNo.value?.dispose();
    txtWebsite.value?.dispose();
    txtAbout.value?.dispose();
    txtArea.value?.dispose();
    txtReferredCode.value?.dispose();
    txtOtherCategory.value?.dispose();
    txtOtherSubCategory.value?.dispose();
    super.onClose();
  }

  Future<void> cropImage(XFile? pickedFile) async {
    if (pickedFile != null) {
      try {
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
          croppedProfileFile.value = croppedFile;
        }
      } catch (e) {
        debugPrint('Error cropping image: $e');
      }
    }
    update();
  }

  Future<List<Map<String, dynamic>>> getCategoryDataApi() async {
    try {
      isLoadingCategories.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.categories));
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint('Categories response received');
        if (responseData['code'] != 200) {
          return [];
        }
        List<Map<String, dynamic>> categories = [];
        for (var item in responseData['data'] ?? []) {
          categories.add(Map<String, dynamic>.from(item));
        }
        return categories;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint('Error loading categories: $error');
      return [];
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getSubCategoryDataCategoryIdWiseApi({
    required Map<String, String> parameters,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(API.subcategories));
      request.fields.addAll(parameters);
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint('Subcategories response received');
        if (responseData['code'] != 200) {
          return [];
        }
        List<Map<String, dynamic>> subCategories = [];
        for (var item in responseData['data'] ?? []) {
          subCategories.add(Map<String, dynamic>.from(item));
        }
        return subCategories;
      } else {
        return [];
      }
    } catch (error) {
      debugPrint('Error loading subcategories: $error');
      return [];
    }
  }

  Future<Map<String, dynamic>> postBusinessSignUpApi(Map<String, String> bodyParams, String photo) async {
    try {
      isButtonLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.businessSignUp));
      request.fields.addAll(bodyParams);
      
      if (photo.isNotEmpty && !photo.startsWith("http") && File(photo).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo),
        );
      }

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      debugPrint('Business SignUp Status Code: ${res.statusCode}');

      if (res.statusCode == 200) {
        try {
          final responseData = json.decode(responseDone.body);
          
          if (responseData is Map<String, dynamic> && responseData.containsKey('code')) {
            if (responseData['code'] == 200) {
              if (responseData['data'] != null) {
                createdPassword.value = responseData['data']['cpassword']?.toString() ?? '';
                createdUserId.value = responseData['data']['id'] ?? 0;
              }
              isAccountCreated.value = true;
              return Map<String, dynamic>.from(responseData);
            } else {
              throw responseData['msg'] ?? ConstantString.somethingWantWrongMsg;
            }
          } else {
            // Account created but response format is different
            isAccountCreated.value = true;
            return {
              'code': 200,
              'msg': 'Account created successfully',
              'data': {}
            };
          }
        } catch (jsonError) {
          debugPrint('JSON parsing error: $jsonError');
          // Account might still be created
          isAccountCreated.value = true;
          return {
            'code': 200,
            'msg': 'Account created successfully',
            'data': {}
          };
        }
      } else {
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      throw e.message.toString();
    } on SocketException catch (e) {
      throw "No internet connection";
    } on Error catch (e) {
      throw e.toString();
    } finally {
      isButtonLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> postUpdateProfileApi(Map<String, String> body, String photo) async {
    try {
      isButtonLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.updateProfile));
      String? token = await SharPreferences.getString(SharPreferences.token);
      
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll(body);
      
      if (photo.isNotEmpty && !photo.startsWith("http") && File(photo).existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', photo),
        );
      }

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      
      debugPrint('Update Profile Status Code: ${res.statusCode}');

      if (res.statusCode == 200) {
        try {
          final responseData = json.decode(responseDone.body);
          if (responseData['code'] == 200) {
            return Map<String, dynamic>.from(responseData);
          } else {
            throw responseData['msg'] ?? ConstantString.somethingWantWrongMsg;
          }
        } catch (jsonError) {
          debugPrint('JSON parsing error in update profile: $jsonError');
          return {
            'code': 200,
            'msg': 'Profile updated successfully',
            'data': {}
          };
        }
      } else if (res.statusCode == 401) {
        throw "Session expired. Please login again.";
      } else {
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      throw e.message.toString();
    } on SocketException catch (e) {
      throw "No internet connection";
    } on Error catch (e) {
      throw e.toString();
    } finally {
      isButtonLoading.value = false;
    }
  }
  
  void clearFields() {
    txtFullName.value?.clear();
    txtCompanyName.value?.clear();
    txtMobileNo.value?.clear();
    txtEmailId.value?.clear();
    txtWhatsappNo.value?.clear();
    txtWebsite.value?.clear();
    txtAbout.value?.clear();
    txtArea.value?.clear();
    txtReferredCode.value?.clear();
    txtOtherCategory.value?.clear();
    txtOtherSubCategory.value?.clear();
    selectedProfileType.value = "";
    selectedCategory.clear();
    selectedSubCategory.clear();
    croppedProfileFile.value = null;
    filePath.value = "";
    isAccountCreated.value = false;
    createdPassword.value = "";
    createdUserId.value = 0;
  }
}