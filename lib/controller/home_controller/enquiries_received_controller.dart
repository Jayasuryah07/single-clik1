import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

class EnquiriesReceivedController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  late TabController tabController;

  final openReceivedList = [].obs;
  final closeReceivedList = [].obs;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    postReceivedApi("1");
    postReceivedApi("2");
    super.onInit();
  }

  Future postReceivedApi(String enquiriesType) async {
    try {
      isLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.received));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'enquiries_type': enquiriesType});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      debugPrint(responseDone.body);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        if (enquiriesType == "1") {
          openReceivedList.value = responseData['data'];
        } else if (enquiriesType == "2") {
          closeReceivedList.value = responseData['data'];
        }
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
