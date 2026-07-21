import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/auth/model/auth_model.dart';
import 'package:tranzoop_mobile_app/features/auth/view/launch_screen.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/dashboard_screen.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();
  bool showOtp = false;
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> otpFocus = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in otpControllers) {
      c.dispose();
    }
    for (final f in otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> sendOtp(AuthViewModel vm) async {
    if (mobileNoController.text.trim().isEmpty) {
      basicWidgets.info(context, "Please enter mobile number");
      return;
    }

    if(showOtp){
      String otp = otpControllers
          .map((e)=>e.text)
          .join();
      bool success = await vm.verifyOtp(
        VerifyOtpRequest(
          mobile: mobileNoController.text.trim(),
          otp: otp,
        ),
      );
      if (success) {
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          ),
        );
      } else {
        basicWidgets.error(context, vm.errorMessage);
      }

    }else{
      bool success = await vm.sendOtp(
        SendOtpRequest(
          mobile: mobileNoController.text.trim(),
        ),
      );
      if(success){
        setState(() {
          showOtp = true;
        });
      } else {
        basicWidgets.error(context, vm.errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final vm = Provider.of<AuthViewModel>(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LaunchScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: basicWidgets.buildCommonEmptyAppBar(Color(0xff1E3A8A)),
        body: vm.isLoading
          ? basicWidgets.loading()
          : SafeArea(
          child: SingleChildScrollView(
            child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xff1E3A8A), Color(0xff2563EB)],
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            CircleAvatar(
                              maxRadius: viewUtil.isTablet ? 40 : 32,
                              backgroundColor: Colors.white.withOpacity(0.15),
                              child: Icon(
                                Icons.local_shipping_outlined,
                                color: Colors.white,
                                size: viewUtil.isTablet ? 45 : 34,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "TRANZOOP",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: viewUtil.isTablet ? 30 : 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 0),
                            Text(
                              "Transport Management Driver App",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: viewUtil.isTablet ? 18 : 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: viewUtil.isTablet ? 22 : 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 15),
                            Expanded(
                              child: Image.asset(
                                'assets/images/login.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(0, -25),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: viewUtil.isTablet ? 50 : 20,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: viewUtil.isTablet ? 30 : 24,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                showOtp ? "Verify OTP" : "Sign In",
                                style: TextStyle(
                                  fontSize: viewUtil.isTablet ? 30 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff1E3A8A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                showOtp
                                    ? "Enter the 6-digit code sent to your mobile"
                                    : "Enter your mobile number to continue",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: viewUtil.isTablet ? 20 : 13,
                                ),
                              ),
                              const SizedBox(height: 25),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: showOtp
                                    ? Column(
                                  key: const ValueKey(1),
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "+91 ${mobileNoController.text}",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          GestureDetector(
                                            onTap: () {
                                              for (final c in otpControllers) {
                                                c.clear();
                                              }
                                              setState(() {
                                                showOtp = false;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.edit,
                                                  size: 14,
                                                  color: AppColors.btnColor,
                                                ),
                                                SizedBox(width: 6),
                                                Text(
                                                  "Change Mobile Number",
                                                  style: TextStyle(
                                                    color: AppColors.btnColor,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 25),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: List.generate(
                                          6,
                                          (index) => SizedBox(
                                            width: 45,
                                            child: TextField(
                                              controller: otpControllers[index],
                                              focusNode: otpFocus[index],
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType.number,
                                              maxLength: 1,
                                              decoration: const InputDecoration(
                                                counterText: "",
                                              ),
                                              inputFormatters: [
                                                FilteringTextInputFormatter.digitsOnly,
                                              ],
                                              onChanged: (value) {
                                                if (value.isNotEmpty && index < 5) {
                                                  otpFocus[index + 1].requestFocus();
                                                }

                                                if (value.isEmpty && index > 0) {
                                                  otpFocus[index - 1].requestFocus();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),
                                  ],
                                )
                                    : Padding(
                                  key: const ValueKey(2),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: viewUtil.isTablet ? 40 : 20),
                                  child: TextField(
                                    controller: mobileNoController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      counterText: "",
                                      labelText: "Mobile Number",
                                      prefixText: "+91 ",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              basicWidgets.buildCommonButton(
                                context,
                                showOtp ? "Verify OTP" : "Continue",
                                () => sendOtp(vm)
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Divider(),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Version 1.0.0",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: viewUtil.isTablet ? 18 : 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Powered by Tranzoop",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: viewUtil.isTablet ? 18 : 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 2,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LaunchScreen(),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        maxRadius: viewUtil.isTablet ? 30 : 20,
                        backgroundColor: Colors.white.withOpacity(0.15),
                        child: Icon(
                          Icons.clear,
                          color: Colors.white,
                          size: viewUtil.isTablet ? 32 : 22,
                        ),
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
