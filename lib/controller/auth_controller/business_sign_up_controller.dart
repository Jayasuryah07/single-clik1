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
  RxList categoryDataList = [].obs;
  RxMap selectedCategory = {}.obs;
  RxList subCategoryDataList = [].obs;
  RxMap selectedSubCategory = {}.obs;
  RxString filePath = "".obs;

  RxBool isButtonLoading = false.obs;
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

  Future<List> getCategoryDataApi() async {
    try {
      isButtonLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.categories));
      // request.headers.addAll({
      //   'Accept': 'application/json',
      // });
      // request.fields.addAll(bodyParams);

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        return responseData['code'] != 200
            ? []
            : List.from(responseData['data'] ?? []);
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<List> getSubCategoryDataCategoryIdWiseApi({
    required Map<String, String> parameters,
  }) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(API.subcategories));
      // request.headers.addAll({
      //   'Accept': 'application/json',
      // });
      request.fields.addAll(parameters);

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        return responseData['code'] != 200
            ? []
            : List.from(responseData['data'] ?? []);
      } else {
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  Future<Map> postBusinessSignUpApi(
      Map<String, String> bodyParams, String photo) async {
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(API.businessSignUp));
      // request.headers.addAll({
      //   'Accept': 'application/json',
      // });
      request.fields.addAll(bodyParams);
      // photo.trim().isEmpty ? null : request.files.add(await http.MultipartFile.fromPath('photo', photo,filename: photo.trim().split('/').isEmpty ? null : photo.trim().split('/').last));

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseData.runtimeType.toString());
        if (responseData['code'] == 200) {
          return responseData;
        } else {
          throw '${responseData['msg'] ?? ConstantString.somethingWantWrongMsg}';
        }
      } else {
        // isButtonLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: true,);
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on SocketException catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on Error catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      // debugPrint(e.toString());
      throw e.toString();
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
      photo == "" ? null:request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photo,
        ),
      );

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseData.runtimeType.toString());
        if (responseData['code'] == 200) {
          return responseData;
        } else {
          throw '${responseData['msg'] ?? ConstantString.somethingWantWrongMsg}';
        }
      } else {
        // isButtonLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: true,);
        throw ConstantString.somethingWantWrongMsg;
      }
    } on TimeoutException catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on SocketException catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast(e.message.toString(),showSuccess: false,);
      throw e.message.toString();
    } on Error catch (e) {
      // isButtonLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      // debugPrint(e.toString());
      throw e.toString();
    }
  }
}
