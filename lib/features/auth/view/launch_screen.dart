import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/auth/view/login_screen.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(
        const AssetImage('assets/images/building.webp'),
        context,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/building.webp',
            fit: BoxFit.cover,
            filterQuality: FilterQuality.low,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.15),
                  const Color(0xff001B3D).withOpacity(0.82),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BIZOOP",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: viewUtil.isTablet ?40 :34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "SMART BOS · V1.0",
                      style: TextStyle(
                        color: Colors.white.withOpacity(.68),
                        fontSize: viewUtil.isTablet ?18 :12,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Container(
                            width: viewUtil.isTablet ? 450 : 300,
                            padding: EdgeInsets.symmetric(
                              horizontal: viewUtil.isTablet ? 35 : 24,
                              vertical: viewUtil.isTablet ? 45 : 30,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff133350).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xff001B3D).withOpacity(0.45),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 15),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: AppColors.btnColor.withOpacity(0.18),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.btnColor.withOpacity(0.35),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.white.withOpacity(0.8),
                                    size: viewUtil.isTablet ? 60 : 32,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Transport Management",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: viewUtil.isTablet ? 25 : 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "Driver App",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.70),
                                    fontSize: viewUtil.isTablet ? 20 : 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    buildTag("Trips"),
                                    buildTag("Fleet"),
                                    buildTag("GPS"),
                                    buildTag("Tracking"),
                                    buildTag("Delivery"),
                                    buildTag("Driver"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTag(String text) {
    ViewUtil viewUtil = ViewUtil(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.btnColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.btnColor.withOpacity(0.28),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.90),
          fontSize: viewUtil.isTablet ? 18 : 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}