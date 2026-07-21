import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/CommonSuccessScreen.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/model/loading_unloading_model.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/viewmodal/loading_unloading_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/trips/view/confirm_delivery_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';

class UnLoadingScreen extends StatefulWidget {
  final CurrentTrip trip;
  const UnLoadingScreen({super.key, required this.trip});

  @override
  State<UnLoadingScreen> createState() => _UnLoadingScreenState();
}

class _UnLoadingScreenState extends State<UnLoadingScreen> with SingleTickerProviderStateMixin {
  final TextEditingController odometerController = TextEditingController();
  late Animation<double> _animation;
  late AnimationController _animationController;
  BasicWidgets basicWidgets = BasicWidgets();
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        setState(() {
          _seconds++;
        });
      },
    );
  }

  String get formattedTime {
    final hours = (_seconds ~/ 3600)
        .toString()
        .padLeft(2, '0');

    final minutes = ((_seconds % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_seconds % 60)
        .toString()
        .padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }

  Future<void> _completeUnLoading() async {
    final vm = context.read<AuthViewModel>();
    final cusVm = context.read<HomeViewModel>();
    final unloadingVm = context.read<LoadingUnloadingViewmodel>();

    final request = UnloadingRequest(
      odometer: odometerController.text,
      unloadingBy: vm.driver?.data?.name ??'',
      receiverName: cusVm.customer?.companyName ??'',
      receiverMobile: cusVm.customer?.mobile.toString() ??'',
    );

    final success = await unloadingVm.unloadingTrip(
      widget.trip.id,
      request,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "UnLoading Completed!",
            message: unloadingVm.successMessage,
            nextStep: "Proceed to Destination",
            buttonText: "Confirm OTP",
            showNextStep: false,
            showSummaryCard: true,
            summaryItems: [
              SummaryItem(
                label: "Pickup Location",
                value: widget.trip.origin.location,
              ),
              SummaryItem(
                label: "Delivery Location",
                value: widget.trip.destination.location,
              ),
              SummaryItem(
                label: "UnLoaded By",
                value: vm.driver?.data?.name ??'',
              ),
              SummaryItem(
                label: "Receiver Name",
                value: cusVm.customer?.companyName ??'',
              ),
            ],
            nextScreen: DeliveryConfirmationScreen(trip: widget.trip),
          ),
        ),
      );
    } else {
      basicWidgets.error(context, unloadingVm.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: basicWidgets.buildAppBarWithRadius(
        context: context,
        title: "UnLoading",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 25,
                    color: AppColors.btnColor,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "UnLoading Duration",
                      style: TextStyle(color: Colors.grey,fontSize: viewUtil.isTablet ?20 :16),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: AppColors.btnColor,
                      fontWeight: FontWeight.bold,
                      fontSize: viewUtil.isTablet ?34 :18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,color: AppColors.btnColor,size: viewUtil.isTablet ?30 :20),
                      SizedBox(width: 8),
                      Text(
                          "Cargo Details",
                          style: basicWidgets.coloredText(context, AppColors.btnColor, viewUtil.isTablet ?22 :16, FontWeight.w500)
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _detailRow("Trip ID", widget.trip.tripNo),
                  const Divider(),
                  _detailRow("Items", widget.trip.commodity),
                  const Divider(),
                  _detailRow("Consignment Weight", "${widget.trip.weight}${widget.trip.uom}"),
                  const Divider(),
                  _detailRow("Status", "In Progress"),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.route,
                        color: AppColors.btnColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Route Information",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: viewUtil.isTablet ?22 :16,
                            color: AppColors.btnColor
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            height: 16,
                            width: 16,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.trip.origin.location,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${widget.trip.origin.city},${widget.trip.origin.state}",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Destination",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              widget.trip.destination.location,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${widget.trip.destination.city},${widget.trip.destination.state}",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    bottomNavigationBar: BottomAppBar(
    height: viewUtil.isTablet ?90 :120,
    color: Colors.transparent,
      child: basicWidgets.buildSlideActionButton(
        context: context,
        animation: _animation,
        text: "Done UnLoading",
        isTablet: viewUtil.isTablet,
        outerColor: AppColors.btnColor,
        innerColor: const Color(0xff6889da),
        onSubmit: () => _showArrivalBottomSheet(),
      ),
    )
    );
  }

  Future<void> _showArrivalBottomSheet() async {
    odometerController.clear();
    await showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        final viewUtil = ViewUtil(context);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.btnColor,
                size: viewUtil.isTablet ? 45 : 34,
              ),
              const SizedBox(height: 10),
              Text(
                "Unloading Details",
                style: TextStyle(
                  fontSize: viewUtil.isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              basicWidgets.buildTextField(
                "Enter Odometer Reading *",
                odometerController,
                context: context,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (odometerController.text.trim().isEmpty) {
                      BasicWidgets().error(
                        context,
                        "Please enter odometer reading",
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await _completeUnLoading();
                  },
                  child: const Text(
                    "Complete Unloading",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    ViewUtil viewUtil = ViewUtil(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title, style: TextStyle(color: Colors.grey,fontSize: viewUtil.isTablet ?20 :16)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600,color: title == "Status"?Colors.orange :Colors.black,
              fontSize: viewUtil.isTablet ?20 :16
          )),
        ],
      ),
    );
  }
}
