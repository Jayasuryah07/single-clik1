import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

import '../../constants/constant_color.dart';

class UpdateProfileController extends GetxController {
  final isLoading = false.obs;
  final isButtonLoading = false.obs;
  final isCategoryLoading = false.obs;

  final nameController = TextEditingController().obs;
  final companyNameController = TextEditingController().obs;
  final emailNameController = TextEditingController().obs;
  final profileTypeSelect = [].obs;

  final categoryList = [].obs;
  final categorySelect = {}.obs;

  final subCategoryList = [].obs;
  final subCategorySelect = {}.obs;

  final whatsappNumberController = TextEditingController().obs;
  final webSiteController = TextEditingController().obs;
  final aboutUsController = TextEditingController().obs;
  final areaController = TextEditingController().obs;

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

  Future postUpdateProfileApi(Map<String, String> body, String photo) async {
    isButtonLoading.value = true;
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(API.updateProfile));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll(body);
      debugPrint(photo);
      photo == "" ? null:request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          photo,
        ),
      );

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      debugPrint(responseDone.statusCode.toString());

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint("response: $body"
            " $responseData");
        if (responseData['code'] == 200) {
          ShowToast.showToast(
            responseData['msg'] ?? ConstantString.dataUpdatedSuccessfullyMsg,
            showSuccess: true,
          );
          Get.back(result: true);
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
        ShowToast.showToast(
          ConstantString.somethingWantWrongMsg,
          showSuccess: false,
        );
      }
    } on TimeoutException catch (e) {
      isButtonLoading.value = false;
      ShowToast.showToast(
        e.message.toString(),
        showSuccess: false,
      );
    } on SocketException catch (e) {
      isButtonLoading.value = false;
      ShowToast.showToast(
        e.message.toString(),
        showSuccess: false,
      );
    } on Error catch (e) {
      isButtonLoading.value = false;
      ShowToast.showToast(
        ConstantString.somethingWantWrongMsg,
        showSuccess: false,
      );
      debugPrint(e.toString());
    }
  }

  Future postCategoriesApi() async {
    try {
      isCategoryLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.categories));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(">>>>>>>>>>> ${responseDone.body}");
        categoryList.value = responseData['data'];
        if (categoryList.isNotEmpty) {
          categorySelect.value = categoryList[0];
          postSubCategoriesApi(categorySelect['id'].toString());
        }
        isCategoryLoading.value = false;
      } else {
        isCategoryLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: false,);
      }
    }
    catch (e) {
      isCategoryLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      debugPrint(e.toString());
    }
  }

  Future postSubCategoriesApi(String? categoryId) async {
    try {
      isCategoryLoading.value = true;
      final request =
          http.MultipartRequest('POST', Uri.parse(API.subcategories));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'category_id': categoryId!});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(">>>>sub>>>>>>> ${responseDone.body}");
        subCategoryList.value = responseData['data'];
        if (subCategoryList.isNotEmpty) {
          subCategorySelect.value = subCategoryList[0];
        }

        isCategoryLoading.value = false;
      } else {
        isCategoryLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: false,);
      }
    }
    // on TimeoutException catch (e) {
    //   isCategoryLoading.value = false;
    //   ShowToast.showToast(e.message.toString(),showSuccess: false,);
    // } on SocketException catch (e) {
    //   isCategoryLoading.value = false;
    //   ShowToast.showToast(e.message.toString(),showSuccess: false,);
    // }
    catch (e) {
      isCategoryLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      debugPrint(e.toString());
    }
  }
}
