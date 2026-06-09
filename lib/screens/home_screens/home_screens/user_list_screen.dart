import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/controller/home_controller/user_list_controller.dart';
import 'package:single_clik/screens/home_screens/home_screens/user_details_screen.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:single_clik/utils/shar_preferences.dart';

import '../../../constants/constant_string.dart';

class UserListScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const UserListScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<UserListScreen> createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  UserListController userListController = Get.put(UserListController());

  // ── Fetch user's own name as the reference ─────────────────────────
  String _referrerName = '';

  @override
  void initState() {
    userListController.postUserListApi(widget.categoryId);
    _loadReferrerInfo();
    super.initState();
  }

  Future<void> _loadReferrerInfo() async {
    try {
      // First try to fetch from HomeController
      HomeController homeController = Get.find<HomeController>();
      String name = (homeController.userData['name'] ?? '').toString().trim();
      
      // If it's empty, try to get from SharedPreferences
      if (name.isEmpty) {
        String? userJson = await SharPreferences.getString(SharPreferences.userData);
        if (userJson != null && userJson.isNotEmpty) {
          var userMap = jsonDecode(userJson);
          name = (userMap['name'] ?? '').toString().trim();
        }
      }
      
      if (mounted) {
        setState(() {
          _referrerName = name;
        });
      }
    } catch (e) {
      debugPrint('Error loading user info: $e');
    }
  }

  // ── Beautiful WhatsApp-formatted message ─────────────────────────────────
  String _buildWhatsAppMessage() {
    final referLine = _referrerName.isNotEmpty
        ? '👤 *Invited by:* ${_referrerName.trim()}'
        : '';

    return '''
🌟 *SINGLE CLIK* 🌟
_Digital Network & Directory_

━━━━━━━━━━━━━━━━━━━━━

👋 Hey! I'm looking for *${widget.categoryName}* providers on *Single Clik* — but they aren't listed yet!

💼 *What is Single Clik?*
A powerful business directory where you can:
✅ Create your profile in minutes
✅ List your services & products
✅ Connect with clients instantly
✅ Get discovered locally & beyond

━━━━━━━━━━━━━━━━━━━━━
${referLine.isNotEmpty ? '$referLine\n━━━━━━━━━━━━━━━━━━━━━\n' : ''}
📲 *Join for FREE — Download Now:*
🔗 https://play.google.com/store/apps/details?id=com.singleclick.agsolution

_One tap. One profile. One click away._ ✨
''';
  }

  // ── Plain message for SMS / Email / Copy ────────────────────────────────
  String _buildPlainMessage() {
    final referLine = _referrerName.isNotEmpty
        ? 'Invited by: ${_referrerName.trim()}\n'
        : '';

    return '''SINGLE CLIK — Digital Network & Directory

Hey! I'm looking for "${widget.categoryName}" providers on Single Clik — but they aren't listed yet!

What is Single Clik?
A powerful business directory where you can:
- Create your profile in minutes
- List your services & products  
- Connect with clients instantly
- Get discovered locally & beyond

${referLine}
Join for FREE — Download Now:
https://play.google.com/store/apps/details?id=com.singleclick.agsolution

One tap. One profile. One click away.''';
  }

  // ── Email subject ────────────────────────────────────────────────────────
  String _buildEmailSubject() {
    return _referrerName.isNotEmpty
        ? '${_referrerName.trim()} invited you to Single Clik!'
        : 'You\'re invited to join Single Clik!';
  }

  // ── WhatsApp share ───────────────────────────────────────────────────────
  Future<void> _shareToWhatsApp() async {
    final msg = _buildWhatsAppMessage();
    final encoded = Uri.encodeComponent(msg);
    final androidUrl = 'whatsapp://send?text=$encoded';
    final iosUrl = 'https://wa.me/?text=$encoded';

    try {
      if (Platform.isIOS) {
        await launchUrl(Uri.parse(iosUrl), mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(Uri.parse(androidUrl), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      Share.share(msg);
    }
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────
  void _showInvitationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 55,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Invite to Single Clik',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ConstantColor.blackColor,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Share this preview with your contacts',
                style: TextStyle(
                  fontSize: 13,
                  color: ConstantColor.grayColor,
                ),
              ),

              const SizedBox(height: 18),

              // ── Preview card (what the recipient sees) ───────────────────
              _InvitePreviewCard(
                categoryName: widget.categoryName,
                referrerName: _referrerName,
              ),

              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Share Via',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // ── Share options row ────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildShareOption(
                    icon: Icons.chat_bubble_outline,
                    color: const Color(0xff25D366),
                    label: 'WhatsApp',
                    onTap: () async {
                      Navigator.pop(context);
                      await _shareToWhatsApp();
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.sms_outlined,
                    color: const Color(0xff0084FF),
                    label: 'SMS',
                    onTap: () async {
                      Navigator.pop(context);
                      final msg = _buildPlainMessage();
                      final uri = Uri(
                        scheme: 'sms',
                        queryParameters: {'body': msg},
                      );
                      try {
                        await launchUrl(uri);
                      } catch (_) {
                        Share.share(msg);
                      }
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.mail_outline_rounded,
                    color: const Color(0xffEA4335),
                    label: 'Email',
                    onTap: () async {
                      Navigator.pop(context);
                      final msg = _buildPlainMessage();
                      final uri = Uri(
                        scheme: 'mailto',
                        queryParameters: {
                          'subject': _buildEmailSubject(),
                          'body': msg,
                        },
                      );
                      try {
                        await launchUrl(uri);
                      } catch (_) {
                        Share.share(msg);
                      }
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.copy_all_rounded,
                    color: const Color(0xff5F6368),
                    label: 'Copy',
                    onTap: () {
                      Navigator.pop(context);
                      Clipboard.setData(ClipboardData(text: _buildWhatsAppMessage()));
                      ShowToast.showToast(
                        'Invitation copied to clipboard!',
                        showSuccess: true,
                      );
                    },
                  ),
                  _buildShareOption(
                    icon: Icons.more_horiz_rounded,
                    color: ConstantColor.primary,
                    label: 'More',
                    onTap: () {
                      Navigator.pop(context);
                      Share.share(_buildPlainMessage());
                    },
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.2), width: 1.5),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: ConstantColor.primaryGradient,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _showInvitationBottomSheet(context),
          ),
        ],
      ),
      body: Obx(
        () => userListController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await userListController.postUserListApi(widget.categoryId);
                },
                backgroundColor: ConstantColor.whiteColor,
                color: ConstantColor.primary,
                child: userListController.userList.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: ConstantColor.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.search_off_rounded,
                                  size: 70,
                                  color: ConstantColor.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'No Profiles Found',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "There are currently no businesses or service providers listed in '${widget.categoryName}'.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ConstantColor.grayColor,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: ConstantColor.bgColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        ConstantColor.grayColor.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  'Single Clik is extremely useful! If you know someone who provides these services, share this app and invite them to create an account in a single click.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        ConstantColor.blackColor.withOpacity(0.8),
                                    fontStyle: FontStyle.italic,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _showInvitationBottomSheet(context),
                                icon: const Icon(Icons.share,
                                    color: Colors.white),
                                label: const Text(
                                  'Invite Providers',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ConstantColor.greenColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 28, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ListView.builder(
                          itemCount: userListController.userList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                Get.to(() => UserDetailsScreen(
                                      id: userListController.userList[index]
                                              ['id']
                                          .toString(),
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: ConstantColor.whiteColor,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ConstantColor.primary,
                                          width: 2,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: AppImageAsset(
                                          image:
                                              '${ConstantString.userImgUrlPath}${userListController.userList[index]['photo']}',
                                          isFile: false,
                                          fit: BoxFit.cover,
                                          height: width / 3.5,
                                          width: width / 3.5,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: width * 0.02),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            userListController.userList[index]
                                                            ['name'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]['name']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Name ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]['name']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: ConstantColor.primary,
                                            ),
                                          ),
                                          SizedBox(height: width / 90),
                                          Text(
                                            userListController.userList[index]
                                                            ['company_name'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]
                                                            ['company_name']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Company Name ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]
                                                        ['company_name']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: ConstantColor.primaryDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: width / 90),
                                          Container(
                                            width: width,
                                            margin: EdgeInsets.only(
                                                right: Get.width / 30),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(1000),
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  Colors.deepOrange
                                                      .withAlpha(0),
                                                  Colors.deepOrange.shade900
                                                      .withAlpha(128),
                                                ],
                                              ),
                                            ),
                                            padding: EdgeInsets.fromLTRB(
                                              width / 90,
                                              width / 90,
                                              width / 40,
                                              width / 90,
                                            ),
                                            child: Text(
                                              userListController.userList[index]
                                                              ['category'] ==
                                                          null ||
                                                      userListController
                                                          .userList[index]
                                                              ['category']
                                                          .toString()
                                                          .trim()
                                                          .isEmpty
                                                  ? 'Category ${ConstantString.naLabel}'
                                                  : userListController
                                                      .userList[index]
                                                          ['category']
                                                      .toString()
                                                      .trim(),
                                              style: const TextStyle(
                                                fontSize: 19,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepOrange,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: width / 90),
                                          Text(
                                            userListController.userList[index]
                                                            ['subcategory'] ==
                                                        null ||
                                                    userListController
                                                        .userList[index]
                                                            ['subcategory']
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                                ? 'Sub Category ${ConstantString.naLabel}'
                                                : userListController
                                                    .userList[index]
                                                        ['subcategory']
                                                    .toString()
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Beautiful invite preview card shown in the bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _InvitePreviewCard extends StatelessWidget {
  final String categoryName;
  final String referrerName;

  const _InvitePreviewCard({
    required this.categoryName,
    required this.referrerName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [ConstantColor.primary, ConstantColor.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle decorative circles in background
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header row: logo + brand + FREE badge ───────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/sc_logo_new.png',
                        height: 30,
                        width: 30,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.touch_app_rounded,
                          color: ConstantColor.primary,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'SINGLE CLIK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        'FREE JOIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Divider ──────────────────────────────────────────────
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),

                const SizedBox(height: 14),

                // ── Category looking for ─────────────────────────────────
                Row(
                  children: [
                    const Text('🔍 ', style: TextStyle(fontSize: 14)),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4),
                          children: [
                            const TextSpan(text: 'Looking for '),
                            TextSpan(
                              text: categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const TextSpan(
                                text: ' providers? They\'re not on Single Clik yet!'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Feature bullets ──────────────────────────────────────
                _featureLine('✅', 'Create profile in minutes'),
                const SizedBox(height: 5),
                _featureLine('✅', 'List services & connect with clients'),
                const SizedBox(height: 5),
                _featureLine('✅', 'Get discovered locally & beyond'),

                const SizedBox(height: 14),

                // ── Divider ──────────────────────────────────────────────
                Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.15),
                ),

                const SizedBox(height: 12),

                // ── Referrer info (if available) ─────────────────────────
                if (referrerName.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Invited by ',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        referrerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // ── CTA strip ────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.download_rounded,
                          color: Color(0xff01875f), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Download on Google Play',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              'Single Clik — Free',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: ConstantColor.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          Icon(Icons.star, color: Colors.amber, size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureLine(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85),
            fontSize: 12,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}