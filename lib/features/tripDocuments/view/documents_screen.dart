import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/tripDocuments/view/trip_documents_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  BasicWidgets basicWidgets = BasicWidgets();
  String selectedFilter = "Month";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrips();
    });
  }

  Future<void> _loadTrips() async {
    if (!mounted) return;
    final homeVm = context.read<HomeViewModel>();
    await homeVm.fetchDriverData();

    if (!mounted) return;
    final history = homeVm.driverData?.data.tripHistory ?? [];
    await context.read<TripViewModel>().fetchTrips(history);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    final tripVm = context.watch<TripViewModel>();
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        basicWidgets.showLogoutDialog(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: basicWidgets.buildAppBarWithRadius(
          context: context,
          title: "Trip Documents",
          showBackButton: false
        ),
        body: Column(
          children: [
            const SizedBox(height: 15),
            Expanded(
              child: tripVm.isLoading
                ? basicWidgets.loading()
                : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tripVm.trips.length,
                itemBuilder: (context, index) {
                  final trip = tripVm.trips[index];
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  trip.tripNo,
                                  style: GoogleFonts.rajdhani(
                                    fontSize: viewUtil.isTablet ?22 :18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.btnColor,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: trip.tripStatus == "Completed" ? Colors.green.shade50 :Colors.orange.shade50,
                                    border: Border.all(color: trip.tripStatus == "Completed" ? Colors.green :Colors.orange),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    trip.tripStatus,
                                    style: TextStyle(
                                      color: trip.tripStatus == "Completed" ? Colors.green :Colors.orange,
                                      fontWeight: FontWeight.w500,
                                      fontSize: viewUtil.isTablet ?18 :13
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 15),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: viewUtil.isTablet ?20 :12,
                                      color: Colors.green,
                                    ),
                                    Container(
                                      width: 2,
                                      height: viewUtil.isTablet ?50 :40,
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${trip.origin.location},${trip.origin.city},${trip.origin.state}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: viewUtil.isTablet ?20 :14
                                        ),
                                      ),
                                      SizedBox(height: viewUtil.isTablet ?40 :28),
                                      Text(
                                        "${trip.destination.location},${trip.destination.city},${trip.destination.state}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                            fontSize: viewUtil.isTablet ?20 :14
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding:
                              EdgeInsets.only(left: 12),
                              child: Divider(),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: viewUtil.isTablet ?22 :16,
                                ),
                                const SizedBox(width: 6),
                                Text(trip.commodity,style: TextStyle(fontSize: viewUtil.isTablet ?20 :14),),
                                const Spacer(),
                                Icon(
                                  Icons.scale,
                                  size: viewUtil.isTablet ?22 :16,
                                ),
                                const SizedBox(width: 6),
                                Text("${trip.weight}${trip.uom}",style: TextStyle(fontSize: viewUtil.isTablet ?20 :14)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.route,
                                  size: viewUtil.isTablet ?22 :16,
                                  color: AppColors.btnColor,
                                ),
                                const SizedBox(width: 6),
                                Text("${trip.distanceTravelled} km",style: TextStyle(fontSize: viewUtil.isTablet ?20 :14)),
                                const Spacer(),
                                ],
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                                  height: viewUtil.isTablet ?58 :48,
                                  child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.receipt_long,
                                      color: Colors.white,
                                      size: viewUtil.isTablet ?22 :18,
                                    ),
                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                      AppColors.btnColor,
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TripDocumentsScreen(trip: trip),
                                        ),
                                      );
                                    },
                                    label: Text(
                                      "View Documents",
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
                      Positioned(
                        left: -6,
                        top: 20,
                        bottom: 30,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              child: CircleAvatar(
                                backgroundColor: Colors.grey.shade300,
                                radius: 7,
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}