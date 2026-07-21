import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/view/fuel_entry_screen.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/view/upload_fuel_entry.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/inspection/view/post_trip_inspection.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/view/loading_screen.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/view/unloading_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/view/confirm_delivery_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/view/in_transit_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/view/new_trips_notification_screen.dart';
import 'package:tranzoop_mobile_app/features/profile/notification_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/view/pickup_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/view/start_trip_screen.dart';
import 'package:tranzoop_mobile_app/features/weight_bridge/view/weight_bridge_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  BasicWidgets basicWidgets = BasicWidgets();
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().fetchDriverData();
      context.read<HomeViewModel>().fetchCurrentTrip();
      context.read<HomeViewModel>().fetchDriverData();
    });
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top],
    );
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return "Good Morning!";
    } else if (hour >= 12 && hour < 17) {
      return "Good Afternoon!";
    } else if (hour >= 17 && hour < 21) {
      return "Good Evening!";
    } else {
      return "Good Night!";
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final vm = context.watch<HomeViewModel>();
    final authVm = context.watch<AuthViewModel>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        basicWidgets.showLogoutDialog(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: basicWidgets.buildCommonEmptyAppBar(AppColors.btnColor),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                color: AppColors.btnColor,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: viewUtil.isTablet ? 35 : 25,
                      backgroundColor: Colors.white,
                      child: Text(authVm.driver?.data?.name.substring(0,1) ??'',
                      style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold))
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hello, ${authVm.driver?.data?.name ?? ""}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: viewUtil.isTablet ? 25 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            getGreeting(),
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: viewUtil.isTablet ? 18 : 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NotificationScreen(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: viewUtil.isTablet ? 35 : 25,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            height: 10,
                            width: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: viewUtil.isTablet ? 25 : 15),
                    GestureDetector(
                      onTap: () {
                        basicWidgets.showLogoutDialog(context);
                      },
                      child: Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                        size: viewUtil.isTablet ? 35 : 25,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.btnColor,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                        child: Container(
                          height: MediaQuery.sizeOf(context).height,
                          decoration: BoxDecoration(color: Colors.white),
                          child: Column(
                            children: [
                              // const SizedBox(height: 15),
                              // Container(
                              //   margin: const EdgeInsets.symmetric(horizontal: 16),
                              //   padding: const EdgeInsets.symmetric(
                              //     horizontal: 18,
                              //     vertical: 16,
                              //   ),
                              //   decoration: BoxDecoration(
                              //     gradient: LinearGradient(
                              //       colors: isOnline
                              //           ? [
                              //         const Color(0xffE8F8EE),
                              //         const Color(0xffF6FFFA),
                              //       ]
                              //           : [
                              //         const Color(0xffFFF5F5),
                              //         Colors.white,
                              //       ],
                              //     ),
                              //     borderRadius: BorderRadius.circular(18),
                              //     border: Border.all(
                              //       color: isOnline
                              //           ? Colors.green.shade300
                              //           : Colors.red.shade300,
                              //       width: 1.2,
                              //     ),
                              //     boxShadow: [
                              //       BoxShadow(
                              //         color: Colors.black.withOpacity(.06),
                              //         blurRadius: 12,
                              //         offset: const Offset(0, 5),
                              //       ),
                              //     ],
                              //   ),
                              //   child: Row(
                              //     children: [
                              //       Container(
                              //         width: viewUtil.isTablet ? 62 : 54,
                              //         height: viewUtil.isTablet ? 62 : 54,
                              //         decoration: BoxDecoration(
                              //           color: isOnline
                              //               ? Colors.green.withOpacity(.12)
                              //               : Colors.red.withOpacity(.12),
                              //           shape: BoxShape.circle,
                              //         ),
                              //         child: Icon(
                              //           Icons.online_prediction,
                              //           color: isOnline ? Colors.green : Colors.red,
                              //           size: viewUtil.isTablet ? 34 : 28,
                              //         ),
                              //       ),
                              //       const SizedBox(width: 16),
                              //       Expanded(
                              //         child: Column(
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             Row(
                              //               children: [
                              //                 Container(
                              //                   width: 10,
                              //                   height: 10,
                              //                   decoration: BoxDecoration(
                              //                     color: isOnline
                              //                         ? Colors.green
                              //                         : Colors.red,
                              //                     shape: BoxShape.circle,
                              //                   ),
                              //                 ),
                              //                 const SizedBox(width: 8),
                              //                 Text(
                              //                   isOnline ? "You're Online" : "You're Offline",
                              //                   style: TextStyle(
                              //                     fontSize: viewUtil.isTablet ? 22 : 17,
                              //                     fontWeight: FontWeight.bold,
                              //                     color: isOnline
                              //                         ? Colors.green.shade700
                              //                         : Colors.red.shade700,
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //             const SizedBox(height: 4),
                              //             Text(
                              //               isOnline
                              //                   ? "Ready to receive new trips"
                              //                   : "Turn on to receive trip requests",
                              //               style: TextStyle(
                              //                 color: Colors.grey.shade600,
                              //                 fontSize: viewUtil.isTablet ? 16 : 12,
                              //               ),
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //       Transform.scale(
                              //         scale: viewUtil.isTablet ? 1.4 : 1.1,
                              //         child: Switch(
                              //           value: isOnline,
                              //           activeColor: Colors.white,
                              //           activeTrackColor: Colors.green,
                              //           inactiveThumbColor: Colors.white,
                              //           inactiveTrackColor: Colors.grey.shade400,
                              //           trackOutlineColor:
                              //           WidgetStateProperty.all(Colors.transparent),
                              //           onChanged: (value) {
                              //             setState(() {
                              //               isOnline = value;
                              //             });
                              //
                              // if (value) {
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (_) =>
                              //       const NewTripsNotificationScreen(),
                              //     ),
                              //   );
                              // }
                              //           },
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Trips",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: viewUtil.isTablet ? 22 : 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _tripCard(
                                        title: "Total Trips",
                                        count: vm.driverData?.data.summary.totalTrips.toString() ?? "0",
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _tripCard(
                                        title: "In Progress",
                                        count: vm.driverData?.data.summary.runningTrips.toString() ?? "0",
                                        color: Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _tripCard(
                                        title: "Completed",
                                        count: vm.driverData?.data.summary.completedTrips.toString() ?? "0",
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Active Trip",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: viewUtil.isTablet ? 22 : 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: vm.isLoading
                                    ? Center(child: basicWidgets.loading())
                                    : vm.tripData?.data == null
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Lottie.asset(
                                              "assets/images/no_trip.json",
                                              width: 200,
                                              height: 100,
                                              fit: BoxFit.contain,
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "No Active Trip",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "You're all caught up.\nNew trips will appear here.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SingleChildScrollView(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: _buildTripCard(vm.tripData!.data!),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildTripCard(CurrentTrip trip) {
    ViewUtil viewUtil = ViewUtil(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border(
          right: BorderSide(color: AppColors.btnColor, width: 4),
          left: BorderSide(color: AppColors.btnColor, width: 4),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                trip.tripNo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: viewUtil.isTablet ? 18 : 14,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trip.tripStatus,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: viewUtil.isTablet ? 16 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  trip.origin.location,
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 18 : 14,
                  ),
                ),
              ),
              Icon(Icons.arrow_right_alt, size: viewUtil.isTablet ? 30 : 20),
              Expanded(
                child: Text(
                  trip.destination.location,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 18 : 14,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  "${trip.origin.city}, ${trip.origin.state}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 18 : 12,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  "${trip.destination.city}, ${trip.destination.state}",
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 18 : 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(child: Text(trip.commodity)),
              Text(
                "${trip.weight}${trip.uom}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FuelEntryScreen(trip: trip),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_gas_station, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        "View Fuel Bill",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () =>
                    navigateByTripStatus(context, trip.tripStatus, trip),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: trip.tripStatus == "Pre Trip Pending"
                        ? Colors.green
                        : AppColors.btnColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trip.tripStatus == "Pre Trip Pending"
                            ? "Start Trip"
                            : "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_double_arrow_right,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildTripProgress(int currentStep) {
    return Row(
      children: List.generate(7, (index) {
        final completed = index <= currentStep;

        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 5,
                backgroundColor: completed
                    ? AppColors.btnColor
                    : Colors.grey.shade300,
              ),
              if (index != 6)
                Expanded(
                  child: Container(
                    height: 2,
                    color: completed
                        ? AppColors.btnColor
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  void navigateByTripStatus(
    BuildContext context,
    String status,
    CurrentTrip trip,
  ) async {
    switch (status) {
      case "Pre Trip Pending":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewTripsNotificationScreen(trip: trip),
          ),
        );
        break;

      case "Reached Pickup":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoadingScreen(trip: trip)),
        );
        break;

      case "Ready For Loading":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PickupScreen(trip: trip)),
        );
        break;

      case "Documents Pending":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeightBridgeScreen(trip: trip)),
        );
        break;

      case "Ready To Start":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => StartTripScreen(trip: trip)),
        );
        break;

      case "In Transit":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => InTransitScreen(trip: trip)),
        );
        break;

      case "Unloading":
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UnLoadingScreen(trip: trip)),
        );
        break;

      case "Delivery OTP Pending":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DeliveryConfirmationScreen(trip: trip),
          ),
        );
        break;

      case "Completed":
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostTripInspectionScreen(trip: trip),
          ),
        );
        break;

      default:
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NewTripsNotificationScreen(trip: trip),
          ),
        );
    }
  }

  Widget _tripCard({
    required String title,
    required String count,
    required Color color,
  }) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: viewUtil.isTablet ? 30 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: viewUtil.isTablet ? 20 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
