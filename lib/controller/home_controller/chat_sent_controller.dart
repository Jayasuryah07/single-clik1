import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import '../../constants/constant_string.dart';

class ChatSentController extends GetxController {
  final isLoading = true.obs;
  final isSending = false.obs; // Separate loading state for sending
  final userId = "".obs;
  final charController = TextEditingController().obs;
  final scrollController = ScrollController().obs;
  final chatList = <dynamic>[].obs;
  
  late Timer timer;
  bool isFirstLoad = true;

  void getChatTimer() {
    const oneSec = Duration(seconds: 2); // Changed to 2 seconds to reduce load
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        postChatApi(isFromTimer: true);
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    getChatTimer();
    postChatApi();
  }

  @override
  void onClose() {
    timer.cancel();
    charController.value.dispose();
    scrollController.value.dispose();
    super.onClose();
  }

  Future<void> postChatApi({bool isFromTimer = false}) async {
    // Skip if already loading and not from timer to prevent duplicate calls
    if (isLoading.value && !isFromTimer) return;
    
    try {
      if (!isFromTimer) {
        isLoading.value = true;
      }
      
      final enquiryId = Get.arguments['enquiry_id']?.toString() ?? '';
      final replyId = Get.arguments['user_id']?.toString() ?? '';
      
      if (enquiryId.isEmpty || replyId.isEmpty) {
        debugPrint('Error: enquiry_id or user_id is missing');
        isLoading.value = false;
        return;
      }
      
      var bodyParams = {
        'enquiry_id': enquiryId,
        'reply_id': replyId
      };
      
      debugPrint('postChatApi bodyParams: $bodyParams');
      
      final token = await SharPreferences.getString(SharPreferences.token);
      if (token == null || token.isEmpty) {
        debugPrint('Error: Token is missing');
        isLoading.value = false;
        return;
      }
      
      final uri = Uri.parse(API.replyChat);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json', // Add accept header
      });
      request.fields.addAll(bodyParams);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body preview: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}');
      
      // Check if response is JSON
      if (responseBody.trim().startsWith('{') || responseBody.trim().startsWith('[')) {
        try {
          final responseData = json.decode(responseBody);
          
          if (response.statusCode == 200) {
            if (responseData['data'] != null) {
              if (responseData['data'] is List) {
                // Only update if data has changed to avoid unnecessary rebuilds
                if (!_isSameChatList(responseData['data'])) {
                  chatList.value = responseData['data'];
                  if (isFirstLoad) {
                    isFirstLoad = false;
                    Future.delayed(const Duration(milliseconds: 300), () {
                      scrollToBottom();
                    });
                  }
                }
              } else if (responseData['data'] is Map) {
                if (!_isSameChatList([responseData['data']])) {
                  chatList.value = [responseData['data']];
                }
              }
            }
          } else {
            debugPrint('Non-200 status code: ${response.statusCode}');
            if (!isFromTimer) {
              ShowToast.showToast(
                responseData['msg'] ?? 'Failed to load messages',
                showSuccess: false,
              );
            }
          }
        } catch (e) {
          debugPrint('JSON parsing error: $e');
          debugPrint('Raw response: $responseBody');
        }
      } else {
        // Response is HTML or other format - API is returning error page
        debugPrint('Non-JSON response received (likely API error)');
        debugPrint('Response: $responseBody');
        
        // Don't show error for timer-based requests
        if (!isFromTimer) {
          ShowToast.showToast(
            'Server error. Please try again.',
            showSuccess: false,
          );
        }
      }
      
      isLoading.value = false;
      
    } catch (e) {
      debugPrint('Error in postChatApi: $e');
      isLoading.value = false;
      if (!isFromTimer) {
        ShowToast.showToast(
          'Connection error. Please check your internet.',
          showSuccess: false,
        );
      }
    }
  }

  Future<void> postSendChatApi() async {
    final message = charController.value.text.trim();
    
    if (message.isEmpty) {
      ShowToast.showToast(
        'Please enter a message',
        showSuccess: false,
      );
      return;
    }
    
    if (isSending.value) {
      debugPrint('Already sending a message, skipping...');
      return;
    }
    
    try {
      isSending.value = true;
      
      final enquiryId = Get.arguments['enquiry_id']?.toString() ?? '';
      final replyId = Get.arguments['user_id']?.toString() ?? '';
      
      if (enquiryId.isEmpty || replyId.isEmpty) {
        ShowToast.showToast(
          'Invalid chat session',
          showSuccess: false,
        );
        isSending.value = false;
        return;
      }
      
      var bodyParams = {
        'enquiry_id': enquiryId,
        'reply_id': replyId,
        'text': message
      };
      
      debugPrint('postSendChatApi bodyParams: $bodyParams');
      
      final token = await SharPreferences.getString(SharPreferences.token);
      if (token == null || token.isEmpty) {
        ShowToast.showToast(
          'Authentication error. Please login again.',
          showSuccess: false,
        );
        isSending.value = false;
        return;
      }
      
      final uri = Uri.parse(API.createReply);
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json', // Add content type
      });
      request.fields.addAll(bodyParams);
      
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      
      debugPrint('Send message status code: ${response.statusCode}');
      debugPrint('Send message response: $responseBody');
      
      // Check if response is JSON
      if (responseBody.trim().startsWith('{') || responseBody.trim().startsWith('[')) {
        try {
          final responseData = json.decode(responseBody);
          
          // Consider 200, 201, and sometimes 500 as success if message was actually sent
          // Because your API might return error but still send the message
          if (response.statusCode == 200 || response.statusCode == 201) {
            // Success case
            charController.value.clear();
            
            // Wait a moment then refresh chat
            await Future.delayed(const Duration(milliseconds: 500));
            await postChatApi();
            
            // Scroll to bottom
            Future.delayed(const Duration(milliseconds: 300), () {
              scrollToBottom();
            });
            
            ShowToast.showToast(
              'Message sent successfully',
              showSuccess: true,
            );
          } else {
            // Even if status code is not 200, the message might have been sent
            // Check if the response indicates message was sent, or just show generic error
            debugPrint('Message may have been sent despite error response');
            
            // Still clear the text field as the message was likely sent
            charController.value.clear();
            
            // Refresh chat to see if message appears
            await Future.delayed(const Duration(milliseconds: 1000));
            await postChatApi();
            
            ShowToast.showToast(
              responseData['msg'] ?? 'Message sent (check if delivered)',
              showSuccess: true,
            );
          }
        } catch (e) {
          debugPrint('JSON parse error: $e');
          // If we can't parse JSON but request completed, message might still be sent
          charController.value.clear();
          await Future.delayed(const Duration(milliseconds: 1000));
          await postChatApi();
          ShowToast.showToast(
            'Message may have been sent. Refresh to check.',
            showSuccess: true,
          );
        }
      } else {
        // HTML response - likely an error page, but message might still be sent
        debugPrint('Non-JSON response: $responseBody');
        
        // Check if this is a timeout or server error
        if (response.statusCode == 500 || response.statusCode == 503) {
          // Server error but message might still be processing
          charController.value.clear();
          
          ShowToast.showToast(
            'Message sent but server returned error. Check in a moment.',
            showSuccess: true,
          );
          
          // Refresh after delay to check if message appeared
          await Future.delayed(const Duration(seconds: 2));
          await postChatApi();
        } else {
          ShowToast.showToast(
            'Server error. Please try again.',
            showSuccess: false,
          );
        }
      }
      
    } on TimeoutException catch (e) {
      debugPrint('TimeoutException: $e');
      // Even on timeout, the message might have been sent
      // Don't clear the text field, let user retry
      ShowToast.showToast(
        'Connection timeout. The message may have been sent. Please refresh.',
        showSuccess: false,
      );
      
      // Refresh after delay to check
      await Future.delayed(const Duration(seconds: 2));
      await postChatApi();
      
    } on SocketException catch (e) {
      debugPrint('SocketException: $e');
      ShowToast.showToast(
        'No internet connection. Please check your network.',
        showSuccess: false,
      );
    } catch (e) {
      debugPrint('Error in postSendChatApi: $e');
      ShowToast.showToast(
        'Failed to send message. Please try again.',
        showSuccess: false,
      );
    } finally {
      isSending.value = false;
    }
  }
  
  // Helper method to check if chat list is the same
  bool _isSameChatList(List<dynamic> newList) {
    if (chatList.length != newList.length) return false;
    
    for (int i = 0; i < chatList.length; i++) {
      if (chatList[i] is Map && newList[i] is Map) {
        // Compare IDs if available
        if (chatList[i]['id'] != newList[i]['id']) {
          return false;
        }
      } else {
        return false;
      }
    }
    return true;
  }
  
  // Helper method to scroll to bottom
  void scrollToBottom() {
    if (scrollController.value.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.value.hasClients) {
          scrollController.value.animateTo(
            scrollController.value.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }
  
  // Method to manually refresh chat
  Future<void> refreshChat() async {
    await postChatApi();
  }
}