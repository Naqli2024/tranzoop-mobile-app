import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/CommonSuccessScreen.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/basic_widgets.dart';
import 'package:bizoop_driver_app/core/utils/view_utils.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:bizoop_driver_app/features/loading_unloading/view/unloading_screen.dart';
import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';
import 'package:bizoop_driver_app/features/trips/service/route_service.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class InTransitScreen extends StatefulWidget {
  final CurrentTrip trip;
  const InTransitScreen({super.key, required this.trip});

  @override
  State<InTransitScreen> createState() => _InTransitScreenState();
}

class _InTransitScreenState extends State<InTransitScreen>with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;
  final TextEditingController remarksController = TextEditingController();
  BasicWidgets basicWidgets = BasicWidgets();
  final RouteService _routeService = RouteService();
  bool isExpanded = false;
  GoogleMapController? _mapController;
  bool _mapReady = false;
  Position? _currentPosition;
  LatLng? _currentLocation;
  LatLng? _dropLocation;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  double _distance = 0;
  double _duration = 0;
  bool _cameraMoved = false;
  bool _isDrawingRoute = false;
  bool _routeLoaded = false;
  LatLng? _animatedPosition;
  BitmapDescriptor? _driverIcon;

  double _travelledDistanceKm = 0.0;
  LatLng? _lastTrackedLocation;

  final googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  @override
  void initState() {
    super.initState();
    _loadMarker();
    _getCurrentLocation();
    _getDropLocation();
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
    _positionStream?.cancel();
    _animationController.dispose();
    _mapReady = false;
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> completeTrip() async {
    final vm = context.read<TripViewModel>();

    // Odometer reading is derived entirely from GPS distance travelled
    // since Start Trip — no manual entry, no address-to-address estimate.
    final arrivalOdometer = _travelledDistanceKm.round();

    final success = await vm.arriveTrip(
      widget.trip.id,
      ArrivalRequest(
        arrivalOdometer: arrivalOdometer,
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

  Future<void> _loadMarker() async {
    _driverIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(60, 60)),
      "assets/images/dot_marker.png",
    );
  }

  Future<void> _animateMarker(LatLng from,LatLng to) async {
    const int steps = 30;

    for (int i = 1; i <= steps; i++) {

      final lat = from.latitude +
          (to.latitude - from.latitude) * i / steps;

      final lng = from.longitude +
          (to.longitude - from.longitude) * i / steps;

      _animatedPosition = LatLng(lat, lng);

      _markers.removeWhere(
            (m) => m.markerId.value == "driver",
      );

      _markers.add(
        Marker(
          markerId: const MarkerId("driver"),
          position: _animatedPosition!,
          icon: _driverIcon!,
          rotation: _currentPosition?.heading ?? 0,
          flat: true,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(
        const Duration(milliseconds: 20),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 20,
      ),
    ).listen((Position position) async {

      if (!mounted) return;

      _currentPosition = position;

      final newPosition = LatLng(
        position.latitude,
        position.longitude,
      );

      // Accumulate the actual distance driven using real GPS fixes only
      // (never the animated/interpolated marker position, which would
      // double count the same movement).
      if (_lastTrackedLocation != null) {
        final segmentMeters = Geolocator.distanceBetween(
          _lastTrackedLocation!.latitude,
          _lastTrackedLocation!.longitude,
          newPosition.latitude,
          newPosition.longitude,
        );
        _travelledDistanceKm += segmentMeters / 1000;
      }
      _lastTrackedLocation = newPosition;

      if (_animatedPosition == null) {

        _animatedPosition = newPosition;

        _markers.add(
          Marker(
            markerId: const MarkerId("driver"),
            position: newPosition,
            icon: _driverIcon!,
            rotation: position.heading,
            flat: true,
            anchor: const Offset(0.5, 0.5),
          ),
        );

        setState(() {});

      } else {

        await _animateMarker(
          _animatedPosition!,
          newPosition,
        );

      }

      _currentLocation = newPosition;

      if (!_routeLoaded && _dropLocation != null) {
        _routeLoaded = true;
        await _drawRoute();
      }

      if (_mapController != null && _mapReady) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _currentLocation!,
              zoom: 18,
              tilt: 60,
              bearing: position.heading,
            ),
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _getDropLocation() async {
    final address = widget.trip.currentJourneyLeg?.to ?? '';

    final locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _dropLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      if (_routePoints.isEmpty &&
          !_routeLoaded &&
          _currentLocation != null) {

        await _drawRoute();
        _routeLoaded = true;
      }
    }
  }

  Future<void> _drawRoute() async {
    if (_currentLocation == null || _dropLocation == null) return;
    if (_isDrawingRoute) return;
    _isDrawingRoute = true;

    try {
      final result = await _routeService.getRoute(
        startLat: _currentLocation!.latitude,
        startLng: _currentLocation!.longitude,
        endLat: _dropLocation!.latitude,
        endLng: _dropLocation!.longitude,
      );

      if (result == null) {
        return;
      }
      if (!mounted) return;

      final route = (result["routes"] as List).first;
      final leg = (route["legs"] as List).first;
      final overviewPolyline = route["overview_polyline"]["points"];

      // distance/duration come back as {"value": <meters|seconds>, "text": ...}
      _distance = (leg["distance"]["value"] as num) / 1000; // meters -> km (estimate only)
      _duration = (leg["duration"]["value"] as num) / 60;   // seconds -> mins

      _routePoints = _decodePolyline(overviewPolyline);

      _polylines.clear();

      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
          visible: true,
          zIndex: 1,
          geodesic: true,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        ),
      );

      // Static markers: driver's starting point and the fixed drop pin.
      _addMarkers();

      if (!_cameraMoved) {
        _cameraMoved = true;

        final bounds = LatLngBounds(
          southwest: LatLng(
            math.min(
              _currentLocation!.latitude,
              _dropLocation!.latitude,
            ),
            math.min(
              _currentLocation!.longitude,
              _dropLocation!.longitude,
            ),
          ),
          northeast: LatLng(
            math.max(
              _currentLocation!.latitude,
              _dropLocation!.latitude,
            ),
            math.max(
              _currentLocation!.longitude,
              _dropLocation!.longitude,
            ),
          ),
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            bounds,
            80,
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
    } finally {
      _isDrawingRoute = false;
    }
  }

  List<LatLng> _decodePolyline(String encoded, {double precision = 1E5}) {
    List<LatLng> poly = [];

    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      lng += dlng;

      poly.add(
        LatLng(
          lat / precision,
          lng / precision,
        ),
      );
    }

    return poly;
  }

  void _addMarkers() {
    _markers.removeWhere(
          (m) => m.markerId.value == "drop",
    );

    if (_dropLocation != null) {

      _markers.add(
        Marker(
          markerId: const MarkerId("drop"),
          position: _dropLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: widget.trip.currentJourneyLeg?.to ?? '',
          ),
        ),
      );

    }

  }

  Future<void> _refreshNavigation() async {
    if (_currentLocation == null) return;

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _currentLocation!,
          zoom: 18,
          tilt: 60,
          bearing: _currentPosition?.heading ?? 0,
        ),
      ),
    );

    await _drawRoute();
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Flexible(
            flex: isExpanded ?3 :8,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ??
                        const LatLng(13.0827, 80.2707),
                    zoom: _currentLocation == null ? 4 : 16,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (GoogleMapController controller) {
                    if (!mounted) return;

                    _mapController = controller;
                    _mapReady = true;
                    setState(() {});

                    _addMarkers();

                    if (_currentLocation != null) {
                      Future.delayed(
                        const Duration(milliseconds: 300),
                            () {
                          if (!mounted || !_mapReady) return;

                          controller.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: _currentLocation!,
                                zoom: 18,
                                bearing: _currentPosition?.heading ?? 0,
                                tilt: 60,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
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
                Positioned(
                  right: 16,
                  top: isExpanded ? 20 : null,
                  bottom: isExpanded ? null : 30,
                  child: FloatingActionButton(
                    heroTag: "refreshRoute",
                    backgroundColor: Colors.white,
                    mini: true,
                    onPressed: _refreshNavigation,
                    child: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                      size: 20,
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
    );
  }

  Future<void> _showArrivalBottomSheet() async {
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
        final vm = context.watch<TripViewModel>();
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
              const SizedBox(height: 20),
              // Odometer reading is no longer typed in — it's the GPS
              // distance driven since Start Trip, shown here read-only
              // and sent as-is to vm.arriveTrip.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.btnColor.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.btnColor.withOpacity(.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.speed, color: AppColors.btnColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Odometer Reading (auto)",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: viewUtil.isTablet ? 15 : 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${_travelledDistanceKm.toStringAsFixed(1)} KM driven since start",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: viewUtil.isTablet ? 20 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              basicWidgets.buildTextField(
                "Remarks",
                remarksController,
                context: context,
                maxLines: 3,
              ),
              const SizedBox(height: 25),
              basicWidgets.buildCommonButton(
                context,
                "Confirm Arrival",
                    () async {
                  Navigator.pop(context);
                  await completeTrip();
                },
                isLoading: vm.isLoading,
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
                              widget.trip.currentJourneyLeg?.from ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: viewUtil.isTablet ?20 :15,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              "Delivery Location",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?18 :12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.trip.currentJourneyLeg?.to ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: viewUtil.isTablet ?20 :15,
                              ),
                            ),
                            SizedBox(height: 4),
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
                          widget.trip.currentJourneyLeg?.commodity ??'',
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.scale,
                          "Weight",
                          widget.trip.currentJourneyLeg?.weight.toString() ??'',
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.route,
                          "Driven",
                          "${_travelledDistanceKm.toStringAsFixed(1)} KM",
                        ),
                      ),
                      Expanded(
                        child: _tripInfo(
                          Icons.timer_outlined,
                          "Est Time",
                          "${_duration.toStringAsFixed(0)} mins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "'Driven' updates live from GPS and is used as the odometer reading",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: viewUtil.isTablet ? 16 : 12,
                          fontStyle: FontStyle.italic,
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