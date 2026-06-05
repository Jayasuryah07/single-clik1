import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:single_clik/constants/show_toast.dart';

import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';import '../../constants/constant_string.dart';

class ChatReceivedController extends GetxController {
  final isLoading = true.obs;

  final userId = "".obs;

  final charController = TextEditingController().obs;

  final scrollController = ScrollController().obs;
  final chatList = [].obs;

  late Timer timer;

  void getChatTimer() {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        postChatApi();
      },
    );
  }

  @override
  void onInit() {
    getChatTimer();
    postChatApi();
    super.onInit();
  }

  Future postChatApi() async {
    var bodyParams = {
      'enquiry_id': Get.arguments['id'].toString(),
      'reply_id': Get.arguments['user_id'].toString()
    };
    try {
      final request = http.MultipartRequest('POST', Uri.parse(API.replyChat));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token) ?? ''}',
      });
      request.fields.addAll(bodyParams);
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(responseData['data'].toString());
        chatList.value = responseData['data'];
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

  Future postSendChatApi(Map<String, dynamic> userMap) async {
    var bodyParams = {
      'enquiry_id': Get.arguments['id'].toString(),
      'reply_id': userMap['user_id'].toString(),
      'text': charController.value.text
    };
    try {
      isLoading.value = true;
      final request = http.MultipartRequest('POST', Uri.parse(API.createReply));
      request.headers.addAll({
        'Authorization': 'Bearer ${await SharPreferences.getString(SharPreferences.token) ?? ''}',
      });
      request.fields.addAll(bodyParams);
      var res = await request.send();
      var responseDone = await http.Response.fromStream(res);

      debugPrint(responseDone.body);
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint(bodyParams.toString());
        if (responseData['code'] == 200) {
          Future.delayed(const Duration(milliseconds: 500), () {
            scrollController.value.animateTo(
              scrollController.value.position.maxScrollExtent,
              duration: const Duration(microseconds: 800),
              curve: Curves.fastOutSlowIn,
            );
          });
          isLoading.value = false;
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
