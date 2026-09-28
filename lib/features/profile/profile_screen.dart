import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bizoop_driver_app/features/profile/company_info.dart';
import 'package:bizoop_driver_app/features/profile/notification_screen.dart';
import 'package:bizoop_driver_app/features/profile/personal_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  BasicWidgets basicWidgets = BasicWidgets();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchDriverData();
    });
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        SystemUiOverlay.top,
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final vm = context.watch<AuthViewModel>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        basicWidgets.showLogoutDialog(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF5F7FA),
        appBar: basicWidgets.buildCommonEmptyAppBar(AppColors.btnColor),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: viewUtil.isTablet
                    ?MediaQuery.sizeOf(context).height * 0.3
                    :MediaQuery.sizeOf(context).height * 0.3,
                padding: const EdgeInsets.only(top: 20, bottom: 25),
                decoration: const BoxDecoration(
                  color: AppColors.btnColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: viewUtil.isTablet ?60 :45,
                      backgroundColor: Colors.white,
                      child: Text(vm.driver?.data?.name.substring(0,1) ??'',
                          style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(height: 12),
                    Text(
                      vm.driver?.data?.name ?? "",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: viewUtil.isTablet ?30 :22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Driver ID : ${vm.driver?.data?.driverId ?? ""}",
                      style: TextStyle(color: Colors.white.withOpacity(.8),fontSize: viewUtil.isTablet ?20 :14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: viewUtil.isTablet ?22 :18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            vm.driver?.data?.mobile.toString() ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: viewUtil.isTablet ?20 :14
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem(vm.driver?.data?.totalTrips.toString() ?? "", "Trips"),
                            _divider(),
                            _statItem(vm.driver?.data?.experience.toString() ??'', "Years of Experience"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.04),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            profileTile(
                              Icons.person_outline,
                              "Personal Information",
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PersonalInfoScreen(),
                                  ),
                                );
                              },
                            ),
                            profileTile(
                              Icons.apartment_outlined,
                              "Company Information",
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CompanyInfoScreen(businessId: vm.driver?.data?.businessId ??''),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: viewUtil.isTablet ?20 :14),
                            minimumSize: const Size(double.infinity, 55),
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () {
                            basicWidgets.showLogoutDialog(context);
                          },
                          child: Text(
                            "LOGOUT",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: viewUtil.isTablet ?22 :14
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    ViewUtil viewUtil = ViewUtil(context);
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: viewUtil.isTablet ?24 :18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(color: Colors.grey.shade600,fontSize: viewUtil.isTablet ?20 :14)),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey.shade300);
  }

  Widget profileTile(IconData icon, String title, VoidCallback onTap) {
    ViewUtil viewUtil = ViewUtil(context);
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: viewUtil.isTablet ?15 :0,horizontal: viewUtil.isTablet ?20 : 15),
        leading: Container(
          width: viewUtil.isTablet ?50 :42,
          height: viewUtil.isTablet ?50 :42,
          decoration: BoxDecoration(
            color: AppColors.btnColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.btnColor, size: viewUtil.isTablet ?30 :20),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, fontSize: viewUtil.isTablet ?24 :16)),
        trailing: Icon(Icons.chevron_right, size: viewUtil.isTablet ?30 :20),
        onTap: onTap,
      ),
    );
  }
}
