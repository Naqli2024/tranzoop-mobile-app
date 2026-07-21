import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/dashboard_screen.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/view/home_screen.dart';

class TripCompletedScreen extends StatefulWidget {
  final CurrentTrip trip;
  const TripCompletedScreen({super.key, required this.trip});

  @override
  State<TripCompletedScreen> createState() =>
      _TripCompletedScreenState();
}

class _TripCompletedScreenState
    extends State<TripCompletedScreen> {
  late ConfettiController _confettiController;

  final BasicWidgets basicWidgets = BasicWidgets();

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );

    Future.delayed(
      const Duration(milliseconds: 300),
          () => _confettiController.play(),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Widget summaryTile(
      String title,
      String value,
      IconData icon,
      ) {
    ViewUtil viewUtil = ViewUtil(context);
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            maxRadius: viewUtil.isTablet ?25 :18,
            backgroundColor: AppColors.btnColor.withOpacity(.12),
            child: Icon(
              icon,
              color: AppColors.btnColor,
              size: viewUtil.isTablet ?30 :20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey,
                fontSize: viewUtil.isTablet ?20 :14
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: viewUtil.isTablet ?20 :14,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xffF7F8FC),
        body: Stack(
          children: [
            /// Left Ribbon
            Align(
              alignment: Alignment.topLeft,
              child: ConfettiWidget(
                confettiController:
                _confettiController,
                blastDirection:
                pi / 4,
                emissionFrequency:
                0.03,
                numberOfParticles:
                10,
                gravity: 0.15,
                shouldLoop: false,
              ),
            ),

            /// Right Ribbon
            Align(
              alignment: Alignment.topRight,
              child: ConfettiWidget(
                confettiController:
                _confettiController,
                blastDirection:
                3 * pi / 4,
                emissionFrequency:
                0.03,
                numberOfParticles:
                10,
                gravity: 0.15,
                shouldLoop: false,
              ),
            ),
            SafeArea(
              child: Padding(
                padding:
                const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Spacer(),
                    Container(
                      height: viewUtil.isTablet ?170 :140,
                      width: viewUtil.isTablet ?170 :140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.amber
                            .withOpacity(.12),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: viewUtil.isTablet ?120 :80,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Trip Completed!",
                      style: TextStyle(
                        fontSize: viewUtil.isTablet ?32 :22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Great job! Delivery completed successfully.",
                      textAlign:
                      TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: viewUtil.isTablet ?20 :14
                      ),
                    ),
                    const SizedBox(height: 35),
                    Container(
                      padding:
                      const EdgeInsets.all(
                          18),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius
                            .circular(
                            20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                                .05),
                            blurRadius:
                            15,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          summaryTile(
                            "Pickup",
                            "${widget.trip.origin.location},\n${widget.trip.origin.city},${widget.trip.origin.state}",
                            Icons.location_on_outlined,
                          ),
                          summaryTile(
                            "Delivery",
                            "${widget.trip.destination.location},\n${widget.trip.destination.city},${widget.trip.destination.state}",
                            Icons.location_on_outlined,
                          ),
                          summaryTile(
                            "Distance Travelled",
                            "${widget.trip.distanceTravelled} Km",
                            Icons.route,
                          ),
                          const SizedBox(height: 12),
                          summaryTile(
                            "Status",
                            widget.trip.tripStatus,
                            Icons.check_circle,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Spacer(),
                    basicWidgets.buildCommonButton(context, "Back To Dashboard", (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DashboardScreen(),
                        ),
                      );
                    })
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}