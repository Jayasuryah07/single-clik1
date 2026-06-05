import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../services/api.dart';
import '../../utils/shar_preferences.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  RxList notificationDataList = [].obs;

  Future<void> getAllNotifications() async {
    try {
      isLoading.value = true;
      final request =
          http.MultipartRequest('POST', Uri.parse(API.notification));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      // request.fields.addAll({'profile_type': profileType!});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        if (responseData['code'] == 200) {
          notificationDataList.value = responseData['data'] ?? [];
          isLoading.value = false;
        } else {
          notificationDataList.value = [];
          isLoading.value = false;
          // ShowToast.showToast(
          //   responseData['msg'] ?? 'Something went wrong.',
          //   showSuccess: false,
          // );
        }
      } else {
        notificationDataList.value = [];
        isLoading.value = false;
        // ShowToast.showToast(
        //   ConstantString.somethingWantWrongMsg,
        //   showSuccess: false,
        // );
      }
    }
    // on TimeoutException catch (e) {
    //   isLoading.value = false;
    //   ShowToast.showToast(
    //     e.message.toString(),
    //     showSuccess: false,
    //   );
    // } on SocketException catch (e) {
    //   isLoading.value = false;
    //   ShowToast.showToast(
    //     e.message.toString(),
    //     showSuccess: false,
    //   );
    // }
    catch (e) {
      notificationDataList.value = [];
      isLoading.value = false;
      // ShowToast.showToast(
      //   'Something went wrong.',
      //   showSuccess: false,
      // );
      debugPrint(e.toString());
    }
  }
}
