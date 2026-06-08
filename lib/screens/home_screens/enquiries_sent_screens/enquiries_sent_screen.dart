import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/controller/home_controller/enquiries_sent_controller.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_screens/enquiries_sent_screens/enquiries_sent_group_screen.dart';
import '../../../widget/dialogs.dart';

class EnquiriesSentScreen extends StatefulWidget {
  const EnquiriesSentScreen({super.key});

  @override
  State<EnquiriesSentScreen> createState() => EnquiriesSentScreenState();
}

class EnquiriesSentScreenState extends State<EnquiriesSentScreen> {
  EnquiriesSentController enquiriesSentController = Get.put(EnquiriesSentController());
  HomeController homeController = Get.put(HomeController());
  
  Timer? _autoRefreshTimer;
  String _currentStatus = "1";
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    
    // Start auto-refresh timer
    _startAutoRefresh();
    
    // Listen to tab changes
    enquiriesSentController.tabController.addListener(_handleTabChange);
  }
  
  void _handleTabChange() {
    if (!enquiriesSentController.tabController.indexIsChanging) {
      if (enquiriesSentController.tabController.index == 0) {
        _currentStatus = "1";
      } else {
        _currentStatus = "2";
      }
    }
  }
  
  void _startAutoRefresh() {
    // Auto-refresh every 3 seconds
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted && !_isRefreshing && !enquiriesSentController.isAutoRefreshing.value) {
        _autoRefreshData();
      }
    });
  }
  
  Future<void> _autoRefreshData() async {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    try {
      // Silently refresh both tabs data
      await Future.wait([
        enquiriesSentController.postSentApi("1", isAutoRefresh: true),
        enquiriesSentController.postSentApi("2", isAutoRefresh: true),
      ]);
      
      // Update home controller unread count
      await homeController.getSentEnquiriesUnreadCount("1");
      
    } catch (e) {
      debugPrint('Auto-refresh error: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    enquiriesSentController.tabController.removeListener(_handleTabChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      body: Obx(
        () => (enquiriesSentController.isLoading.value && 
               enquiriesSentController.openSentList.isEmpty && 
               enquiriesSentController.closeSentList.isEmpty)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                      children: [
                        TabBarView(
                          controller: enquiriesSentController.tabController,
                          children: [
                            _buildOpenTab(height),
                            _buildClosedTab(height),
                          ],
                        ),
                        // Auto-refresh indicator
                        if (enquiriesSentController.isAutoRefreshing.value)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ConstantColor.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
      ),
    );
  }
  
  Widget _buildOpenTab(double height) {
    return RefreshIndicator(
      onRefresh: () async {
        await enquiriesSentController.postSentApi("1", isAutoRefresh: false);
        await homeController.getSentEnquiriesUnreadCount("1");
      },
      backgroundColor: ConstantColor.whiteColor,
      color: ConstantColor.primary,
      child: enquiriesSentController.openSentList.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: Get.height / 2.8,
                ),
                Center(
                  child: Text(
                    ConstantString.dataNotFoundLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ConstantColor.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: enquiriesSentController.openSentList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final enquiry = enquiriesSentController.openSentList[index];
                final hasUnread = (enquiry['unread_reply_count'] != null && 
                                    enquiry['unread_reply_count'] > 0);
                
                return GestureDetector(
                  onTap: () async {
                    await Get.to(
                      () => EnquiriesSentGroupScreen(
                        userData: enquiry,
                        isChat: true,
                      ),
                      arguments: {
                        'enquiryId': enquiry['id'].toString(),
                        'user_id': enquiry['user_id']?.toString() ?? '',
                      },
                    )?.then((value) async {
                      // Refresh data when coming back
                      await enquiriesSentController.postSentApi("1", isAutoRefresh: false);
                      await homeController.getSentEnquiriesUnreadCount("1");
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8, 
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: hasUnread 
                          ? ConstantColor.primary.withOpacity(0.05)
                          : ConstantColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: hasUnread
                          ? Border.all(
                              color: ConstantColor.primary,
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${enquiry['category'] == null || enquiry['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiry['category']} (${enquiry['subcategory'] == null || enquiry['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiry['subcategory']})",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (hasUnread)
                                  Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      enquiry['unread_reply_count'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: () async {
                                    Dialogs.dialogs.areYouSureAlertDialog(
                                      context: context,
                                      title: 'Close Enquiry?',
                                      description: 'Do you want to close this enquiry?',
                                      onPressed: () async {
                                        Get.back();
                                        await enquiriesSentController.postCloseSentApi(
                                          enquiry['id'].toString()
                                        );
                                      },
                                    );
                                  },
                                  child: const SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Icon(
                                      Icons.close,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (enquiry['enq_text'] != null && 
                            enquiry['enq_text'].toString().trim().isNotEmpty) ...[
                          SizedBox(height: height * 0.01),
                          Text(
                            enquiry['enq_text'] ?? "",
                            style: TextStyle(
                              color: ConstantColor.blackColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: height * 0.01),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              enquiry['status'] ?? "",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: enquiry['status'] == 'Open'
                                    ? ConstantColor.greenColor
                                    : ConstantColor.grayColor,
                              ),
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy').format(
                                DateTime.parse(
                                  enquiry['created_at'] ?? DateTime.now().toString()
                                )
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: ConstantColor.grayColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Widget _buildClosedTab(double height) {
    return RefreshIndicator(
      onRefresh: () async {
        await enquiriesSentController.postSentApi("2", isAutoRefresh: false);
      },
      backgroundColor: ConstantColor.whiteColor,
      color: ConstantColor.primary,
      child: enquiriesSentController.closeSentList.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: Get.height / 2.8,
                ),
                Center(
                  child: Text(
                    ConstantString.dataNotFoundLabel,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ConstantColor.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            )
          : ListView.builder(
              itemCount: enquiriesSentController.closeSentList.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final enquiry = enquiriesSentController.closeSentList[index];
                
                return GestureDetector(
                  onTap: () async {
                    await Get.to(
                      () => EnquiriesSentGroupScreen(
                        userData: enquiry,
                        isChat: false,
                      ),
                      arguments: {
                        'enquiryId': enquiry['id'].toString(),
                        'user_id': enquiry['user_id']?.toString() ?? '',
                      },
                    )?.then((value) async {
                      await enquiriesSentController.postSentApi("2", isAutoRefresh: false);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20, 
                      vertical: 12,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8, 
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                      color: ConstantColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${enquiry['category'] == null || enquiry['category'].toString().trim().isEmpty ? 'Category ${ConstantString.naLabel}' : enquiry['category']} (${enquiry['subcategory'] == null || enquiry['subcategory'].toString().trim().isEmpty ? 'Sub Category ${ConstantString.naLabel}' : enquiry['subcategory']})",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: ConstantColor.blackColor,
                          ),
                        ),
                        if (enquiry['enq_text'] != null && 
                            enquiry['enq_text'].toString().trim().isNotEmpty) ...[
                          SizedBox(height: height * 0.01),
                          Text(
                            enquiry['enq_text'] ?? "",
                            style: TextStyle(
                              color: ConstantColor.blackColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        SizedBox(height: height * 0.01),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              enquiry['status'] ?? "",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: ConstantColor.grayColor,
                              ),
                            ),
                            Text(
                              DateFormat('dd-MM-yyyy').format(
                                DateTime.parse(
                                  enquiry['created_at'] ?? DateTime.now().toString()
                                )
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: ConstantColor.grayColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}