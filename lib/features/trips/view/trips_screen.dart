import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';
import 'package:bizoop_driver_app/features/trips/view/trip_details_screen.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  BasicWidgets basicWidgets = BasicWidgets();
  String currentFilter = 'All';
  final FocusNode searchFocusNode = FocusNode();
  final TextEditingController searchController = TextEditingController();
  late List<TripData> filteredTrips;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      if (mounted) setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;

    setState(() {
      _initialLoading = true;
    });

    try {
      final homeVm = context.read<HomeViewModel>();
      final tripVm = context.read<TripViewModel>();

      await homeVm.fetchDriverData();

      if (!mounted) return;

      final history = homeVm.driverData?.data.tripHistory ?? [];

      await tripVm.fetchTrips(history);
    } finally {
      if (mounted) {
        setState(() {
          _initialLoading = false;
        });
      }
    }
  }

  List<TripData> getFilteredTrips(List<TripData> allTrips) {
    List<TripData> trips;

    switch (currentFilter) {
      case "Ongoing":
        trips = allTrips.where((e) {
          final status = e.tripStatus.toLowerCase();
          return status == "in progress" ||
              status == "ongoing" ||
              status == "assigned";
        }).toList();
        break;

      case "Completed":
        trips = allTrips.where((e) {
          return e.tripStatus.toLowerCase() == "completed";
        }).toList();
        break;

      default:
        trips = List.from(allTrips);
    }

    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return trips;
    }

    return trips.where((trip) {
      if (trip.journeyLegs.isEmpty) {
        return trip.tripNo.toLowerCase().contains(query) ||
            trip.tripStatus.toLowerCase().contains(query);
      }

      final currentLeg = trip.journeyLegs.firstWhere(
            (leg) => leg.legNo == trip.currentLeg,
        orElse: () => trip.journeyLegs.first,
      );

      return trip.tripNo.toLowerCase().contains(query) ||
          currentLeg.from.toLowerCase().contains(query) ||
          currentLeg.to.toLowerCase().contains(query) ||
          currentLeg.commodity.toLowerCase().contains(query) ||
          trip.tripStatus.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final tripVm = context.watch<TripViewModel>();

    final allTrips = tripVm.trips;
    final filteredTrips = getFilteredTrips(allTrips);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        basicWidgets.showLogoutDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: basicWidgets.buildAppBarWithRadius(
          context: context,
          title: "Trips",
          showBackButton: false
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(viewUtil.isTablet ?40 :30),
                  ),
                  height: MediaQuery.of(context).size.height * 0.055,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              currentFilter = 'All';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentFilter == 'All'
                                  ? AppColors.btnColor
                                  : null,
                              borderRadius: BorderRadius.circular(viewUtil.isTablet ?40 :30),
                            ),
                            child: Center(
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color: currentFilter == 'All'
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: viewUtil.isTablet ? 22 :14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              currentFilter = 'Ongoing';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentFilter == 'Ongoing'
                                  ? AppColors.btnColor
                                  : null,
                              borderRadius: BorderRadius.circular(viewUtil.isTablet ?40 :30),
                            ),
                            child: Center(
                              child: Text(
                                'Ongoing',
                                style: TextStyle(
                                  color: currentFilter == 'Ongoing'
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: viewUtil.isTablet ? 22 :14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              FocusScope.of(context).unfocus();
                              currentFilter = 'Completed';
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: currentFilter == 'Completed'
                                  ? AppColors.btnColor
                                  : null,
                              borderRadius: BorderRadius.circular(viewUtil.isTablet ?40 :30),
                            ),
                            child: Center(
                              child: Text(
                                'Completed',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: currentFilter == 'Completed'
                                      ? Colors.white
                                      : Colors.black,
                                  fontSize: viewUtil.isTablet ? 22 : 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  keyboardType: TextInputType.text,
                  style: TextStyle(
                    fontSize: viewUtil.isTablet ? 22 : 14,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: viewUtil.isTablet ?18 :0,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(viewUtil.isTablet ? 35 :30),
                      borderSide: const BorderSide(color: Color(0xffE5E9F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xffE5E9F0)),
                    ),
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      fontSize: viewUtil.isTablet ? 22 : 14,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: viewUtil.isTablet ?15 :0,horizontal: viewUtil.isTablet ?15 :0),
                      child: Icon(Icons.search, size: viewUtil.isTablet ?30 :18),
                    ),
                    suffixIcon: Visibility(
                      visible: searchController.text.isNotEmpty,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            FocusScope.of(context).unfocus();
                            searchController.clear();
                          });
                        },
                        icon: Icon(Icons.cancel_outlined, size: viewUtil.isTablet ?30 :20,color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _initialLoading || tripVm.isLoading
                    ? basicWidgets.loading()
                    : filteredTrips.isEmpty
                    ? _buildEmptyState()
                    : _buildTrips(filteredTrips),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;

    if (searchController.text.isNotEmpty) {
      title = "No trips found";
      subtitle = "Try searching with another keyword.";
    } else {
      switch (currentFilter) {
        case "Ongoing":
          title = "No ongoing trips";
          subtitle = "You don't have any ongoing trips.";
          break;

        case "Completed":
          title = "No completed trips";
          subtitle = "Completed trips will appear here.";
          break;

        default:
          title = "No trips found";
          subtitle = "No trips are available.";
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrips(List<TripData> trips) {
    ViewUtil viewUtil = ViewUtil(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];

        if (trip.journeyLegs.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentLeg = trip.journeyLegs.firstWhere(
              (leg) => leg.legNo == trip.currentLeg,
          orElse: () => trip.journeyLegs.first,
        );
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: EdgeInsets.symmetric(vertical: viewUtil.isTablet ?16 :5),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: trip.tripStatus == "In Transit"? Colors.orange: Colors.green,width: 3)),
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: viewUtil.isTablet
                    ? EdgeInsets.fromLTRB(16, 10, 16, 5)
                    : EdgeInsets.fromLTRB(16, 10, 16, 5),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.btnColor,
                      size: viewUtil.isTablet ?26 :20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        trip.tripNo,
                        style: GoogleFonts.rajdhani(
                          fontSize: viewUtil.isTablet ?24 :18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.btnColor,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: trip.tripStatus == "Completed"
                            ? Colors.green.withOpacity(.15)
                            : Colors.orange.withOpacity(.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: trip.tripStatus == "Completed"
                            ? Colors.green
                            : Colors.orange)
                      ),
                      child: Text(
                        trip.tripStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: viewUtil.isTablet ?16 :10,
                          color: trip.tripStatus == "Completed"
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.circle,
                              size: viewUtil.isTablet ?18 :12,
                              color: Colors.green,
                            ),
                            Container(
                              width: 2,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Icon(
                              Icons.location_on,
                              size: viewUtil.isTablet ?26 :18,
                              color: Colors.red,
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentLeg.from,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: viewUtil.isTablet ?22 :14,
                                ),
                              ),
                              SizedBox(height: viewUtil.isTablet ?24 :28),
                              Text(
                                currentLeg.to,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: viewUtil.isTablet ?22 :14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _infoTile(
                            Icons.inventory_2_outlined,
                            "Cargo",
                            currentLeg.commodity,
                          ),
                        ),
                        Expanded(
                          child: _infoTile(
                            Icons.scale,
                            "Weight",
                            "${currentLeg.weight}${currentLeg.uom}",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                        width: double.infinity,
                        height: viewUtil.isTablet ?58 :48,
                        child: ElevatedButton.icon(
                          icon: Icon(
                            Icons.visibility,
                            color: Colors.white,
                            size: viewUtil.isTablet ?22 :18,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TripDetailsScreen(trip: trip),
                              ),
                            );
                          },
                          label: Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: viewUtil.isTablet ?20 :14
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _infoTile(
      IconData icon,
      String title,
      String value,
      ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Row(
      children: [
        Icon(icon, size: viewUtil.isTablet ?26 :18),
        SizedBox(width: viewUtil.isTablet ?12 :6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: viewUtil.isTablet ?20 :12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: viewUtil.isTablet ?18 :12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}