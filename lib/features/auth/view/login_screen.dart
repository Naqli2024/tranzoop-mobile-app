import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/auth/model/auth_model.dart';
import 'package:bizoop_driver_app/features/auth/view/launch_screen.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/view/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();
  bool _obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login(AuthViewModel vm) async {
    if (usernameController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      basicWidgets.info(context, "Please enter login credentials");
      return;
    }

    bool success = await vm.login(
      LoginRequest(
        userName: usernameController.text.trim(),
        password: passwordController.text.trim(),
      ),
    );
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      basicWidgets.error(context, vm.errorMessage);
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
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  child: Icon(
                                    Icons.local_shipping_outlined,
                                    color: Colors.white,
                                    size: viewUtil.isTablet ? 45 : 34,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "BIZOOP",
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
                                    "Sign In",
                                    style: TextStyle(
                                      fontSize: viewUtil.isTablet ? 30 : 24,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff1E3A8A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Enter your credentials to continue",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: viewUtil.isTablet ? 20 : 13,
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: basicWidgets.buildTextField(
                                      'Username',
                                      usernameController,
                                      context: context,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: basicWidgets.buildTextField(
                                      'Password',
                                      passwordController,
                                      context: context,
                                      obscureText: _obscurePassword,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                        ),
                                        iconSize: 23,
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  basicWidgets.buildCommonButton(
                                    context,
                                    "Login",
                                    () => login(vm),
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
                                    "Powered by Bizoop",
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
