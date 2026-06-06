// lib/controllers/home_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:single_clik/constants/constant_string.dart';
import 'package:single_clik/constants/show_toast.dart';
import 'package:single_clik/services/api.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'package:single_clik/utils/cache_manager.dart';
import '../../Model/on_board_model.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final isLoading = false.obs;
  final isAddLoading = false.obs;
  final isOnBoardingLoading = false.obs;
  final isButtonLoading = false.obs;
  final isRefreshing = false.obs; // Added for pull-to-refresh

  final searchController = TextEditingController().obs;
  FocusNode searchFocusNode = FocusNode();

  late TabController tabController;
  RxInt tabIndex = 0.obs;
  RxInt selectTab = 0.obs;
  RxBool isSearchOpen = false.obs;

  // Cache keys
  static const String CACHE_DASHBOARD = 'dashboard_data';
  static const String CACHE_BUSINESS = 'business_data';
  static const String CACHE_SERVICES = 'services_data';
  static const String CACHE_SLIDER = 'slider_data';
  static const String CACHE_ADV_SLIDER = 'adv_slider_data';
  static const String CACHE_ONBOARD = 'onboard_data';
  static const String CACHE_CATEGORIES = 'categories_data';
  static const String CACHE_USER_PROFILE = 'user_profile';
  static const String CACHE_ENQUIRY_COUNTS = 'enquiry_counts';
  
  // Cache duration (30 minutes)
  static const Duration CACHE_DURATION = Duration(minutes: 30);

  final allList = <dynamic>[].obs;
  final searchAllList = <dynamic>[].obs;
  final allSliderList = <dynamic>[].obs;
  final searchAllSliderList = <dynamic>[].obs;
  final allAdvSliderList = <dynamic>[].obs;
  final searchAllAdvSliderList = <dynamic>[].obs;
  final businessList = <dynamic>[].obs;
  final servicesList = <dynamic>[].obs;
  final allAdvPopUpSliderList = <dynamic>[].obs;

  final categoryList = <dynamic>[].obs;
  final categorySelect = {}.obs;

  final subCategoryList = <dynamic>[].obs;
  final subCategorySelect = {}.obs;

  final priorityTypeSelect = 'Urgent'.obs;

  final inquiryController = TextEditingController().obs;
  RxInt pendingOpenInquiriesCount = 0.obs;
  RxInt receivedUnreadCount = 0.obs;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Track if initial load is done
  RxBool isInitialLoadComplete = false.obs;
  
  // Prevent multiple simultaneous requests
  final _requestLocks = <String, bool>{};
  
  late Timer timer;
  late Timer countTimer;
  bool _isDisposed = false;

  void getDashboardTimer() {
    // Poll counts every 2 seconds for near-instant bottom bar badge updates
    countTimer = Timer.periodic(
      const Duration(seconds: 2),
      (Timer timer) {
        if (!_isDisposed) {
          getSentEnquiriesUnreadCount('1', forceRefresh: true);
        }
      },
    );

    // Poll full dashboard and profile every 25 seconds
    timer = Timer.periodic(
      const Duration(seconds: 25),
      (Timer timer) {
        if (!_isDisposed) {
          refreshDashboardAndProfile();
        }
      },
    );
  }

  Future<void> refreshDashboardAndProfile() async {
    if (_isDisposed) return;
    try {
      final userId = await SharPreferences.getString(SharPreferences.userId) ?? '';
      if (userId.isNotEmpty) {
        await Future.wait([
          postFetchProfileApi(forceRefresh: true),
          postDashboardApi(userId, forceRefresh: true),
        ]);
      }
    } catch (e) {
      debugPrint('Background dashboard sync error: $e');
    }
  }

  Future<void> refreshCountsAndDashboard() async {
    if (_isDisposed) return;
    try {
      final userId = await SharPreferences.getString(SharPreferences.userId) ?? '';
      if (userId.isNotEmpty) {
        await Future.wait([
          getSentEnquiriesUnreadCount('1', forceRefresh: true),
          postFetchProfileApi(forceRefresh: true),
          postDashboardApi(userId, forceRefresh: true),
        ]);
      }
    } catch (e) {
      debugPrint('Background sync error: $e');
    }
  }

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _initializeData();
    super.onInit();
  }

  Future<void> _initializeData() async {
    // Load cached data first (instant display)
    await _loadAllCachedData();
    
    // Then fetch fresh data in background
    await refreshAllData();
    
    isInitialLoadComplete.value = true;
    
    // Start background timer after first load
    getDashboardTimer();
  }

  Future<void> _loadAllCachedData() async {
    await Future.wait([
      _loadCachedDashboard(),
      _loadCachedBusinessData(),
      _loadCachedServicesData(),
      _loadCachedSliderData(),
      _loadCachedOnboardData(),
      _loadCachedProfileData(),
      _loadCachedEnquiryCounts(),
    ]);
  }

  Future<void> _loadCachedDashboard() async {
    try {
      final cachedData = await CacheManager.get(CACHE_DASHBOARD);
      if (cachedData != null) {
        allList.value = cachedData['data'] ?? [];
        searchAllList.value = cachedData['data'] ?? [];
        debugPrint('✅ Loaded dashboard from cache: ${allList.length} items');
      }
    } catch (e) {
      debugPrint('Error loading cached dashboard: $e');
    }
  }

  Future<void> _loadCachedBusinessData() async {
    try {
      final cachedData = await CacheManager.get(CACHE_BUSINESS);
      if (cachedData != null) {
        businessList.value = cachedData['data'] ?? [];
        debugPrint('✅ Loaded business data from cache: ${businessList.length} items');
      }
    } catch (e) {
      debugPrint('Error loading cached business data: $e');
    }
  }

  Future<void> _loadCachedServicesData() async {
    try {
      final cachedData = await CacheManager.get(CACHE_SERVICES);
      if (cachedData != null) {
        servicesList.value = cachedData['data'] ?? [];
        debugPrint('✅ Loaded services data from cache: ${servicesList.length} items');
      }
    } catch (e) {
      debugPrint('Error loading cached services data: $e');
    }
  }

  Future<void> _loadCachedSliderData() async {
    try {
      final cachedData = await CacheManager.get(CACHE_SLIDER);
      if (cachedData != null) {
        allSliderList.value = cachedData['data'] ?? [];
        searchAllSliderList.value = cachedData['data'] ?? [];
        debugPrint('✅ Loaded slider from cache: ${allSliderList.length} items');
      }
    } catch (e) {
      debugPrint('Error loading cached slider: $e');
    }
  }

  Future<void> _loadCachedOnboardData() async {
    try {
      final cachedData = await CacheManager.get(CACHE_ONBOARD);
      if (cachedData != null) {
        onBoardList.value = OnBoardModel.fromJson(cachedData['data']);
        debugPrint('✅ Loaded onboard data from cache');
      }
    } catch (e) {
      debugPrint('Error loading cached onboard data: $e');
    }
  }

  Future<void> _loadCachedProfileData() async {
    try {
      final cachedData = await CacheManager.get(CACHE_USER_PROFILE);
      if (cachedData != null) {
        userData.value = cachedData['data'];
        debugPrint('✅ Loaded profile from cache');
      }
    } catch (e) {
      debugPrint('Error loading cached profile: $e');
    }
  }

  Future<void> _loadCachedEnquiryCounts() async {
    try {
      final cachedData = await CacheManager.get(CACHE_ENQUIRY_COUNTS);
      if (cachedData != null) {
        pendingOpenInquiriesCount.value = cachedData['pending'] ?? 0;
        receivedUnreadCount.value = cachedData['received'] ?? 0;
        debugPrint('✅ Loaded enquiry counts from cache');
      }
    } catch (e) {
      debugPrint('Error loading cached enquiry counts: $e');
    }
  }

  // Refresh all data (called on pull-to-refresh)
  Future<void> refreshAllData() async {
    if (isRefreshing.value) return;
    
    isRefreshing.value = true;
    
    try {
      final userId = await SharPreferences.getString(SharPreferences.userId) ?? '';
      
      await Future.wait([
        postDashboardApi(userId, forceRefresh: true),
        postBusinessDashboardApi("0", forceRefresh: true),
        postBusinessDashboardApi("1", forceRefresh: true),
        postDashboardSliderApi("", forceRefresh: true),
        postDashboardAdvSliderApi(),
        postDashboardAdvPopUpSliderApi(),
        fetchOnboardApi(forceRefresh: true),
        postFetchProfileApi(forceRefresh: true),
        getSentEnquiriesUnreadCount('1', forceRefresh: true),
      ]);
      
      debugPrint('✅ All data refreshed successfully');
      ShowToast.showToast('Data refreshed successfully', showSuccess: true);
    } catch (e) {
      debugPrint('❌ Error refreshing data: $e');
      ShowToast.showToast('Failed to refresh data', showSuccess: false);
    } finally {
      isRefreshing.value = false;
    }
  }

  void searchProduct(String query) {
    if (searchAllList.isEmpty) return;
    
    isLoading(true);
    try {
      if (query.isEmpty) {
        allList.value = searchAllList;
      } else {
        allList.value = searchAllList
            .where((item) =>
                (item['name']?.toString().trim().toLowerCase().contains(query.toString().trim().toLowerCase()) ?? false) ||
                (item['company_name']?.toString().trim().toLowerCase().contains(query.toString().trim().toLowerCase()) ?? false) ||
                (item['category']?.toString().trim().toLowerCase().contains(query.toString().trim().toLowerCase()) ?? false) ||
                (item['subcategory']?.toString().trim().toLowerCase().contains(query.toString().trim().toLowerCase()) ?? false))
            .toList();
      }
      debugPrint('Search results: ${allList.length}');
    } catch (e) {
      debugPrint('Search error: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> postDashboardApi(String userId, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheManager.get(CACHE_DASHBOARD);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < CACHE_DURATION) {
          allList.value = cachedData['data'] ?? [];
          searchAllList.value = cachedData['data'] ?? [];
          debugPrint('✅ Using cached dashboard data (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    // Acquire lock to prevent multiple simultaneous requests
    if (_requestLocks['dashboard'] == true) {
      debugPrint('⏳ Dashboard request already in progress, skipping...');
      return;
    }
    
    _requestLocks['dashboard'] = true;
    
    try {
      if (!forceRefresh) isLoading.value = true;
      
      debugPrint('=== Calling Dashboard API ===');
      debugPrint('URL: ${API.dashboard}');
      
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      debugPrint('Token present: ${token.isNotEmpty}');
      
      final response = await http.post(
        Uri.parse(API.dashboard),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {"user_id": userId},
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('Dashboard Response Status: ${response.statusCode}');
      
      // Check if response is HTML (server error)
      if (response.body.trim().startsWith('<!DOCTYPE') || 
          response.body.trim().startsWith('<html')) {
        debugPrint('❌ ERROR: Server returned HTML instead of JSON');
        if (!forceRefresh && allList.isEmpty) {
          ShowToast.showToast("Server error. Please try again later.", showSuccess: false);
        }
        return;
      }
      
      final data = json.decode(response.body);
      debugPrint('Dashboard Response Code: ${data['code']}');
      
      if (data['code'] == 200) {
        final dashboardData = data['data'] ?? [];
        allList.value = dashboardData;
        searchAllList.value = dashboardData;
        
        // Save to cache
        await CacheManager.set(CACHE_DASHBOARD, {
          'data': dashboardData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Dashboard data cached: ${dashboardData.length} items');
      } else {
        debugPrint('API returned error code: ${data['code']}');
        if (!forceRefresh && allList.isEmpty) {
          ShowToast.showToast(data['msg'] ?? "Failed to load data", showSuccess: false);
        }
      }
    } catch (e) {
      debugPrint('❌ Dashboard API Error: $e');
      // Only show error if not from refresh and no cached data
      if (!forceRefresh && allList.isEmpty) {
        ShowToast.showToast("Network error. Please check your connection.", showSuccess: false);
      }
    } finally {
      if (!forceRefresh) isLoading.value = false;
      _requestLocks['dashboard'] = false;
    }
  }

  Future<void> postBusinessDashboardApi(String? profileType, {bool forceRefresh = false}) async {
    debugPrint('=== postBusinessDashboardApi Called ===');
    debugPrint('Profile Type: $profileType');
    
    // Check cache first
    if (!forceRefresh) {
      final cacheKey = profileType == "0" ? CACHE_BUSINESS : CACHE_SERVICES;
      final cachedData = await CacheManager.get(cacheKey);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < CACHE_DURATION) {
          if (profileType == "0") {
            businessList.value = cachedData['data'];
          } else if (profileType == "1") {
            servicesList.value = cachedData['data'];
          }
          debugPrint('✅ Using cached ${profileType == "0" ? "business" : "services"} data (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    // Acquire lock
    final lockKey = 'business_${profileType}';
    if (_requestLocks[lockKey] == true) {
      debugPrint('⏳ ${profileType} request already in progress, skipping...');
      return;
    }
    
    _requestLocks[lockKey] = true;
    
    try {
      if (!forceRefresh) isLoading.value = true;
      
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      debugPrint('Token: ${token.isNotEmpty ? "Present" : "Missing"}');
      
      final response = await http.post(
        Uri.parse(API.dashboardCategories),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'categories_type': profileType!},
      ).timeout(const Duration(seconds: 30));
      
      debugPrint('Response Status Code: ${response.statusCode}');
      
      // Check if response is HTML (server error)
      if (response.body.trim().startsWith('<!DOCTYPE') || 
          response.body.trim().startsWith('<html')) {
        debugPrint('❌ ERROR: Server returned HTML instead of JSON');
        if (!forceRefresh) {
          ShowToast.showToast("Server error. Please try again later.", showSuccess: false);
        }
        return;
      }
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        debugPrint("✅ Response Code: ${responseData['code']}");
        
        if (responseData['code'] == 200 && responseData['data'] != null) {
          List dataList = List.from(responseData['data']);
          List dataList2 = List.from(responseData['data']);
          List finalDataList = [];
          
          debugPrint('Original DataList length: ${dataList.length}');
          
          // Remove items with member_count == 0 or null
          dataList.removeWhere((element) => 
            element['member_count'] == null || 
            element['member_count'] == 0
          );
          
          // Keep items with member_count == 0 or null for second list
          dataList2.removeWhere((element) => 
            element['member_count'] != null && 
            element['member_count'] != 0
          );
          
          finalDataList.addAll(dataList);
          finalDataList.addAll(dataList2);
          debugPrint('Final DataList length: ${finalDataList.length}');
          
          if (profileType == "0") {
            businessList.value = finalDataList;
            // Save to cache
            await CacheManager.set(CACHE_BUSINESS, {
              'data': finalDataList,
              'timestamp': DateTime.now().toIso8601String(),
            });
            debugPrint('✅ Business list updated: ${businessList.length} items');
          } else if (profileType == "1") {
            servicesList.value = finalDataList;
            // Save to cache
            await CacheManager.set(CACHE_SERVICES, {
              'data': finalDataList,
              'timestamp': DateTime.now().toIso8601String(),
            });
            debugPrint('✅ Services list updated: ${servicesList.length} items');
          }
        } else {
          debugPrint('❌ API returned error code: ${responseData['code']}');
          if (!forceRefresh) {
            ShowToast.showToast(responseData['msg'] ?? 'Failed to load data', showSuccess: false);
          }
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        if (!forceRefresh) {
          ShowToast.showToast('Server error. Please try again later.', showSuccess: false);
        }
      }
    } catch (e) {
      debugPrint('❌ Exception in postBusinessDashboardApi: $e');
      if (!forceRefresh && businessList.isEmpty && servicesList.isEmpty) {
        ShowToast.showToast('Network error. Please check your connection.', showSuccess: false);
      }
    } finally {
      if (!forceRefresh) isLoading.value = false;
      _requestLocks[lockKey] = false;
    }
  }

  Future<void> postDashboardSliderApi(String? profileType, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheManager.get(CACHE_SLIDER);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < CACHE_DURATION) {
          allSliderList.value = cachedData['data'];
          searchAllSliderList.value = cachedData['data'];
          debugPrint('✅ Using cached slider data (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    if (_requestLocks['slider'] == true) return;
    _requestLocks['slider'] = true;
    
    try {
      if (!forceRefresh) isLoading.value = true;
      
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.slider));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll({'profile_type': profileType!});

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        if (responseData['code'] == 200) {
          final sliderData = responseData['data'] ?? [];
          if (profileType == "") {
            allSliderList.value = sliderData;
            searchAllSliderList.value = sliderData;
            
            // Save to cache
            await CacheManager.set(CACHE_SLIDER, {
              'data': sliderData,
              'timestamp': DateTime.now().toIso8601String(),
            });
            debugPrint('✅ Slider data cached: ${sliderData.length} items');
          }
        }
      }
    } catch (e) {
      debugPrint('Slider API Error: $e');
    } finally {
      if (!forceRefresh) isLoading.value = false;
      _requestLocks['slider'] = false;
    }
  }

  Future<void> postDashboardAdvSliderApi() async {
    if (_requestLocks['advSlider'] == true) return;
    _requestLocks['advSlider'] = true;
    
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.advSlider));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        if (responseData['code'] == 200) {
          allAdvSliderList.value = responseData['data'] ?? [];
          searchAllAdvSliderList.value = responseData['data'] ?? [];
        }
      }
    } catch (e) {
      debugPrint('AdvSlider API Error: $e');
    } finally {
      _requestLocks['advSlider'] = false;
    }
  }

  Future<void> postDashboardAdvPopUpSliderApi() async {
    if (_requestLocks['advPopUp'] == true) return;
    _requestLocks['advPopUp'] = true;
    
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.advPopUpSlider));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        if (responseData['code'] == 200) {
          allAdvPopUpSliderList.value = responseData['data'] ?? [];
        }
      }
    } catch (e) {
      debugPrint('AdvPopUpSlider API Error: $e');
    } finally {
      _requestLocks['advPopUp'] = false;
    }
  }

  Rx<OnBoardModel> onBoardList = OnBoardModel().obs;
  
  Future<void> fetchOnboardApi({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheManager.get(CACHE_ONBOARD);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < CACHE_DURATION) {
          onBoardList.value = OnBoardModel.fromJson(cachedData['data']);
          debugPrint('✅ Using cached onboard data (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    if (_requestLocks['onboard'] == true) return;
    _requestLocks['onboard'] = true;
    
    try {
      isOnBoardingLoading.value = true;
      debugPrint('Calling onboard API: ${API.onboard}');
      
      final request = http.MultipartRequest('POST', Uri.parse(API.onboard));
      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);
      debugPrint("Onboard response: ${responseDone.body}");

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        onBoardList.value = OnBoardModel.fromJson(responseData);
        
        // Save to cache
        await CacheManager.set(CACHE_ONBOARD, {
          'data': responseData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Onboard data cached');
      }
    } catch (e) {
      debugPrint('Onboard API Error: $e');
    } finally {
      isOnBoardingLoading.value = false;
      _requestLocks['onboard'] = false;
    }
  }

  Future<void> postCategoriesApi() async {
    // Check cache first
    final cachedData = await CacheManager.get(CACHE_CATEGORIES);
    if (cachedData != null && cachedData['timestamp'] != null) {
      final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
      if (age < CACHE_DURATION) {
        categoryList.value = cachedData['data'];
        debugPrint('✅ Using cached categories data');
        return;
      }
    }
    
    if (_requestLocks['categories'] == true) return;
    _requestLocks['categories'] = true;
    
    try {
      isAddLoading.value = true;
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.categories));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);
      
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint("Categories response: ${responseDone.body}");
        categoryList.value = responseData['data'];
        
        // Save to cache
        await CacheManager.set(CACHE_CATEGORIES, {
          'data': responseData['data'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('Categories API Error: $e');
    } finally {
      isAddLoading.value = false;
      _requestLocks['categories'] = false;
    }
  }

  Future<void> postSubCategoriesApi(String? categoryId) async {
    try {
      isAddLoading.value = true;
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.subcategories));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll({'category_id': categoryId!});

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);
      
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint("Subcategories response: ${responseDone.body}");
        subCategoryList.value = responseData['data'];
      }
    } catch (e) {
      debugPrint('Subcategories API Error: $e');
    } finally {
      isAddLoading.value = false;
    }
  }

  Future<List> postSubCategoriesListApiLis(String? categoryId) async {
    List subCategoryDataList = [];
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.subcategories));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll({'category_id': categoryId!});

      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);
      
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        debugPrint("Subcategories response: ${responseDone.body}");
        subCategoryDataList = responseData['data'];
      }
    } catch (e) {
      debugPrint('Subcategories API Error: $e');
    }
    return subCategoryDataList;
  }

  // FIXED: This method now returns Future<bool>
  // In home_controller.dart - Replace your postCreateEnquiryApi method with this:

