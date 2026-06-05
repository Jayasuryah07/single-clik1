import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

class EnquiriesSentController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  late TabController tabController;

  final openSentList = [].obs;
  final closeSentList = [].obs;
  @override
  void onInit() {
    postSentApi("1");
    postSentApi("2");
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);

    super.onInit();
  }

  Future postSentApi(String? enquiriesType) async {
    try {
      isLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.sent));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'enquiries_type': enquiriesType!});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      debugPrint(responseDone.body);
      if (res.statusCode == 200) {

        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        if (enquiriesType == "1") {
          openSentList.value = responseData['data'];
        } else if (enquiriesType == "2") {
          closeSentList.value = responseData['data'];
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

  Future postCloseSentApi(String? enquiryId) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(API.sentClose));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'enquiry_id': enquiryId!});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      debugPrint(responseDone.body);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint('Response Done: ${responseDone.body}');
        if (responseData['code'] == 200) {
          postSentApi("1");
          postSentApi("2");
          isLoading.value = false;
          ShowToast.showToast(
            responseData['msg'] ?? ConstantString.enquireCloseSuccessfullyMsg,
            showSuccess: true,
          );
        } else {
          isLoading.value = false;
          ShowToast.showToast(
            responseData['msg'] ?? ConstantString.somethingWantWrongMsg,
            showSuccess: false,
          );
        }
      } else {
        isLoading.value = false;
        ShowToast.showToast(
          ConstantString.somethingWantWrongMsg,
          showSuccess: false,
        );
      }
    } on TimeoutException catch (e) {
      isLoading.value = false;
      ShowToast.showToast(
        e.message.toString(),
        showSuccess: false,
      );
    } on SocketException catch (e) {
      isLoading.value = false;
      ShowToast.showToast(
        e.message.toString(),
        showSuccess: false,
      );
    } on Error catch (e) {
      isLoading.value = false;
      ShowToast.showToast(
        ConstantString.somethingWantWrongMsg,
        showSuccess: false,
      );
      debugPrint(e.toString());
    }
  }
}
