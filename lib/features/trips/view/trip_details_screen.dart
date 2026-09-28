import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripData trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final List<String> tripStages = [
    "Pre Trip Pending",
    "Reached Pickup",
    "Ready For Loading",
    "Documents Pending",
    "Ready To Start",
    "In Transit",
    "Unloading",
    "Delivery OTP Pending",
    "Completed",
    "Closed"
  ];

  int currentStageIndex() {
    return tripStages.indexWhere(
          (e) =>
      e.toLowerCase() ==
          widget.trip.tripStatus.toLowerCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    if (widget.trip.journeyLegs.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No journey leg available"),
        ),
      );
    }

    final currentLeg = widget.trip.journeyLegs.firstWhere(
          (leg) => leg.legNo == widget.trip.currentLeg,
      orElse: () => widget.trip.journeyLegs.first,
    );
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.btnColor,
                        AppColors.blackColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.btnColor.withOpacity(.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_shipping_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.trip.tripNo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          widget.trip.tripStatus,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: viewUtil.isTablet ?18 :14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.circle,
                            size: viewUtil.isTablet ?22 :14,
                            color: Colors.green,
                          ),
                          Container(
                            width: 2,
                            height: viewUtil.isTablet ?75 :65,
                            color: Colors.grey.shade300,
                          ),
                          Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: viewUtil.isTablet ?26 :22,
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pickup Location",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?20 :14,
                              ),
                            ),
                            Text(
                              currentLeg.from,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: viewUtil.isTablet ?20 :14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Delivery Location",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?20 :14,
                              ),
                            ),
                            Text(
                              currentLeg.to,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: viewUtil.isTablet ?20 :14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        Icons.inventory_2_outlined,
                        "Cargo",
                        currentLeg.commodity,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        Icons.scale,
                        "Weight",
                        "${currentLeg.weight}${currentLeg.uom}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        Icons.directions_car,
                        "Vehicle",
                        widget.trip.vehicleId?.regNo ?? "N/A",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _infoCard(
                        Icons.person,
                        "Driver",
                        currentLeg.driver1?.name ?? "N/A",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trip Progress",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: viewUtil.isTablet ? 22 : 16,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: tripStages.length,
                        itemBuilder: (_, index) {

                          return TripTrackerTile(
                            title: tripStages[index],
                            isCompleted: index < currentStageIndex(),
                            isCurrent: index == currentStageIndex(),
                            isLast: index == tripStages.length - 1,
                          );
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
            Positioned(
              top: 40,
                left: 10,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(
                    maxRadius: viewUtil.isTablet ?22 :20,
                      child: Icon(Icons.arrow_back_outlined,size: viewUtil.isTablet ?22 :20)),
                ))
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
      IconData icon,
      String title,
      String value,
      ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.btnColor, size: viewUtil.isTablet ?26 :18
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey,
              fontSize: viewUtil.isTablet ?20 :12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: viewUtil.isTablet ?20 :12,
            ),
          ),
        ],
      ),
    );
  }
}

class TripTrackerTile extends StatefulWidget {

  final String title;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  const TripTrackerTile({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  State<TripTrackerTile> createState() =>
      _TripTrackerTileState();
}

class _TripTrackerTileState
    extends State<TripTrackerTile>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isCurrent) {
      controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final double glow = widget.isCurrent
            ? 8.0 + (controller.value * 15.0)
            : 0.0;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  AnimatedContainer(
                    duration:
                    Duration(milliseconds: 300),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isCompleted
                          ? Colors.green
                          : widget.isCurrent
                          ? Colors.blue
                          : Colors.grey.shade300,
                      boxShadow: widget.isCurrent
                          ? [
                        BoxShadow(
                          color: Colors.blue
                              .withOpacity(.6),
                          blurRadius: glow,
                          spreadRadius: 1,
                        )
                      ]
                          : [],
                    ),

                    child: Icon(
                      widget.isCompleted
                          ? Icons.check
                          : widget.isCurrent
                          ? Icons.radio_button_checked
                          : Icons.circle,
                      size: widget.isCompleted
                          ? 15
                          : 10,
                      color: Colors.white,
                    ),
                  ),

                  if (!widget.isLast)
                    Container(
                      width: 2,
                      height: 35,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.isCompleted
                            ? Colors.green
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                ],
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Padding(
                  padding:const EdgeInsets.only(top: 2),
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: widget.isCurrent
                          ? FontWeight.bold
                          : FontWeight.w500,
                      fontSize: 15,
                      color: widget.isCompleted
                          ? Colors.green.shade700
                          : widget.isCurrent
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