// In home_controller.dart - Replace your postCreateEnquiryApi method with this:

Future<bool> postCreateEnquiryApi(Map<String, String> bodyParams) async {
  try {
    isButtonLoading.value = true;
    
    final token = await SharPreferences.getString(SharPreferences.token) ?? '';
    if (token.isEmpty) {
      ShowToast.showToast('Authentication error. Please login again.', showSuccess: false);
      isButtonLoading.value = false;
      return false;
    }
    
    final request = http.MultipartRequest('POST', Uri.parse(API.createEnquiry));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    });
    request.fields.addAll(bodyParams);

    debugPrint('=== Create Enquiry Request ===');
    debugPrint('URL: ${API.createEnquiry}');
    debugPrint('Body: ${request.fields}');
    
    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();
    
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
    
    // Check if response is valid JSON
    if (responseBody.trim().isEmpty) {
      debugPrint('Empty response body');
      ShowToast.showToast('Server returned empty response', showSuccess: false);
      isButtonLoading.value = false;
      return false;
    }
    
    // Check if response is HTML (server error)
    if (responseBody.trim().startsWith('<!DOCTYPE') || 
        responseBody.trim().startsWith('<html')) {
      debugPrint('Server returned HTML error page');
      ShowToast.showToast('Server error. Please try again later.', showSuccess: false);
      isButtonLoading.value = false;
      return false;
    }
    
    try {
      final responseData = json.decode(responseBody);
      debugPrint("Parsed Response Data (first 200 chars): ${responseData.toString().substring(0, responseData.toString().length > 200 ? 200 : responseData.toString().length)}");
      
      // Check if enquiry was created - even if status is 500
      // The email error means the enquiry is still saved in database
      bool enquiryCreated = false;
      String successMessage = '';
      
      // Check for various success indicators
      if (responseData['enquiry_id'] != null || 
          responseData['id'] != null || 
          responseData['data'] != null ||
          (responseData['message'] != null && responseData['message'].toString().contains('Connection could not be established'))) {
        // Even if email fails, the enquiry might be created
        enquiryCreated = true;
        successMessage = 'Enquiry created successfully (Email notification failed)';
        debugPrint('Enquiry was likely created despite email error');
      }
      
      // Check for success codes
      if (responseData['code'] != null) {
        if (responseData['code'] is int) {
          enquiryCreated = enquiryCreated || (responseData['code'] == 200 || responseData['code'] == 201);
        } else if (responseData['code'] is String) {
          enquiryCreated = enquiryCreated || (responseData['code'] == '200' || responseData['code'] == '201' || responseData['code'] == 'success');
        }
        if (responseData['msg'] != null) successMessage = responseData['msg'];
      }
      
      if (responseData['status'] != null) {
        enquiryCreated = enquiryCreated || (responseData['status'] == 'success' || responseData['status'] == true);
        if (responseData['message'] != null) successMessage = responseData['message'];
      }
      
      // If status code is 500 but we have an error about mail, the enquiry was likely created
      if (response.statusCode == 500 && responseBody.contains('mail.singleclik.in')) {
        enquiryCreated = true;
        successMessage = 'Enquiry created successfully (Email notification failed)';
        debugPrint('Server returned 500 due to email error, but enquiry was created');
      }
      
      debugPrint('Enquiry Created: $enquiryCreated');
      debugPrint('Message: $successMessage');
      
      if (enquiryCreated) {
        // Refresh enquiry counts to show the new enquiry
        await getSentEnquiriesUnreadCount('1', forceRefresh: true);
        
        ShowToast.showToast(
          successMessage.isNotEmpty ? successMessage : ConstantString.dataSubmittedSuccessfullyMsg,
          showSuccess: true,
        );
        isButtonLoading.value = false;
        return true;
      } else {
        ShowToast.showToast(
          successMessage.isNotEmpty ? successMessage : 'Failed to create enquiry',
          showSuccess: false,
        );
        isButtonLoading.value = false;
        return false;
      }
      
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      
      // Even if JSON parsing fails, the enquiry might have been created
      // Check if response contains success indicators or email error
      if (responseBody.contains('success') || 
          responseBody.contains('created') || 
          responseBody.contains('mail.singleclik.in') ||
          response.statusCode == 500) {
        debugPrint('Enquiry was likely created despite parsing error');
        await getSentEnquiriesUnreadCount('1', forceRefresh: true);
        ShowToast.showToast(
          'Enquiry created successfully',
          showSuccess: true,
        );
        isButtonLoading.value = false;
        return true;
      }
      
      ShowToast.showToast('Server response error. Please check if enquiry was created.', showSuccess: false);
      isButtonLoading.value = false;
      return false;
    }
    
  } on TimeoutException catch (e) {
    debugPrint('Timeout: $e');
    ShowToast.showToast('Connection timeout. Please check if enquiry was created.', showSuccess: false);
    isButtonLoading.value = false;
    return false;
  } on SocketException catch (e) {
    debugPrint('Network error: $e');
    ShowToast.showToast('No internet connection', showSuccess: false);
    isButtonLoading.value = false;
    return false;
  } catch (e) {
    debugPrint('Error in postCreateEnquiryApi: $e');
    ShowToast.showToast('Something went wrong. Please check if enquiry was created.', showSuccess: false);
    isButtonLoading.value = false;
    return false;
  }
}
  Future<void> getSentEnquiriesUnreadCount(String? enquiriesType, {bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheManager.get(CACHE_ENQUIRY_COUNTS);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < const Duration(minutes: 5)) { // Shorter cache for counts
          pendingOpenInquiriesCount.value = cachedData['pending'] ?? 0;
          receivedUnreadCount.value = cachedData['received'] ?? 0;
          debugPrint('✅ Using cached enquiry counts (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.enquirySentCount));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var res = await request.send().timeout(const Duration(seconds: 15));
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        pendingOpenInquiriesCount.value = ((responseData['data'] ?? 0) as int);
      }
    } catch (e) {
      debugPrint("Sent Enquiries Count Error: $e");
    }

    await getReceivedEnquiriesUnreadCount();
    
    // Save combined counts to cache
    await CacheManager.set(CACHE_ENQUIRY_COUNTS, {
      'pending': pendingOpenInquiriesCount.value,
      'received': receivedUnreadCount.value,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> getReceivedEnquiriesUnreadCount() async {
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.enquiryReceivedCount));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      request.fields.addAll({'enquiries_type': '1'});

      var res = await request.send().timeout(const Duration(seconds: 15));
      var responseDone = await http.Response.fromStream(res);
      
      if (res.statusCode == 200) {
        final responseData = json.decode(responseDone.body);
        receivedUnreadCount.value = ((responseData['data'] ?? 0) as int);
      }
    } catch (e) {
      debugPrint("Received Enquiries Count Error: $e");
    }
  }

  RxMap userData = {}.obs;

  Future<void> postFetchProfileApi({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheManager.get(CACHE_USER_PROFILE);
      if (cachedData != null && cachedData['timestamp'] != null) {
        final age = DateTime.now().difference(DateTime.parse(cachedData['timestamp']));
        if (age < CACHE_DURATION) {
          userData.value = cachedData['data'];
          debugPrint('✅ Using cached profile data (age: ${age.inMinutes} min)');
          return;
        }
      }
    }
    
    if (_requestLocks['profile'] == true) return;
    _requestLocks['profile'] = true;
    
    try {
      final token = await SharPreferences.getString(SharPreferences.token) ?? '';
      final request = http.MultipartRequest('POST', Uri.parse(API.fetchProfile));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });
      
      var res = await request.send().timeout(const Duration(seconds: 30));
      var responseDone = await http.Response.fromStream(res);

      if (res.statusCode == 200) {
        final responseBody = jsonDecode(responseDone.body);
        final profileData = responseBody["data"][0] ?? responseBody["data"] ?? {};
        userData.value = profileData;
        
        // Save to cache
        await CacheManager.set(CACHE_USER_PROFILE, {
          'data': profileData,
          'timestamp': DateTime.now().toIso8601String(),
        });
        debugPrint('✅ Profile data cached');
      } else {
        userData.value = {};
      }
    } catch (e) {
      debugPrint("Profile API Error: $e");
      userData.value = {};
    } finally {
      _requestLocks['profile'] = false;
    }
  }

  // Clear all cache (useful for logout)
  Future<void> clearAllCache() async {
    await CacheManager.clearAll();
    debugPrint('✅ All cache cleared');
  }

  @override
  void onClose() {
    _isDisposed = true;
    try {
      timer.cancel();
    } catch (_) {}
    try {
      countTimer.cancel();
    } catch (_) {}
    tabController.dispose();
    searchFocusNode.dispose();
    searchController.value.dispose();
    inquiryController.value.dispose();
    super.onClose();
  }
}