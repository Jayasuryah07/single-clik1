// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/user_details_controller.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../../../constants/constant_string.dart';

class UserDetailsScreen extends StatefulWidget {
  final String id;

  const UserDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<UserDetailsScreen> createState() => UserDetailsScreenState();
}

class UserDetailsScreenState extends State<UserDetailsScreen> {

  ScrollController scrollController = ScrollController();
  RxBool isSliverAppBarExpanded = false.obs;

  double height = Get.height;
  double width = Get.width;
  bool get _isSliverAppBarExpanded {
    return scrollController.hasClients &&
        scrollController.offset > (width - kToolbarHeight);
  }

  UserDetailsController userDetailsController =
      Get.put(UserDetailsController());

  Future<void> getUserData() async {
    await userDetailsController.postUserByIdApi(widget.id);
  }

  @override
  void initState() {
    getUserData();
    scrollController.addListener(
      () {
        isSliverAppBarExpanded.value = _isSliverAppBarExpanded;
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantColor.whiteColor,
      // appBar: AppBar(
      //   backgroundColor: ConstantColor.bgColor,
      //   leading: GestureDetector(
      //     onTap: () {
      //       Get.back();
      //     },
      //     child: Icon(
      //       Icons.arrow_back_outlined,
      //       color: ConstantColor.blackColor,
      //     ),
      //   ),
      // ),
      bottomNavigationBar: Container(
        height: 70,
        color: ConstantColor.whiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                var contact =
                    '+91' + userDetailsController.userDetails['mobile'];
                var androidUrl = "whatsapp://send?phone=$contact";
                var iosUrl = "https://wa.me/$contact";

                try {
                  if (Platform.isIOS) {
                    await launchUrl(Uri.parse(iosUrl));
                  } else {
                    await launchUrl(Uri.parse(androidUrl));
                  }
                } on Exception {
                  ShowToast.showToast(
                    "WhatsApp is not installed.",
                    showSuccess: false,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: ConstantColor.greenColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/whatsapp.svg',
                    fit: BoxFit.contain,
                    height: Get.width / 15,
                    width: Get.width / 15,
                    colorFilter: ColorFilter.mode(
                      ConstantColor.whiteColor,
                      BlendMode.srcIn, // Preserves original alpha/shape of SVG
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                var contact = userDetailsController.userDetails['email'];
                var androidUrl = "mailto:$contact";
                var iosUrl = "mailto:$contact";

                try {
                  if (Platform.isIOS) {
                    await launchUrl(Uri.parse(iosUrl));
                  } else {
                    await launchUrl(Uri.parse(androidUrl));
                  }
                } on Exception {
                  ShowToast.showToast(
                    "WhatsApp is not installed.",
                    showSuccess: false,
                  );
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Icon(
                    Icons.mail_outline_outlined,
                    color: ConstantColor.whiteColor,
                    size: Get.width / 15,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Uri uri = Uri.parse(
                    "${ConstantString.userImgUrlPath}${userDetailsController.userDetails['photo']}");

                Directory tempDir = await getTemporaryDirectory();
                String tempPath = tempDir.path;
                File file = File(tempPath +
                    (DateTime.now().millisecondsSinceEpoch).toString() +
                    '.png');
                http.Response response = await http.get(uri);
                await file.writeAsBytes(response.bodyBytes);
                List<String> subCatList = [];
                String subCategory = "";

                for (int i = 0;
                    i <
                        userDetailsController
                            .userDetailsProduct['subcategories'].length;
                    i++) {
                  subCatList.add(userDetailsController
                      .userDetailsProduct['subcategories'][i]["subcategory"]
                      .toString()
                      .trim()
                      .replaceAll(",", "\n")
                      .trim());
                }

                for (int i = 0; i < subCatList.length; i++) {
                  subCategory = subCatList.join(", ");
                }

                debugPrint(subCategory);

                Share.shareXFiles(
                  [XFile(file.path)],
                  text:
                      "${userDetailsController.userDetails['name']}\n\n${userDetailsController.userDetails['company_name']}\n$subCategory\n\nMobile : ${userDetailsController.userDetails['mobile']}\nEmail : ${userDetailsController.userDetails['email']}",
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Icon(
                    Icons.share,
                    color: ConstantColor.whiteColor,
                    size: Get.width / 15,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                launchUrl(Uri.parse(
                    "tel: ${'+91' + userDetailsController.userDetails['mobile']}"));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(12),
                child: Center(
                  child: Icon(
                    Icons.call,
                    color: ConstantColor.whiteColor,
                    size: Get.width / 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => userDetailsController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  controller: scrollController,
                  physics: userDetailsController.userDetails['about_us']
                              .toString()
                              .length >
                          1000
                      ? null
                      : const NeverScrollableScrollPhysics(),
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      Obx(
                        () => SliverAppBar(
                          elevation: 0,
                          title: isSliverAppBarExpanded.value
                              ? Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: ConstantColor.primary,
                                          width: 1,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: AppImageAsset(
                                          image:
                                              "${ConstantString.userImgUrlPath}${userDetailsController.userDetails['photo']}",
                                          isFile: false,
                                          fit: BoxFit.cover,
                                          height: Get.width / 10,
                                          width: Get.width / 10,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: width / 30,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userDetailsController
                                                  .userDetails['name'] ??
                                              "",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: ConstantColor.primary,
                                          ),
                                        ),
                                        userDetailsController.userDetails[
                                                        'company_name'] ==
                                                    null ||
                                                userDetailsController
                                                            .userDetails[
                                                        'company_name'] ==
                                                    null
                                                        .toString()
                                                        .trim()
                                                        .isEmpty
                                            ? const SizedBox()
                                            : Text(
                                                userDetailsController
                                                            .userDetails[
                                                        'company_name'] ??
                                                    "",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      ConstantColor.blackColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                      ],
                                    ),
                                  ],
                                )
                              : null,
                          pinned: true,
                          expandedHeight: width,
                          backgroundColor: ConstantColor.whiteColor,
                          iconTheme: IconThemeData(
                            color: ConstantColor.blackColor,
                          ),
                          flexibleSpace: isSliverAppBarExpanded.value
                              ? null
                              : FlexibleSpaceBar(
                                  background: Column(
                                    children: [
                                      AppBar(
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                      ),
                                      SizedBox(height: width * 0.03),
                                      Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  insetPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: Get.width / 30,
                                                  ),
                                                  backgroundColor:
                                                      ConstantColor.whiteColor,
                                                  child: SizedBox(
                                                    child: AppImageAsset(
                                                      image:
                                                          "${ConstantString.userImgUrlPath}${userDetailsController.userDetails['photo']}",
                                                      isFile: false,
                                                      height: Get.width / 1.2,
                                                      width: Get.width / 1.2,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: ConstantColor.primary,
                                                width: 3,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: ClipOval(
                                              child: AppImageAsset(
                                                image:
                                                    "${ConstantString.userImgUrlPath}${userDetailsController.userDetails['photo']}",
                                                isFile: false,
                                                fit: BoxFit.cover,
                                                height: Get.width / 1.8,
                                                width: Get.width / 1.8,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Text(
                                        userDetailsController
                                                .userDetails['name'] ??
                                            "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: ConstantColor.primary,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      userDetailsController.userDetails[
                                                      'company_name'] ==
                                                  null ||
                                              userDetailsController.userDetails[
                                                      'company_name'] ==
                                                  null.toString().trim().isEmpty
                                          ? const SizedBox()
                                          : Column(
                                              children: [
                                                Text(
                                                  "Company",
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        ConstantColor.grayColor,
                                                  ),
                                                ),
                                                Text(
                                                  userDetailsController
                                                              .userDetails[
                                                          'company_name'] ??
                                                      "",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: ConstantColor
                                                        .blackColor,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                      SizedBox(height: height * 0.01),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      SliverPersistentHeader(
                        delegate: MySliverPersistentHeaderDelegate(
                          TabBar(
                            controller: userDetailsController.tabController,
                            indicatorColor: ConstantColor.primary,
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicatorWeight: 2,
                            tabs: [
                              Tab(
                                child: Text(
                                  "About",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ConstantColor.primary,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Product & Services",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ConstantColor.primary,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  "Contact",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: ConstantColor.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: userDetailsController.tabController,
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.03),
                              // Text(
                              //   "Company",
                              //   style: TextStyle(
                              //     fontSize: 12,
                              //     fontWeight: FontWeight.w400,
                              //     color: ConstantColor.grayColor,
                              //   ),
                              // ),
                              // Text(
                              //   controller.userDetails['company_name'] ?? "",
                              //   style: TextStyle(
                              //     fontSize: 18,
                              //     fontWeight: FontWeight.w600,
                              //     color: ConstantColor.blackColor,
                              //   ),
                              // ),
                              // SizedBox(height: height * 0.02),
                              Text(
                                userDetailsController.userDetails['about_us']
                                    .toString()
                                    .replaceAll("/", "\n"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: ConstantColor.blackColor,
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              
                              // Services Offered Header
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Services Offered",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Check if categories list is empty
                              if (userDetailsController.userDetailsProduct['categories'] == null ||
                                  (userDetailsController.userDetailsProduct['categories'] as List).isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                  child: Text(
                                    "No services listed",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              else
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: userDetailsController
                                      .userDetailsProduct['categories'].length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Text(
                                            ' ' +
                                                userDetailsController
                                                    .userDetailsProduct[
                                                        'categories'][index]
                                                        ["category"]
                                                    .toString()
                                                    .trim()
                                                    .replaceAll(",", "\n")
                                                    .trim(),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.deepOrange,
                                            ),
                                          ),
                                        ),
                                        ListView.builder(
                                          physics: const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: userDetailsController
                                              .userDetailsProduct['subcategories']
                                              .length,
                                          itemBuilder: (context, index2) {
                                            return userDetailsController
                                                                .userDetailsProduct[
                                                            'subcategories']
                                                        [index2]["category_id"] !=
                                                    userDetailsController
                                                                .userDetailsProduct[
                                                            'categories'][index]
                                                        ["u_catg_id"]
                                                ? const SizedBox.shrink()
                                                : Padding(
                                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 30, right: 10),
                                                          child: Icon(Icons.circle, size: 7, color: ConstantColor.primary),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            userDetailsController
                                                                .userDetailsProduct[
                                                                    'subcategories']
                                                                    [index2][
                                                                    "subcategory"]
                                                                .toString()
                                                                .trim()
                                                                .replaceAll(
                                                                    ",", "\n")
                                                                .trim(),
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: ConstantColor
                                                                  .blackColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                          },
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    );
                                  },
                                ),
                              
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 16),
                              
                              // Products Header
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: ConstantColor.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "Products",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Products Display List
                              Builder(
                                builder: (context) {
                                  final products = List.from(
                                    userDetailsController.userDetailsProduct['products'] ??
                                    userDetailsController.userDetailsProduct['product_services'] ??
                                    userDetailsController.userDetails['products'] ??
                                    userDetailsController.userDetails['product_services'] ??
                                    []
                                  );
                                  
                                  if (products.isEmpty) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 30),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[300]),
                                            const SizedBox(height: 12),
                                            Text(
                                              "No products uploaded by this business yet",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[500],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  
                                  return GridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.85,
                                    ),
                                    itemCount: products.length,
                                    itemBuilder: (context, idx) {
                                      final product = products[idx];
                                      return GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return Dialog(
                                                insetPadding: EdgeInsets.symmetric(
                                                  horizontal: Get.width / 20,
                                                ),
                                                backgroundColor: ConstantColor.whiteColor,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    AppBar(
                                                      backgroundColor: Colors.transparent,
                                                      elevation: 0,
                                                      leading: IconButton(
                                                        icon: const Icon(Icons.close, color: Colors.black),
                                                        onPressed: () => Get.back(),
                                                      ),
                                                      title: Text(
                                                        (product['product_name'] ?? '').toString(),
                                                        style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                    ConstrainedBox(
                                                      constraints: BoxConstraints(
                                                        maxHeight: Get.height * 0.6,
                                                        maxWidth: Get.width * 0.9,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                        child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: AppImageAsset(
                                                            image: "${ConstantString.productImgUrlPath}${product['product_images'] ?? ''}",
                                                            isFile: false,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.04),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                            border: Border.all(color: Colors.grey[200]!),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                                  child: AppImageAsset(
                                                    image: "${ConstantString.productImgUrlPath}${product['product_images'] ?? ''}",
                                                    isFile: false,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8),
                                                child: Text(
                                                  (product['product_name'] ?? '').toString(),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: height * 0.03),
                              Text(
                                "Mobile Number",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ConstantColor.grayColor,
                                ),
                              ),
                              Text(
                                userDetailsController.userDetails['mobile'] ??
                                    "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Email",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ConstantColor.grayColor,
                                ),
                              ),
                              Text(
                                userDetailsController.userDetails['email'] ??
                                    "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Whatsapp",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ConstantColor.grayColor,
                                ),
                              ),
                              Text(
                                userDetailsController.userDetails['whatsapp'] ??
                                    "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                              SizedBox(height: height * 0.03),
                              Text(
                                "Area",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ConstantColor.grayColor,
                                ),
                              ),
                              Text(
                                userDetailsController.userDetails['area'] ?? "",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: ConstantColor.blackColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class MySliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  MySliverPersistentHeaderDelegate(this._tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: ConstantColor.whiteColor, child: _tabBar);
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(MySliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
