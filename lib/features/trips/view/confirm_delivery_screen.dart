import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/CommonSuccessScreen.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/inspection/view/post_trip_inspection.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';

class DeliveryConfirmationScreen extends StatefulWidget {
  final CurrentTrip trip;
  const DeliveryConfirmationScreen({super.key, required this.trip});

  @override
  State<DeliveryConfirmationScreen> createState() =>
      _DeliveryConfirmationScreenState();
}

class _DeliveryConfirmationScreenState
    extends State<DeliveryConfirmationScreen> {
  final BasicWidgets basicWidgets = BasicWidgets();
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _secondsRemaining = 30;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendOtp();
    });
    startOtpTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final vm = context.read<TripViewModel>();

    final success = await vm.resendOtp(widget.trip.id);

    if (!mounted) return;

    if (!success) {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  Future<void> verifyOtp() async {
    String otp = otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      BasicWidgets().error(context, "Enter valid OTP");
      return;
    }

    final vm = context.read<TripViewModel>();

    final success = await vm.verifyOtp(
      widget.trip.id,
      otp,
    );
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "Delivery Confirmed",
            message: vm.successMessage,
            nextStep: "Proceed to Post Trip Inspection",
            buttonText: "Continue",
            showNextStep: true,
            nextStepIcon: Icons.verified_user_outlined,
            showSummaryCard: false,
            nextScreen: PostTripInspectionScreen(trip: widget.trip),
          ),
        ),
      );
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  void startOtpTimer() {
    canResend = false;
    _secondsRemaining = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
        setState(() {
          canResend = true;
        });
      }
    });
  }

  Widget otpBox(int index) {
    ViewUtil viewUtil = ViewUtil(context);
    return SizedBox(
      width: viewUtil.isTablet ? 70 : 50,
      height: viewUtil.isTablet ? 80 : 60,
      child: TextFormField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < focusNodes.length - 1) {
                FocusScope.of(context).requestFocus(
                  focusNodes[index + 1],
                );
              } else {
                FocusScope.of(context).unfocus();
              }
            }
          }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final cusVm = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_outlined),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Delivery Confirmation",
                      style: TextStyle(
                        fontSize: viewUtil.isTablet ? 30 : 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Image.asset('assets/images/otp.png'),
              const SizedBox(height: 25),
              Text(
                "Enter the OTP sent to the customer's mobile number\n${cusVm.customer?.mobile ?? ''}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: viewUtil.isTablet ? 22 : 18,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) => otpBox(index)),
              ),
              const SizedBox(height: 30),
              canResend
                  ? TextButton(
                      onPressed: () async {
                        final vm = context.read<TripViewModel>();
                        final success = await vm.resendOtp(widget.trip.id);

                        if (!mounted) return;

                        if (success) {
                          for (final controller in otpControllers) {
                            controller.clear();
                          }
                          startOtpTimer();
                          basicWidgets.success(context, vm.successMessage);
                        } else {
                          basicWidgets.error(context, vm.errorMessage);
                        }
                      },
                      child: Text(
                        "Resend OTP",
                        style: TextStyle(
                          color: AppColors.btnColor,
                          fontWeight: FontWeight.bold,
                          fontSize: viewUtil.isTablet ? 22 : 18,
                        ),
                      ),
                    )
                  : Text(
                      "Resend OTP in 00:${_secondsRemaining.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: viewUtil.isTablet ? 22 : 16,
                      ),
                    ),
              const Spacer(),
              basicWidgets.buildCommonButton(context, 'Verify OTP', verifyOtp),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
