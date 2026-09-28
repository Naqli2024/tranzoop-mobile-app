import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:bizoop_driver_app/features/inspection/view/pre_trip_inspection.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';

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
    final homeVm = context.watch<HomeViewModel>();
    return Scaffold(
      appBar: basicWidgets.buildCommonAppBar(
        context: context,
        title: "New Trip Assigned",
      ),
      body: vm.isLoading
          ? basicWidgets.loading()
          : _buildTripDetails(widget.trip, vm.trip?.data, vm.customer),
    );
  }

  Widget _buildTripDetails(CurrentTrip trip, TripData? vm, Customer? customer) {
    ViewUtil viewUtil = ViewUtil(context);
    final homeVm = context.watch<HomeViewModel>();
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
              viewUtil.isTablet ? 20 : 13,
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
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRow("Trip ID", trip.tripNo, isHeader: true),
                  const Divider(),
                  _buildRow("Vehicle No", vm?.vehicleId?.regNo ?? ''),
                  const Divider(),
                  _buildRow(
                    "Vehicle Name",
                    "${vm?.vehicleId?.make ?? ""} (${vm?.vehicleId?.model ?? ''})",
                  ),
                  const Divider(),
                  _buildRow("Pickup", trip.currentJourneyLeg?.from ??''),
                  const Divider(),
                  _buildRow("Delivery", trip.currentJourneyLeg?.to ??''),
                  const Divider(),
                  _buildRow("Cargo", trip.currentJourneyLeg?.commodity ??''),
                  const Divider(),
                  _buildRow("Weight", "${trip.currentJourneyLeg?.weight ??''} ${trip.currentJourneyLeg?.uom ??''}"),
                  const Divider(),
                  _buildLocationRow(
                    "Customer Details",
                    "${customer?.companyName ?? "N/A"} (${customer?.contactPerson ?? "N/A"})",
                    customer?.mobile.toString() ?? "",
                  ),
                  SizedBox(height: 5),
                  _buildRow('Address', customer?.billingAddress ?? "N/A"),
                ],
              ),
            ),
          ),
          const Spacer(),
          basicWidgets.buildCommonButton(
            context,
            'Accept Order',
            () async {
              final success = await homeVm.startTracking();

              if (!mounted) return;

              if (!success) {
                basicWidgets.error(
                  context,
                  homeVm.errorMessage,
                );
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PreTripInspectionScreen(
                    trip: widget.trip,
                  ),
                ),
              );
            },
            isLoading: homeVm.isLoading,
          ),
          SizedBox(height: 20),
        ],
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
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: viewUtil.isTablet ? 20 : 12,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: isHeader
                ? viewUtil.isTablet
                      ? 18
                      : 16
                : viewUtil.isTablet
                ? 20
                : 14,
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
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: viewUtil.isTablet ? 20 : 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                location,
                style: TextStyle(
                  fontSize: viewUtil.isTablet ? 20 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: viewUtil.isTablet ? 18 : 12,
          ),
        ),
      ],
    );
  }
}
