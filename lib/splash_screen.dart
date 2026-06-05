import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:single_clik/utils/shar_preferences.dart';
import 'constants/constant_color.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  // bool login = false;
  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  void checkLogin() async
  {
/*    print("""
FCM"""+await SharPreferences.getString(
        SharPreferences.fcmToken));*/
    //Timer(const Duration(seconds: 2,), () => Get.offNamed('getStarted'),);

    bool login = await SharPreferences.getBoolean(SharPreferences.isLogin) ?? false;

    Timer(Duration(seconds: 2), () {
      if(login) {
        Get.offNamed('home');
      } else {
        Get.offNamed('getStarted');
      }
        });
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Image.asset(
            "assets/images/sc_logo_new.png",
            height: height * 0.25,
          ),
          SizedBox(height: height * 0.01),
          Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "SINGLE",
                    style: TextStyle(
                      fontSize: 40,
                      color: ConstantColor.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    " CLIK",
                    style: TextStyle(
                      fontSize: 40,
                      color: ConstantColor.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

}
