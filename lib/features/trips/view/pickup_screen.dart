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
import 'package:bizoop_driver_app/features/loading_unloading/view/loading_screen.dart';
import 'package:bizoop_driver_app/features/trips/service/route_service.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'dart:math' as math;

class PickupScreen extends StatefulWidget {
  final CurrentTrip trip;
  const PickupScreen({super.key, required this.trip, });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> with SingleTickerProviderStateMixin {
  final RouteService _routeService = RouteService();
  BasicWidgets basicWidgets = BasicWidgets();
  late Animation<double> _animation;
  late AnimationController _animationController;
  GoogleMapController? _mapController;
  bool _mapReady = false;
  Position? _currentPosition;
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  StreamSubscription<Position>? _positionStream;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  double _distance = 0;
  double _duration = 0;
  bool _cameraMoved = false;
  bool _routeLoaded = false;
  bool _isDrawingRoute = false;
  LatLng? _animatedPosition;
  BitmapDescriptor? _driverIcon;

  final googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;


  @override
  void initState() {
    super.initState();
    _loadMarker();
    _getCurrentLocation();
    _getPickupLocation();
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

  Future<void> _reachedPickup() async {
    final vm = context.read<TripViewModel>();
    final success = await vm.reachedPickup(widget.trip.id);
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommonSuccessScreen(
            title: "Reached Pickup",
            message: vm.successMessage,
            nextStep: "Proceed to Loading",
            buttonText: "Start Loading",
            showNextStep: false,
            showSummaryCard: true,
            summaryItems: [
              SummaryItem(
                label: "Pickup Location",
                value: widget.trip.currentJourneyLeg?.from ??'',
              ),
              SummaryItem(
                label: "Delivery Location",
                value: widget.trip.currentJourneyLeg?.to ??'',
              ),
              SummaryItem(
                label: "Cargo",
                value: widget.trip.currentJourneyLeg?.commodity ??'',
              ),
              SummaryItem(
                label: "Weight",
                value: '${widget.trip.currentJourneyLeg?.weight.toString() ?? ''}${widget.trip.currentJourneyLeg?.uom ?? ''}',
              ),
            ],
            nextScreen: LoadingScreen(trip: widget.trip),
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

      if (!_routeLoaded && _pickupLocation != null) {
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
    });
  }

  Future<void> _getPickupLocation() async {
    final address = widget.trip.currentJourneyLeg?.from ??'';

    final locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _pickupLocation = LatLng(
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
    if (_currentLocation == null || _pickupLocation == null) return;
    if (_isDrawingRoute) return;
    _isDrawingRoute = true;

    try {
      final result = await _routeService.getRoute(
        startLat: _currentLocation!.latitude,
        startLng: _currentLocation!.longitude,
        endLat: _pickupLocation!.latitude,
        endLng: _pickupLocation!.longitude,
      );

      if (result == null) {
        return;
      }
      if (!mounted) return;

      final route = (result["routes"] as List).first;
      final leg = (route["legs"] as List).first;
      final overviewPolyline = route["overview_polyline"]["points"];

      // distance/duration come back as {"value": <meters|seconds>, "text": ...}
      _distance = (leg["distance"]["value"] as num) / 1000; // meters -> km
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

      // Static markers: driver's starting point and the fixed pickup pin.
      _addMarkers();

      if (!_cameraMoved) {
        _cameraMoved = true;

        final bounds = LatLngBounds(
          southwest: LatLng(
            math.min(
              _currentLocation!.latitude,
              _pickupLocation!.latitude,
            ),
            math.min(
              _currentLocation!.longitude,
              _pickupLocation!.longitude,
            ),
          ),
          northeast: LatLng(
            math.max(
              _currentLocation!.latitude,
              _pickupLocation!.latitude,
            ),
            math.max(
              _currentLocation!.longitude,
              _pickupLocation!.longitude,
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
          (m) => m.markerId.value == "pickup",
    );

    if (_pickupLocation != null) {

      _markers.add(
        Marker(
          markerId: const MarkerId("pickup"),
          position: _pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(
            title: widget.trip.currentJourneyLeg?.from,
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
    BasicWidgets basicWidgets = BasicWidgets();
    final vm =  context.watch<TripViewModel>();
    final cusVm = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: vm.isLoading
      ? basicWidgets.loading()
      : Stack(
        children: [
          SizedBox(
            height: 700,
            width: double.infinity,
            child: GoogleMap(
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
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
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
                      )
                    ],
                  ),
                  child: Icon(Icons.arrow_back_outlined)
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 430,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.15),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: viewUtil.isTablet ?EdgeInsets.all(16) : EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.btnColor.withOpacity(.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.location_pin,
                          color: AppColors.btnColor,
                          size: viewUtil.isTablet ?30 :20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.trip.currentJourneyLeg?.from ??'',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: viewUtil.isTablet ?22 :16,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.btnColor,
                        size: viewUtil.isTablet ?30 :20,
                      ),
                      SizedBox(width: 10),
                      Text("${cusVm.customer?.companyName ??''} (${cusVm.customer?.contactPerson ??''})",style: TextStyle(fontSize: viewUtil.isTablet ?20 :14),),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.call_outlined,
                        color: AppColors.btnColor,
                        size: viewUtil.isTablet ?30 :20,
                      ),
                      SizedBox(width: 10),
                      Text(cusVm.customer?.mobile.toString() ??'',style: TextStyle(fontSize: viewUtil.isTablet ?20 :14)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Estimated Distance",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: viewUtil.isTablet ?20 :12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${_distance.toStringAsFixed(1)} KM",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: viewUtil.isTablet ?18 :14,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Estimated Time",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: viewUtil.isTablet ?20 :12,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "${_duration.toStringAsFixed(0)} mins",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: viewUtil.isTablet ?18 :14,
                                ),
                              )
                            ],
                          ),
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
                        "Estimated values • Tap Refresh to update",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: viewUtil.isTablet ? 16 : 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  basicWidgets.buildSlideActionButton(
                    context: context,
                    animation: _animation,
                    text: "Reached Pickup",
                    isTablet: viewUtil.isTablet,
                    outerColor: AppColors.btnColor,
                    innerColor: const Color(0xff6889da),
                    onSubmit: () => _reachedPickup(),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}