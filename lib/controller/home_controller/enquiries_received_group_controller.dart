import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';

class EnquiriesSentGroupController extends GetxController {
  final isLoading = false.obs;

  final sentGroupList = [].obs;

  Future postGroupSentApi(String? enquiryId) async {
    try {
      isLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.groupSent));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token)}',
      });
      debugPrint('EnquiryId : $enquiryId');
      request.fields.addAll({'enquiry_id': enquiryId!});

      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);
      debugPrint(responseDone.body);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseDone.body);
        sentGroupList.value = responseData['data'];
        debugPrint('SenderGroupList ${sentGroupList.length}');
        isLoading.value = false;
      } else {
        isLoading.value = false;
        // ShowToast.showToast(
        //   responseData['msg'] ?? 'Something went wrong.',
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
      isLoading.value = false;
      // ShowToast.showToast(
      //   'Something went wrong.',
      //   showSuccess: false,
      // );
      debugPrint(e.toString());
    }
  }
}
