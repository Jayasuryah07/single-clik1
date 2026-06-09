import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_color.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/controller/home_controller/home_controller.dart';
import 'package:single_clik/screens/home_screens/home_screens/user_details_screen.dart';
import 'package:single_clik/screens/home_screens/home_screens/user_list_screen.dart';
import 'package:single_clik/widget/app_button.dart';
import 'package:single_clik/widget/app_image_assets.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    const quick = Duration(milliseconds: 1000);
    final scaleTween = Tween(begin: 0.0, end: 1.0);
    _animationController = AnimationController(duration: quick, vsync: this);
    animation = scaleTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    )..addListener(() {
        scale.value = animation.value;
      });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getData();
      getServices();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> getServices() async {
    await homeController.postBusinessDashboardApi("0");
    await homeController.postBusinessDashboardApi("1");
  }

  RxDouble scale = 1.0.obs;

  HomeController homeController = Get.put(HomeController());

  void getData() {
    homeController.tabController.addListener(() {
      homeController.tabIndex.value = homeController.tabController.index;
      if (homeController.tabIndex.value != 0) {
        homeController.searchController.value.clear();
        homeController.searchProduct('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ConstantColor.bgColor,
      floatingActionButton: SizedBox(
        width: Get.width,
        child: Row(
          children: [
            const Spacer(),
            Obx(
              () => Transform.scale(
                scale: scale.value,
                child: GestureDetector(
                  onTap: () {
                    raiseInquiryDialog(context, homeController, height, width);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ConstantColor.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ConstantColor.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Image.asset(
                      "assets/icons/icon_add.png",
                      height: 25,
                      width: 25,
                      color: ConstantColor.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Obx(
        () => homeController.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TabBarView(
                controller: homeController.tabController,
                children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postDashboardApi("");
                            await homeController.postDashboardSliderApi("");
                            await homeController.postDashboardAdvSliderApi();
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.allList.isEmpty
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
                              : SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
                                  child: Column(
                                    children: [
                                      ListView.separated(
                                        itemCount:
                                            homeController.allList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        separatorBuilder: (context, index) =>
                                            index == 0
                                                ? homeController
                                                        .allSliderList.isEmpty
                                                    ? const SizedBox()
                                                    : Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height:
                                                                Get.width / 150,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: Get.width /
                                                                  30,
                                                            ),
                                                            child: const Text(
                                                              'Recently Joined Members',
                                                              style: TextStyle(
                                                                color: Color(0xff0F172A),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                Get.width / 35,
                                                          ),
                                                          CarouselSlider(
                                                            options: CarouselOptions(
                                                                height:
                                                                    width / 2.5,
                                                                autoPlay: true,
                                                                initialPage: 0,
                                                                enlargeFactor:
                                                                    0,
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                viewportFraction:
                                                                    0.3),
                                                            items:
                                                                List.generate(
                                                              homeController
                                                                  .allSliderList
                                                                  .length,
                                                              (index) =>
                                                                  SizedBox(
                                                                width:
                                                                    width / 3.5,
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        Get.to(() =>
                                                                            UserDetailsScreen(
                                                                              id: homeController.allSliderList[index]['id'].toString(),
                                                                            ));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          border:
                                                                              Border.all(
                                                                            color:
                                                                                const Color(0xff0B3C9B),
                                                                            width:
                                                                                2.5,
                                                                          ),
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          boxShadow: [
                                                                            BoxShadow(
                                                                              color: Colors.black.withOpacity(0.06),
                                                                              blurRadius: 8,
                                                                              offset: const Offset(0, 3),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        child:
                                                                            ClipOval(
                                                                          child:
                                                                              AppImageAsset(
                                                                            image:
                                                                                "${ConstantString.userImgUrlPath}${homeController.allSliderList[index]['photo']}",
                                                                            isFile:
                                                                                false,
                                                                            height:
                                                                                width / 4,
                                                                            width:
                                                                                width / 4,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                        height: height *
                                                                            0.01),
                                                                    Text(
                                                                      (homeController.allSliderList[index]
                                                                              [
                                                                              'name'] ??
                                                                          ""),
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(0xff334155),
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                : index == 8
                                                    ? homeController
                                                            .allAdvSliderList
                                                            .isEmpty
                                                        ? const SizedBox()
                                                        : Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              SizedBox(
                                                                height:
                                                                    Get.width /
                                                                        30,
                                                              ),
                                                              CarouselSlider(
                                                                options:
                                                                    CarouselOptions(
                                                                  autoPlay:
                                                                      true,
                                                                  initialPage:
                                                                      0,
                                                                  enlargeFactor:
                                                                      0,
                                                                  scrollDirection:
                                                                      Axis.horizontal,
                                                                  viewportFraction:
                                                                      0.9,
                                                                  enlargeCenterPage:
                                                                      false,
                                                                ),
                                                                items: List
                                                                    .generate(
                                                                  homeController
                                                                      .allAdvSliderList
                                                                      .length,
                                                                  (index) =>
                                                                      SizedBox(
                                                                    width:
                                                                        width,
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        GestureDetector(
                                                                          onTap:
                                                                              () async {
                                                                            debugPrint('slider_url : ${homeController.allAdvSliderList[index]['slider_url']}');
                                                                            Uri url = Uri.parse(homeController.allAdvSliderList[index]['slider_url'] ?? '');
                                                                            debugPrint('slider_url $url');
                                                                            if (await canLaunchUrl(url)) {
                                                                              await launchUrl(url, mode: LaunchMode.externalApplication);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: ConstantColor.primary,
                                                                                  width: 2,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(15)),
                                                                            child:
                                                                                ClipRRect(
                                                                              borderRadius: BorderRadius.circular(13),
                                                                              child: AppImageAsset(
                                                                                image: "${ConstantString.sliderImgUrlPath}${homeController.allAdvSliderList[index]['slider_images']}",
                                                                                isFile: false,
                                                                                height: width / 2,
                                                                                width: width / 1.2,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                    : const SizedBox(),
                                        itemBuilder: (context, index) {
                                          return GestureDetector(
                                            onTap: () {
                                              debugPrint('Id: ${homeController.allList[index]['id']}');
                                              Get.to(() => UserDetailsScreen(
                                                    id: homeController
                                                        .allList[index]['id']
                                                        .toString(),
                                                  ));
                                            },
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(16),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: ConstantColor.whiteColor,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.04),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: const Color(0xff0B3C9B),
                                                        width: 2.5,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.06),
                                                          blurRadius: 8,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                    child: ClipOval(
                                                      child: AppImageAsset(
                                                        image:
                                                            "${ConstantString.userImgUrlPath}${homeController.allList[index]['photo']}",
                                                        isFile: false,
                                                        fit: BoxFit.cover,
                                                        height: width / 3.8,
                                                        width: width / 3.8,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: width * 0.035),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          (homeController.allList[
                                                                      index]
                                                                  ['name'] ??
                                                              ""),
                                                          style: const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(0xff1E293B),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          homeController.allList[
                                                                      index][
                                                                  'company_name'] ??
                                                              "",
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(6),
                                                            color: const Color(0xffFFF2E6),
                                                          ),
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                          child: Text(
                                                            homeController.allList[index]
                                                                            [
                                                                            'category'] ==
                                                                        null ||
                                                                    homeController
                                                                        .allList[
                                                                            index]
                                                                            [
                                                                            'category']
                                                                        .toString()
                                                                        .trim()
                                                                        .isEmpty
                                                                ? 'Category ${ConstantString.naLabel}'
                                                                : homeController
                                                                    .allList[
                                                                        index][
                                                                        'category']
                                                                    .toString()
                                                                    .toUpperCase(),
                                                            style: const TextStyle(
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                color: Colors
                                                                    .deepOrange,
                                                                letterSpacing:
                                                                    1.2),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          homeController.allList[
                                                                              index]
                                                                          [
                                                                          'subcategory'] ==
                                                                      null ||
                                                                  homeController
                                                                      .allList[
                                                                          index]
                                                                          [
                                                                          'subcategory']
                                                                      .toString()
                                                                      .trim()
                                                                      .isEmpty
                                                              ? 'Sub Category ${ConstantString.naLabel}'
                                                              : homeController
                                                                  .allList[
                                                                      index][
                                                                      'subcategory']
                                                                  .toString(),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .grey.shade500,
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
                                    ],
                                  ),
                                ),
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postBusinessDashboardApi("0");
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.businessList.isEmpty
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
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.95,
                                  ),
                                  padding: const EdgeInsets.only(bottom: 80, top: 10),
                                  itemCount: homeController.businessList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      if (homeController.businessList[index]
                                                  ['member_count'] ==
                                              null ||
                                          homeController.businessList[index]
                                                  ['member_count'] ==
                                              0) {
                                        EasyLoading.showError(
                                          ConstantString
                                              .businessServiceMembersEmptyMsg,
                                        );
                                      } else {
                                        Get.to(
                                          () => UserListScreen(
                                            categoryId: (homeController
                                                            .businessList[index]
                                                        ['id'] ??
                                                    "")
                                                .toString(),
                                            categoryName: (homeController
                                                            .businessList[index]
                                                        ['category'] ??
                                                    "")
                                                .toString(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xffF6F5FA),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: AppImageAsset(
                                                image:
                                                    "${ConstantString.categoriesImgUrlPath}${homeController.businessList[index]['category_image']}",
                                                isFile: false,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            homeController.businessList[index]
                                                    ['category'] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: (homeController.businessList[
                                                                  index][
                                                              'member_count'] ==
                                                          null ||
                                                      homeController.businessList[
                                                                  index][
                                                              'member_count'] ==
                                                          0)
                                                  ? ConstantColor.grayColor
                                                  : ConstantColor.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        RefreshIndicator(
                          onRefresh: () async {
                            await homeController.postBusinessDashboardApi("1");
                            await homeController
                                .getSentEnquiriesUnreadCount("1");
                          },
                          backgroundColor: ConstantColor.whiteColor,
                          color: ConstantColor.primary,
                          child: homeController.servicesList.isEmpty
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
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    childAspectRatio: 0.95,
                                  ),
                                  itemCount: homeController.servicesList.length,
                                  padding: const EdgeInsets.only(bottom: 80, top: 10),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) =>
                                      GestureDetector(
                                    onTap: () {
                                      if (homeController.servicesList[index]
                                                  ['member_count'] ==
                                              null ||
                                          homeController.servicesList[index]
                                                  ['member_count'] ==
                                              0) {
                                        EasyLoading.showError(
                                          ConstantString
                                              .businessServiceMembersEmptyMsg,
                                        );
                                      } else {
                                        Get.to(() => UserListScreen(
                                              categoryId:
                                                  (homeController.servicesList[
                                                              index]['id'] ??
                                                          "")
                                                      .toString(),
                                              categoryName: (homeController
                                                              .servicesList[
                                                          index]['category'] ??
                                                      "")
                                                  .toString(),
                                            ));
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            height: 80,
                                            width: 80,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color(0xffF6F5FA),
                                                width: 2,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: AppImageAsset(
                                                image:
                                                    "${ConstantString.categoriesImgUrlPath}${homeController.servicesList[index]['category_image']}",
                                                isFile: false,
                                                fit: BoxFit.cover,
                                                height: 80,
                                                width: 80,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            homeController.servicesList[index]
                                                    ['category'] ??
                                                "",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: (homeController.servicesList[
                                                                  index][
                                                              'member_count'] ==
                                                          null ||
                                                      homeController.servicesList[
                                                                  index][
                                                              'member_count'] ==
                                                          0)
                                                  ? ConstantColor.grayColor
                                                  : ConstantColor.primary,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
      ),
    );
  }

  Future<void> raiseInquiryDialog(BuildContext context,
    HomeController controller,
    double height,
    double width) async {

  await controller.postCategoriesApi();
  controller.categorySelect.value = {};
  controller.subCategorySelect.value = {};
  controller.priorityTypeSelect.value = "";
  controller.subCategoryList.value = [];
  controller.inquiryController.value.clear();
  
  List categoryList = List.from(controller.categoryList);

  categoryList.removeWhere(
    (element) =>
        element['category'].toString().trim().toLowerCase() ==
        'Not in List'.trim().toLowerCase(),
  );

  if (!context.mounted) return;
  final dialogContext = context;

  return showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (context) => Obx(
      () => Dialog(
        backgroundColor: ConstantColor.whiteColor,
        surfaceTintColor: ConstantColor.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Raise Inquiry",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: ConstantColor.blackColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Category",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xffF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffEBEFF2),
                        width: 1,
                      )),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  child: DropdownButton(
                    dropdownColor: ConstantColor.whiteColor,
                    value: controller.categorySelect['category'] == null ||
                            controller.categorySelect['category']
                                .toString()
                                .trim()
                                .isEmpty
                        ? null
                        : controller.categorySelect['category'].toString(),
                    padding: EdgeInsets.zero,
                    isExpanded: true,
                    onChanged: (dynamic newValue) {
                      for (int i = 0; i < categoryList.length; i++) {
                        if (categoryList[i]['category'].toString() == newValue.toString()) {
                          debugPrint('Selected Category Data: ${categoryList[i]}');
                          controller.categorySelect.value = categoryList[i] ?? {};
                          debugPrint('Category ID: ${controller.categorySelect['id']}');
                          controller.postSubCategoriesApi(
                              controller.categorySelect['id'].toString());
                        }
                      }
                    },
                    items: categoryList.map(
                      (val) {
                        return DropdownMenuItem(
                          value: val['category']?.toString() ?? "",
                          child: Text(
                            val['category']?.toString() ?? "",
                            style: TextStyle(
                              fontSize: 15,
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),
                    underline: const SizedBox(),
                    hint: Text(
                      "Select Category",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Sub-Category",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: const Color(0xffF7F8FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xffEBEFF2),
                        width: 1,
                      )),
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 16,
                  ),
                  child: DropdownButton(
                    dropdownColor: ConstantColor.whiteColor,
                    value: controller.subCategorySelect['subcategory'] == null ||
                            controller.subCategorySelect['subcategory']
                                .toString()
                                .trim()
                                .isEmpty
                        ? null
                        : controller.subCategorySelect['subcategory'].toString(),
                    padding: EdgeInsets.zero,
                    isExpanded: true,
                    onChanged: (dynamic newValue) {
                      for (int i = 0; i < controller.subCategoryList.length; i++) {
                        if (controller.subCategoryList[i]['subcategory'].toString() == newValue.toString()) {
                          debugPrint('Selected SubCategory Data: ${controller.subCategoryList[i]}');
                          controller.subCategorySelect.value = controller.subCategoryList[i] ?? {};
                          debugPrint('SubCategory ID: ${controller.subCategorySelect['id']}');
                        }
                      }
                    },
                    hint: Text(
                      "Select SubCategory",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    items: controller.subCategoryList.map(
                      (val) {
                        return DropdownMenuItem(
                          value: val['subcategory']?.toString() ?? "",
                          child: Text(
                            val['subcategory']?.toString() ?? "",
                            style: TextStyle(
                              fontSize: 15,
                              color: ConstantColor.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ).toList(),
                    underline: const SizedBox(),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      size: 24,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Priority type",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.priorityTypeSelect.value = "Urgent";
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.priorityTypeSelect.value == "Urgent"
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: controller.priorityTypeSelect.value == "Urgent"
                                ? const Color(0xff0B3C9B)
                                : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Urgent",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: controller.priorityTypeSelect.value == "Urgent"
                                  ? ConstantColor.blackColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    GestureDetector(
                      onTap: () {
                        controller.priorityTypeSelect.value = "General";
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            controller.priorityTypeSelect.value == "General"
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: controller.priorityTypeSelect.value == "General"
                                ? const Color(0xff0B3C9B)
                                : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "General",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: controller.priorityTypeSelect.value == "General"
                                  ? ConstantColor.blackColor
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F8FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xffEBEFF2),
                      width: 1,
                    ),
                  ),
                  child: TextFormField(
                    controller: controller.inquiryController.value,
                    textInputAction: TextInputAction.newline,
                    maxLines: 5,
                    style: TextStyle(
                      fontSize: 15,
                      color: ConstantColor.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                    keyboardType: TextInputType.multiline,
                    cursorColor: ConstantColor.blackColor,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      hintText: "Need Photographer for one day for birthday celebration.",
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400),
                      filled: false,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (!controller.isButtonLoading.value) {
                            Get.back();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xffD0D5DD), width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "CANCEL",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff344054),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.isButtonLoading.value
                            ? null
                            : () async {
                                // Validate selections
                                if (controller.categorySelect.isEmpty) {
                                  ShowToast.showToast('Please Select Category', showSuccess: false);
                                  return;
                                }
                                
                                if (controller.subCategorySelect.isEmpty) {
                                  ShowToast.showToast('Please Select Sub-Category', showSuccess: false);
                                  return;
                                }
                                
                                if (controller.priorityTypeSelect.value.isEmpty) {
                                  ShowToast.showToast('Please Select Priority Type', showSuccess: false);
                                  return;
                                }
                                
                                // Get IDs safely
                                String categoryId = controller.categorySelect['id']?.toString() ?? '';
                                String subCategoryId = controller.subCategorySelect['id']?.toString() ?? '';
                                String priorityType = controller.priorityTypeSelect.value == "Urgent" ? "0" : "1";
                                String inquiryText = controller.inquiryController.value.text.trim();
                                
                                // Validate IDs
                                if (categoryId.isEmpty) {
                                  ShowToast.showToast('Invalid Category selected', showSuccess: false);
                                  return;
                                }
                                
                                if (subCategoryId.isEmpty) {
                                  ShowToast.showToast('Invalid Sub-Category selected', showSuccess: false);
                                  return;
                                }
                                
                                var bodyParams = {
                                  'category': categoryId,
                                  'sub_category': subCategoryId,
                                  'type': priorityType,
                                  'enq_text': inquiryText,
                                };
                                
                                debugPrint('Sending Inquiry with params: $bodyParams');
                                
                                // Call API
                                bool success = await controller.postCreateEnquiryApi(bodyParams);
                                
                                if (success) {
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff0B3C9B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                        ),
                        child: controller.isButtonLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "SUBMIT",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}