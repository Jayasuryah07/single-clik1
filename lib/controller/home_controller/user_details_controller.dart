import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

class UserDetailsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;

  late TabController tabController;

  Map userDetails = {}.obs;
  Map userDetailsProduct = {}.obs;
  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    super.onInit();
  }

  Future postUserByIdApi(String? userId) async {
    try {
      isLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.userById));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'user_id': userId!});

      debugPrint(API.userById);
      debugPrint(await SharPreferences.getString(SharPreferences.token));
      debugPrint(request.fields.toString());

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        log(">>>>sub>>>>>>> ${responseDone.body}");
        userDetails = responseData['data'];
        userDetailsProduct = responseData;
        isLoading.value = false;
      } else {
        isLoading.value = false;
        // ShowToast.showToast(responseData['msg'] ?? 'Something went wrong.',showSuccess: false,);
      }
    }
    // on TimeoutException catch (e) {
    //   isLoading.value = false;
    //   ShowToast.showToast(e.message.toString(),showSuccess: false,);
    // } on SocketException catch (e) {
    //   isLoading.value = false;
    //   ShowToast.showToast(e.message.toString(),showSuccess: false,);
    // }
    catch (e) {
      isLoading.value = false;
      // ShowToast.showToast('Something went wrong.',showSuccess: false,);
      debugPrint(e.toString());
    }
  }
}
