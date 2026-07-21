import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/inspection/view/pre_trip_inspection.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';

class NewTripsNotificationScreen extends StatefulWidget {
  final CurrentTrip trip;
  const NewTripsNotificationScreen({super.key, required this.trip});

  @override
  State<NewTripsNotificationScreen> createState() =>
      _NewTripsNotificationScreenState();
}

class _NewTripsNotificationScreenState extends State<NewTripsNotificationScreen>
    with SingleTickerProviderStateMixin {
  BasicWidgets basicWidgets = BasicWidgets();
  late Animation<double> _animation;
  late AnimationController _animationController;
  bool hasTrips = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TripViewModel>().fetchTrip(widget.trip.id);
    });
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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TripViewModel>();
    return hasTrips
        ? Scaffold(
      appBar: basicWidgets.buildCommonAppBar(
        context: context,
        title: "New Trip Assigned",
      ),
      body: _buildTripDetails(widget.trip,vm.trip?.data,vm.customer))
        : Scaffold(
      appBar: basicWidgets.buildCommonAppBar(
        context: context,
        title: "Trips",
      ),
      body: _buildNoTrip(),
    );
  }

  Widget _buildTripDetails(CurrentTrip trip,TripData? vm, Customer? customer) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.btnColor, Colors.white, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Text(
            'You have been assigned a new trip. Please review the trip details and confirm your acceptance.',
            textAlign: TextAlign.center,
            style: basicWidgets.coloredText(
              context,
              Colors.white,
              viewUtil.isTablet ?20 :13,
              FontWeight.w500,
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("Trip ID", trip.tripNo, isHeader: true),
                  const Divider(),
                  _buildRow("Vehicle No", vm?.vehicle.regNo ??''),
                  const Divider(),
                  _buildRow("Vehicle Name", "${vm?.vehicle.make ?? ""} (${vm?.vehicle.model ?? ''})"),
                  const Divider(),
                  _buildRow("Pickup", "${trip.origin.location}, ${trip.origin.city}"),
                  const Divider(),
                  _buildRow("Delivery", "${trip.destination.location}, ${trip.destination.city}"),
                  const Divider(),
                  _buildRow("Cargo", trip.commodity),
                  const Divider(),
                  _buildRow("Weight", "${trip.weight} Ton"),
                  const Divider(),
                  _buildLocationRow(
                    "Customer Details",
                    "${customer?.companyName ?? "N/A"} (${customer?.contactPerson ?? "N/A"})",
                    customer?.mobile.toString() ?? "",
                  ),
                  SizedBox(height: 5),
                  _buildRow('Address', customer?.billingAddress ?? "N/A")
                ],
              ),
            ),
          ),
          const Spacer(),
          basicWidgets.buildSlideActionButton(
            context: context,
            animation: _animation,
            text: "Accept Order",
            isTablet: viewUtil.isTablet,
            outerColor: AppColors.btnColor,
            innerColor: const Color(0xff6889da),
            onSubmit: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PreTripInspectionScreen(trip: widget.trip),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNoTrip() {
    ViewUtil viewUtil = ViewUtil(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              width: MediaQuery.sizeOf(context).width,
              child: Image.asset(
                'assets/images/no_trips.png',
                fit: BoxFit.contain,
              ),
            ),
            // const SizedBox(height: 25),
            Text(
              "No Trips Assigned",
              style: TextStyle(
                fontSize: viewUtil.isTablet ?30 :22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "You currently have no assigned trips.\nNew trip requests will appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: viewUtil.isTablet ?20 :14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.btnColor, size: 20),
                    SizedBox(width: 4),
                    Text(
                      "Back",
                      style: TextStyle(
                        color: AppColors.btnColor,
                        fontWeight: FontWeight.w600,
                        fontSize: viewUtil.isTablet ?22 :14
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHeader = false}) {
    ViewUtil viewUtil = ViewUtil(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: viewUtil.isTablet ?20 :12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: isHeader ? viewUtil.isTablet ?18 :16 : viewUtil.isTablet ?20 :14,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(String title, String location, String time) {
    ViewUtil viewUtil = ViewUtil(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: viewUtil.isTablet ?20 :12),
              ),
              const SizedBox(height: 5),
              Text(
                location,
                style: TextStyle(
                  fontSize: viewUtil.isTablet ?20 :14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(time, style: TextStyle(fontWeight: FontWeight.w600, fontSize: viewUtil.isTablet ?18 :12)),
      ],
    );
  }
}
