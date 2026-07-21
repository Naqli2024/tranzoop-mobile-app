import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/CommonSuccessScreen.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/view/unloading_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class InTransitScreen extends StatefulWidget {
  final CurrentTrip trip;
  const InTransitScreen({super.key, required this.trip});

  @override
  State<InTransitScreen> createState() => _InTransitScreenState();
}

class _InTransitScreenState extends State<InTransitScreen>with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final TextEditingController odometerController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();
  bool isExpanded = false;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> completeTrip() async {
    final vm = context.read<TripViewModel>();
    if (odometerController.text.trim().isEmpty) {
      basicWidgets.error(context, "Please enter odometer");
      return;
    }

    final success = await vm.arriveTrip(
      widget.trip.id,
      ArrivalRequest(
        arrivalOdometer: int.parse(
          odometerController.text.trim(),
        ),
        remarks: remarksController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "Destination Reached",
            message:
            "Your vehicle has arrived at the destination. Start the unloading process to complete the delivery.",
            nextStep: "Proceed to UnLoading",
            buttonText: "Start Unloading",
            showNextStep: true,
            nextStepIcon: Icons.inventory_2_outlined,
            showSummaryCard: false,
            nextScreen: UnLoadingScreen(trip: widget.trip),
          ),
        ),
      );
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              flex: isExpanded ?3 :8,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.map,
                      size: 80,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 15,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: isExpanded ?8 :3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(35),
                  ),
                  boxShadow: [ BoxShadow( color: Colors.black.withOpacity(.15), blurRadius: 10, ), ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      currentLocationCard(),
                      const SizedBox(height: 10),
                      basicWidgets.buildSlideActionButton(
                        context: context,
                        animation: _animation,
                        text: "Reached Destination",
                        isTablet: viewUtil.isTablet,
                        outerColor: AppColors.btnColor,
                        innerColor: const Color(0xff6889da),
                        onSubmit: () => _showArrivalBottomSheet(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showArrivalBottomSheet() async {
    odometerController.clear();
    remarksController.clear();

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
                Icons.flag_circle,
                color: AppColors.btnColor,
                size: viewUtil.isTablet ? 45 : 34,
              ),
              const SizedBox(height: 10),
              Text(
                "Arrival Details",
                style: TextStyle(
                  fontSize: viewUtil.isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              basicWidgets.buildTextField(
                "Arrival Odometer *",
                odometerController,
                context: context,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              basicWidgets.buildTextField(
                "Remarks",
                remarksController,
                context: context,
                maxLines: 3,
              ),
              const SizedBox(height: 25),
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
                      basicWidgets.error(
                        context,
                        "Please enter odometer reading",
                      );
                      return;
                    }

                    Navigator.pop(context);

                    await completeTrip();
                  },
                  child: const Text(
                    "Confirm Arrival",
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

  Widget currentLocationCard() {
    ViewUtil viewUtil = ViewUtil(context);
    final vm = context.watch<AuthViewModel>();
    final cusVm = context.watch<HomeViewModel>();
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_shipping,
                  color: AppColors.btnColor,
                  size: viewUtil.isTablet ?38 :28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Trip In Progress",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: viewUtil.isTablet ?22 :16,
                      ),
                    ),
                    Text(
                      "Trip ID: ${widget.trip.tripNo}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: viewUtil.isTablet ?18 :12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(.3),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.center,
            child: isExpanded
                ? Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: Colors.green,
                            size: viewUtil.isTablet ?30 :20,
                          ),
                          Container(
                            width: 2,
                            height: viewUtil.isTablet ?75 :70,
                            color: Colors.grey.shade300,
                          ),
                          Icon(
                            Icons.flag,
                            color: Colors.red,
                            size: viewUtil.isTablet ?30 :20,
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current Location",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?18 :12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trip.origin.location,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: viewUtil.isTablet ?20 :15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${widget.trip.origin.city},${widget.trip.origin.state}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?16 :13,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Text(
                              "Delivery Location",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?18 :12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trip.destination.location,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: viewUtil.isTablet ?20 :15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${widget.trip.destination.city},${widget.trip.destination.state}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?16 :13,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  customerCard(cusVm.customer),
                  Divider(color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _tripInfo(
                          Icons.inventory_2_outlined,
                          "Cargo",
                          widget.trip.commodity,
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.scale,
                          "Weight",
                          widget.trip.weight.toString(),
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.route,
                          "Distance",
                          "100 KM",
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.timer_outlined,
                          "Time",
                          "45 mins",
                        ),
                      ),
                    ],
                  ),
                ],
              )
                : SizedBox.shrink()
            )
        ],
      ),
    );
  }

  Widget customerCard(Customer? customer) {
    ViewUtil viewUtil = ViewUtil(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.btnColor.withOpacity(.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.business,
                  color: AppColors.btnColor,
                  size: viewUtil.isTablet ? 32 : 24,
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer?.companyName ??'',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: viewUtil.isTablet ? 22 : 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer?.contactPerson ??'',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: viewUtil.isTablet ? 17 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _callCustomer(customer?.mobile.toString() ??''),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.call,
                        size: viewUtil.isTablet ?25 :15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Call",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet ?18 :11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.btnColor,
                size: viewUtil.isTablet ? 24 : 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  customer?.billingAddress ??'',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: viewUtil.isTablet ? 17 : 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _callCustomer(mobileNo) async {
    if (mobileNo == null || mobileNo.isEmpty) return;

    final uri = Uri.parse("tel:$mobileNo");

    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  Widget _tripInfo(
      IconData icon,
      String title,
      String value,
      ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.btnColor,
          size: viewUtil.isTablet ?30 :22,
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: viewUtil.isTablet ?18 :11,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: viewUtil.isTablet ?18 :13,
          ),
        ),
      ],
    );
  }

}
