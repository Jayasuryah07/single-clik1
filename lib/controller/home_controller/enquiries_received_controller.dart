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
  final isAutoRefreshing = false.obs;
  late TabController tabController;

  final openReceivedList = [].obs;
  final closeReceivedList = [].obs;

  late Timer timer;
  bool _isDisposed = false;

  void getReceivedTimer() {
    const period = Duration(seconds: 4);
    timer = Timer.periodic(
      period,
      (Timer timer) {
        if (!_isDisposed) {
          postReceivedApi("1", isAutoRefresh: true);
          postReceivedApi("2", isAutoRefresh: true);
        }
      },
    );
  }

  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    postReceivedApi("1");
    postReceivedApi("2");
    getReceivedTimer();
    super.onInit();
  }

  Future postReceivedApi(String enquiriesType, {bool isAutoRefresh = false}) async {
    if (_isDisposed) return;
    try {
      if (!isAutoRefresh) {
        isLoading.value = true;
      } else {
        isAutoRefreshing.value = true;
      }
      final request = http.MultipartRequest('POST', Uri.parse(API.received));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      request.fields.addAll({'enquiries_type': enquiriesType});

      var res = await request.send().timeout(const Duration(seconds: 10));
      var responseDone = await http.Response.fromStream(res);

      if (_isDisposed) return;

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        if (responseData['data'] != null) {
          List<dynamic> newData = responseData['data'];
          if (enquiriesType == "1") {
            openReceivedList.value = newData;
          } else if (enquiriesType == "2") {
            closeReceivedList.value = newData;
          }
        }
      }
    }
    catch (e) {
      debugPrint('Error in postReceivedApi: $e');
    } finally {
      if (!_isDisposed) {
        if (!isAutoRefresh) {
          isLoading.value = false;
        } else {
          isAutoRefreshing.value = false;
        }
      }
    }
  }

  @override
  void onClose() {
    _isDisposed = true;
    timer.cancel();
    tabController.dispose();
    super.onClose();
  }
}
