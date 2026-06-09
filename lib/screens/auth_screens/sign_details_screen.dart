import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/auth_controller/sign_details_controller.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_text_field.dart';

class SignDetailsScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const SignDetailsScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
  });

  @override
  State<SignDetailsScreen> createState() => _SignDetailsScreenState();
}

class _SignDetailsScreenState extends State<SignDetailsScreen>
    with SingleTickerProviderStateMixin {
  SignDetailsController signDetailsController = Get.put(SignDetailsController());
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.whiteColor,
      body: Obx(
        () => signDetailsController.isLoading.value
            ? Center(
                child: CircularProgressIndicator(
                  color: ConstantColor.primary,
                ),
              )
            : Stack(
                children: [
                  // ── Animated Background Bubbles ──────────────
                  _buildAnimatedBackgroundBubbles(height, width),

                  // ── Main Content ─────────────────────────────
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.05),

                          // Back Button
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    ConstantColor.primary.withOpacity(0.15),
                                    ConstantColor.primaryDark.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: ConstantColor.primary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: ConstantColor.primary.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: ConstantColor.primary,
                                size: 24,
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.02),

                          // Welcome Section
                          Center(
                            child: TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: child,
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    "WELCOME TO",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ConstantColor.grayColor,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  SizedBox(height: height * 0.008),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (bounds) =>
                                            LinearGradient(
                                          colors: [
                                            ConstantColor.primary,
                                            ConstantColor.primaryDark,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ).createShader(bounds),
                                        child: const Text(
                                          "SINGLE",
                                          style: TextStyle(
                                            fontSize: 38,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        " CLIK",
                                        style: TextStyle(
                                          fontSize: 38,
                                          color: ConstantColor.primaryDark,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Hello Message Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ConstantColor.primary.withOpacity(0.08),
                                  ConstantColor.primaryDark.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: ConstantColor.primary.withOpacity(0.2),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ConstantColor.primary.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello! 👋",
                                  style: TextStyle(
                                    fontSize: 24,
                                    color: ConstantColor.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: height * 0.005),
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    fontSize: 28,
                                    color: ConstantColor.blackColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: height * 0.01),
                                Text(
                                  "Let's complete your profile to get started",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: ConstantColor.grayColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: height * 0.03),

                          // Email Field
                          _buildLabelWithAsterisk("Email ID"),
                          SizedBox(height: height * 0.008),
                          _buildTextField(
                            controller: signDetailsController.emailController.value,
                            hint: "Enter your email address",
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            action: TextInputAction.next,
                          ),

                          SizedBox(height: height * 0.02),

                          // Area Field
                          _buildLabelWithAsterisk("Area"),
                          SizedBox(height: height * 0.008),
                          _buildTextField(
                            controller: signDetailsController.areaController.value,
                            hint: "Enter your area (e.g., Bangalore, Mumbai)",
                            icon: Icons.location_on_outlined,
                            keyboardType: TextInputType.text,
                            action: TextInputAction.next,
                          ),

                          SizedBox(height: height * 0.02),

                          // Referred Code Field
                          Text(
                            "Referred Code (Optional)",
                            style: TextStyle(
                              fontSize: 16,
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: height * 0.008),
                          _buildTextField(
                            controller: signDetailsController.referredCodeController.value,
                            hint: "Enter referred code (if any)",
                            icon: Icons.card_giftcard_outlined,
                            keyboardType: TextInputType.text,
                            action: TextInputAction.done,
                          ),

                          SizedBox(height: height * 0.025),

                          // Photo Upload Section
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  ConstantColor.primary.withOpacity(0.05),
                                  ConstantColor.primaryDark.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: ConstantColor.primary.withOpacity(0.15),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: ConstantColor.primary.withOpacity(0.08),
                                  blurRadius: 15,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Upload your Photo",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: ConstantColor.blackColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: height * 0.005),
                                    Text(
                                      "Optional • Max 5MB",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: ConstantColor.grayColor,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                    );
                                    if (image != null) {
                                      signDetailsController.cropImage(image);
                                    }
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    height: 85,
                                    width: 85,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white,
                                          ConstantColor.primary.withOpacity(0.05),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: ConstantColor.primary.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ConstantColor.primary.withOpacity(0.15),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: signDetailsController.croppedProfileFile != null &&
                                            signDetailsController.croppedProfileFile!.value.path.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.file(
                                              File(signDetailsController.croppedProfileFile!.value.path),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: ConstantColor.primary,
                                                  size: 28,
                                                ),
                                                SizedBox(height: height * 0.005),
                                                Text(
                                                  "Add Photo",
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: ConstantColor.primary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: height * 0.04),

                          // Continue Button
                          TweenAnimationBuilder(
                            tween: Tween<double>(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, double value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: AppButton(
                              onTap: () async {
                                if (signDetailsController.emailController.value.text.isEmpty) {
                                  ShowToast.showToast("Please Enter Email ID", showSuccess: false);
                                } else if (!RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(signDetailsController.emailController.value.text.trim())) {
                                  ShowToast.showToast("Please Enter Valid Email ID", showSuccess: false);
                                } else if (signDetailsController.areaController.value.text.isEmpty) {
                                  ShowToast.showToast("Please Enter Area", showSuccess: false);
                                } else {
                                  Map<String, String> bodyParams = {
                                    'person_name': widget.name.trim(),
                                    'person_mobile': widget.phoneNumber.trim(),
                                    'person_email': signDetailsController.emailController.value.text.trim(),
                                    'person_area': signDetailsController.areaController.value.text.trim(),
                                    'referred_by_code': signDetailsController.referredCodeController.value.text.trim(),
                                    'user_type': '1',
                                  };
                                  await signDetailsController.postSignUpApi(
                                    bodyParams,
                                    signDetailsController.croppedProfileFile != null &&
                                            signDetailsController.croppedProfileFile!.value.path.isNotEmpty
                                        ? signDetailsController.croppedProfileFile!.value.path.trim()
                                        : signDetailsController.filePath.value.trim(),
                                  );
                                }
                              },
                              isLoading: signDetailsController.isButtonLoading.value,
                              title: "Continue",
                            ),
                          ),

                          SizedBox(height: height * 0.05),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Reusable text field ───────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    required TextInputAction action,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffF7F8FA), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffEBEFF2), width: 1),
        boxShadow: [
          BoxShadow(
            color: ConstantColor.primary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: action,
        style: TextStyle(fontSize: 16, color: ConstantColor.blackColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: ConstantColor.grayColor),
          prefixIcon: Icon(icon, color: ConstantColor.primary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  // ── Label with red asterisk ───────────────────────────────────────────────

  Widget _buildLabelWithAsterisk(String label) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 16,
              color: ConstantColor.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(
            text: " *",
            style: TextStyle(
              fontSize: 16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Background bubbles ────────────────────────────────────────────────────

  Widget _buildAnimatedBackgroundBubbles(double height, double width) {
    return Stack(
      children: [
        // ════════════════════════════════════════════
        // TOP SECTION — rich cluster of bubbles
        // ════════════════════════════════════════════

        // Large anchor blob — top left, bleeds off screen
        _bubble(
          left: -width * 0.18,
          top: -height * 0.06,
          size: height * 0.32,
          color: ConstantColor.primary,
          opacity: 0.10,
        ),

        // Large anchor blob — top right, bleeds off screen
        _bubble(
          right: -width * 0.14,
          top: -height * 0.04,
          size: height * 0.28,
          color: ConstantColor.primaryDark,
          opacity: 0.08,
        ),

        // Animated floating blob — top left mid
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              sin(_animationController.value * 2 * pi) * 8,
              cos(_animationController.value * 1.5 * pi) * 8,
            ),
            child: _bubble(
              left: width * 0.04,
              top: height * 0.04,
              size: height * 0.16,
              color: ConstantColor.primary,
              opacity: 0.14,
            ),
          ),
        ),

        // Animated floating blob — top right mid
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              cos(_animationController.value * 1.8 * pi) * 10,
              sin(_animationController.value * 2.2 * pi) * 10,
            ),
            child: _bubble(
              right: width * 0.06,
              top: height * 0.06,
              size: height * 0.14,
              color: ConstantColor.primaryDark,
              opacity: 0.12,
            ),
          ),
        ),

        // Medium bubble — upper left accent
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              sin(_animationController.value * 2.5 * pi + 1) * 6,
              cos(_animationController.value * 1.9 * pi + 1) * 6,
            ),
            child: _bubble(
              left: width * 0.22,
              top: height * 0.01,
              size: height * 0.10,
              color: ConstantColor.primary,
              opacity: 0.16,
            ),
          ),
        ),

        // Medium bubble — upper right accent
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              cos(_animationController.value * 2.1 * pi + 2) * 7,
              sin(_animationController.value * 1.6 * pi + 2) * 7,
            ),
            child: _bubble(
              right: width * 0.24,
              top: height * 0.02,
              size: height * 0.09,
              color: ConstantColor.primaryDark,
              opacity: 0.14,
            ),
          ),
        ),

        // Small sparkle — top left inner
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              sin(_animationController.value * 3 * pi) * 4,
              cos(_animationController.value * 2.8 * pi) * 4,
            ),
            child: _bubble(
              left: width * 0.14,
              top: height * 0.10,
              size: height * 0.06,
              color: ConstantColor.primary,
              opacity: 0.22,
            ),
          ),
        ),

        // Small sparkle — top center
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              cos(_animationController.value * 2.4 * pi + 0.5) * 5,
              sin(_animationController.value * 1.8 * pi + 0.5) * 5,
            ),
            child: _bubble(
              left: width * 0.42,
              top: -height * 0.01,
              size: height * 0.07,
              color: ConstantColor.primary,
              opacity: 0.13,
            ),
          ),
        ),

        // Small sparkle — top right inner
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              sin(_animationController.value * 2.3 * pi + 1.5) * 5,
              cos(_animationController.value * 3.1 * pi + 1.5) * 5,
            ),
            child: _bubble(
              right: width * 0.14,
              top: height * 0.12,
              size: height * 0.055,
              color: ConstantColor.primaryDark,
              opacity: 0.20,
            ),
          ),
        ),

        // Tiny glowing dot — top far left
        _tinyBubble(
          left: width * 0.06,
          top: height * 0.17,
          size: height * 0.025,
          color: ConstantColor.primary,
          opacity: 0.45,
        ),

        // Tiny glowing dot — top center-left
        _tinyBubble(
          left: width * 0.32,
          top: height * 0.07,
          size: height * 0.020,
          color: ConstantColor.primaryDark,
          opacity: 0.38,
        ),

        // Tiny glowing dot — top center-right
        _tinyBubble(
          right: width * 0.30,
          top: height * 0.08,
          size: height * 0.022,
          color: ConstantColor.primary,
          opacity: 0.40,
        ),

        // Tiny glowing dot — top far right
        _tinyBubble(
          right: width * 0.07,
          top: height * 0.18,
          size: height * 0.024,
          color: ConstantColor.primaryDark,
          opacity: 0.42,
        ),

        // Extra tiny particles — top area
        _particle(left: width * 0.26, top: height * 0.03, size: height * 0.008, color: ConstantColor.primary),
        _particle(right: width * 0.28, top: height * 0.04, size: height * 0.007, color: ConstantColor.primaryDark),
        _particle(left: width * 0.50, top: height * 0.06, size: height * 0.006, color: ConstantColor.primary),
        _particle(right: width * 0.45, top: height * 0.14, size: height * 0.008, color: ConstantColor.primaryDark),
        _particle(left: width * 0.08, top: height * 0.22, size: height * 0.007, color: ConstantColor.primary),
        _particle(right: width * 0.10, top: height * 0.20, size: height * 0.006, color: ConstantColor.primaryDark),

        // ════════════════════════════════════════════
        // BOTTOM SECTION — light, minimal
        // ════════════════════════════════════════════

        // Bottom left
        _bubble(
          left: -width * 0.08,
          bottom: height * 0.12,
          size: height * 0.16,
          color: ConstantColor.primary,
          opacity: 0.08,
        ),

        // Bottom right
        _bubble(
          right: -width * 0.05,
          bottom: height * 0.08,
          size: height * 0.20,
          color: ConstantColor.primaryDark,
          opacity: 0.07,
        ),

        // Animated mid-right
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              cos(_animationController.value * 1.3 * pi) * 7,
              sin(_animationController.value * 2.1 * pi) * 7,
            ),
            child: _bubble(
              right: width * 0.08,
              top: height * 0.50,
              size: height * 0.11,
              color: ConstantColor.primaryDark,
              opacity: 0.10,
            ),
          ),
        ),

        // Animated mid-left
        AnimatedBuilder(
          animation: _animationController,
          builder: (_, __) => Transform.translate(
            offset: Offset(
              sin(_animationController.value * 2.5 * pi) * 6,
              cos(_animationController.value * 1.2 * pi) * 6,
            ),
            child: _bubble(
              left: width * 0.02,
              top: height * 0.42,
              size: height * 0.10,
              color: ConstantColor.primary,
              opacity: 0.09,
            ),
          ),
        ),

        _tinyBubble(
          left: width * 0.22,
          bottom: height * 0.18,
          size: height * 0.018,
          color: ConstantColor.primary,
          opacity: 0.35,
        ),

        _tinyBubble(
          right: width * 0.18,
          bottom: height * 0.32,
          size: height * 0.020,
          color: ConstantColor.primaryDark,
          opacity: 0.32,
        ),

        _particle(left: width * 0.15, bottom: height * 0.45, size: height * 0.007, color: ConstantColor.primary),
        _particle(right: width * 0.25, bottom: height * 0.15, size: height * 0.008, color: ConstantColor.primaryDark),
      ],
    );
  }

  Widget _bubble({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.3),
            radius: 0.85,
            colors: [
              color.withOpacity(opacity),
              color.withOpacity(0.01),
            ],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _tinyBubble({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
    required double opacity,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withOpacity(opacity), color.withOpacity(0)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(opacity * 0.5),
              blurRadius: size * 2,
              spreadRadius: size * 0.5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _particle({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.55),
        ),
      ),
    );
  }
}