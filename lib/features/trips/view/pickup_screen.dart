import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/CommonSuccessScreen.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/basic_widgets.dart';
import 'package:tranzoop_mobile_app/core/utils/view_utils.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/view/loading_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/service/route_service.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';

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
  MapLibreMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _pickupLocation;
  List<LatLng> _routePoints = [];
  double _distance = 0;
  double _duration = 0;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  bool _cameraMoved = false;
  Circle? _driverMarker;
  Circle? _pickupMarker;


  @override
  void initState() {
    super.initState();
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
                value: widget.trip.origin.location,
              ),
              SummaryItem(
                label: "Delivery Location",
                value: widget.trip.destination.location,
              ),
              SummaryItem(
                label: "Cargo",
                value: widget.trip.commodity,
              ),
              SummaryItem(
                label: "Weight",
                value: widget.trip.weight.toString(),
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

      _currentPosition = position;

      _currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      print("Current Location");
      print(position.latitude);
      print(position.longitude);

      setState(() {});

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
      _drawRoute();
    });
  }

  Future<void> _getPickupLocation() async {
    String address =
        "${widget.trip.origin.location}, ${widget.trip.origin.city}, ${widget.trip.origin.state}";

    List<Location> locations =
    await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _pickupLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      setState(() {});
    }
    _drawRoute();
  }

  Future<void> _drawRoute() async {
    if (_currentLocation == null || _pickupLocation == null) return;

    final result = await _routeService.getRoute(
      startLat: _currentLocation!.latitude,
      startLng: _currentLocation!.longitude,
      endLat: _pickupLocation!.latitude,
      endLng: _pickupLocation!.longitude,
    );

    if (result == null) return;

    final trip = result["trip"];

    final shape = trip["legs"][0]["shape"];

    final summary = trip["summary"];

    _distance = summary["length"].toDouble();

    _duration = summary["time"] / 60;

    final decoded = _decodePolyline(shape);

    _routePoints = decoded;

    await _mapController?.clearLines();

    await _mapController?.addLine(
      LineOptions(
        geometry: decoded,
        lineColor: "#2962FF",
        lineWidth: 5,
      ),
    );

    await _addMarkers();
    if (!_cameraMoved) {
      _cameraMoved = true;
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _currentLocation!.latitude < _pickupLocation!.latitude
                  ? _currentLocation!.latitude
                  : _pickupLocation!.latitude,
              _currentLocation!.longitude < _pickupLocation!.longitude
                  ? _currentLocation!.longitude
                  : _pickupLocation!.longitude,
            ),
            northeast: LatLng(
              _currentLocation!.latitude > _pickupLocation!.latitude
                  ? _currentLocation!.latitude
                  : _pickupLocation!.latitude,
              _currentLocation!.longitude > _pickupLocation!.longitude
                  ? _currentLocation!.longitude
                  : _pickupLocation!.longitude,
            ),
          ),
          left: 60,
          top: 120,
          right: 60,
          bottom: 350,
        ),
      );
    }

    setState(() {});
  }

  List<LatLng> _decodePolyline(String encoded) {
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
          lat / 1E6,
          lng / 1E6,
        ),
      );
    }

    return poly;
  }

  Future<void> _addMarkers() async {
    if (_mapController == null) return;

    if (_currentLocation != null) {
      if (_driverMarker == null) {
        _driverMarker = await _mapController!.addCircle(
          CircleOptions(
            geometry: _currentLocation!,
            circleRadius: 8,
            circleColor: "#2962FF",
            circleStrokeWidth: 2,
            circleStrokeColor: "#FFFFFF",
          ),
        );
      } else {
        await _mapController!.updateCircle(
          _driverMarker!,
          CircleOptions(
            geometry: _currentLocation!,
          ),
        );
      }
    }

    if (_pickupLocation != null) {
      if (_pickupMarker == null) {
        _pickupMarker = await _mapController!.addCircle(
          CircleOptions(
            geometry: _pickupLocation!,
            circleRadius: 8,
            circleColor: "#FF0000",
            circleStrokeWidth: 2,
            circleStrokeColor: "#FFFFFF",
          ),
        );
      } else {
        await _mapController!.updateCircle(
          _pickupMarker!,
          CircleOptions(
            geometry: _pickupLocation!,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ViewUtil viewUtil = ViewUtil(context);
    BasicWidgets basicWidgets = BasicWidgets();
    final vm = context.watch<AuthViewModel>();
    final cusVm = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          Positioned.fill(
            child: MapLibreMap(
              styleString: "https://tiles.openfreemap.org/styles/liberty",
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(13.0827, 80.2707),
                zoom: _currentLocation == null ? 4 : 16,
              ),
              myLocationEnabled: true,
              myLocationTrackingMode: MyLocationTrackingMode.tracking,
              compassEnabled: true,
              rotateGesturesEnabled: true,
              zoomGesturesEnabled: true,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _addMarkers();
                  if (_currentLocation != null) {
                    _mapController?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _currentLocation!,
                          zoom: 16,
                          tilt: 50,
                          bearing: _currentPosition?.heading ?? 0,
                        ),
                      ),
                    );
                  }
                }
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
                              widget.trip.origin.location,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: viewUtil.isTablet ?22 :16,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${widget.trip.origin.city},${widget.trip.origin.state}",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: viewUtil.isTablet ?16 :13,
                              ),
                            )
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
                                "Distance",
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
                                "ETA",
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
