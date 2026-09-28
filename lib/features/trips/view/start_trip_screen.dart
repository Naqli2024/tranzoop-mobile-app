import 'package:flutter/material.dart';
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
import 'package:bizoop_driver_app/features/trips/view/in_transit_screen.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class StartTripScreen extends StatefulWidget {
  final CurrentTrip trip;

  const StartTripScreen({super.key, required this.trip});

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final RouteService _routeService = RouteService();
  BasicWidgets basicWidgets = BasicWidgets();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> startTrip() async {
    final vm = context.read<TripViewModel>();
    final success = await vm.startTrip(
      widget.trip.id
    );
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => InTransitScreen(trip: widget.trip)),
      );
    } else {
      basicWidgets.error(context, vm.errorMessage);
    }
  }

  Future<void> _initializeMap() async {
    await _getCurrentLocation();
    await _getDestinationLocation();

    if (_mapController != null) {
      await _drawRoute();
    }

    setState(() {});
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

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    _currentLocation = LatLng(position.latitude, position.longitude);
  }

  Future<void> _getDestinationLocation() async {
    String address = widget.trip.currentJourneyLeg?.to ?? '';

    List<Location> locations = await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _destinationLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );
    }
  }

  Future<void> _drawRoute() async {
    if (_currentLocation == null || _destinationLocation == null) return;

    final result = await _routeService.getRoute(
      startLat: _currentLocation!.latitude,
      startLng: _currentLocation!.longitude,
      endLat: _destinationLocation!.latitude,
      endLng: _destinationLocation!.longitude,
    );

    if (result == null) return;
    if (!mounted) return;

    final route = (result["routes"] as List).first;
    final overviewPolyline = route["overview_polyline"]["points"];

    final points = _decodePolyline(overviewPolyline);

    _polylines = {
      Polyline(
        polylineId: const PolylineId("route"),
        points: points,
        color: Colors.blue,
        width: 5,
        geodesic: true,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };

    _markers = {
      Marker(
        markerId: const MarkerId("current"),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Current Location"),
      ),
      Marker(
        markerId: const MarkerId("destination"),
        position: _destinationLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.trip.currentJourneyLeg?.to ??''),
      ),
    };

    setState(() {});

    _fitCamera();
  }

  void _fitCamera() {
    if (_currentLocation == null ||
        _destinationLocation == null ||
        _mapController == null)
      return;

    final bounds = LatLngBounds(
      southwest: LatLng(
        math.min(_currentLocation!.latitude, _destinationLocation!.latitude),
        math.min(_currentLocation!.longitude, _destinationLocation!.longitude),
      ),
      northeast: LatLng(
        math.max(_currentLocation!.latitude, _destinationLocation!.latitude),
        math.max(_currentLocation!.longitude, _destinationLocation!.longitude),
      ),
    );

    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));
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

      lat += ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      lng += ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / precision, lng / precision));
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    final viewUtil = ViewUtil(context);
    final cusVm = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .30,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(13.0827, 80.2707),
                    zoom: 14,
                  ),
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (controller) async {
                    _mapController = controller;

                    if (_currentLocation != null &&
                        _destinationLocation != null) {
                      await _drawRoute();
                    }
                  },
                ),
                Positioned(
                  top: 25,
                  left: 15,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _tripReadyCard(viewUtil),
                    const SizedBox(height: 18),
                    _routeCard(viewUtil),
                    const SizedBox(height: 18),
                    customerCard(cusVm.customer),
                    const SizedBox(height: 18),
                    _cargoCard(viewUtil),
                    const SizedBox(height: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: viewUtil.isTablet ? 110 : 120,
        child: BottomAppBar(
          color: Colors.white,
          elevation: 10,
          child: basicWidgets.buildSlideActionButton(
            context: context,
            animation: _animation,
            text: "Start Trip",
            isTablet: viewUtil.isTablet,
            outerColor: AppColors.btnColor,
            innerColor: const Color(0xff6889da),
            onSubmit: () => startTrip(),
          ),
        ),
      ),
    );
  }


  Widget _tripReadyCard(ViewUtil viewUtil) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green),
            ),
            child: Icon(Icons.check, color: Colors.green, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ready to start your trip",
                  style: TextStyle(
                    fontSize: viewUtil.isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Everything looks good.\nYou're ready to begin your journey.",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _routeCard(ViewUtil viewUtil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.btnColor.withOpacity(.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                Icons.my_location,
                color: Colors.green,
                size: viewUtil.isTablet ? 30 : 20,
              ),
              Container(
                width: 2,
                height: viewUtil.isTablet ? 75 : 70,
                color: Colors.grey.shade300,
              ),
              Icon(
                Icons.flag,
                color: Colors.red,
                size: viewUtil.isTablet ? 30 : 20,
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Location",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: viewUtil.isTablet ? 18 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trip.currentJourneyLeg?.from ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 20 : 15,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Delivery Location",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: viewUtil.isTablet ? 18 : 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trip.currentJourneyLeg?.to ??'',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ? 20 : 15,
                  ),
                ),
              ],
            ),
          ),
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
        border: Border.all(color: AppColors.btnColor.withOpacity(.2)),
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
                      customer?.companyName ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: viewUtil.isTablet ? 22 : 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer?.contactPerson ?? '',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: viewUtil.isTablet ? 17 : 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _callCustomer(customer?.mobile.toString() ?? ''),
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
                        size: viewUtil.isTablet ? 25 : 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Call",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: viewUtil.isTablet ? 18 : 11,
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
                  customer?.billingAddress ?? '',
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

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _cargoCard(ViewUtil viewUtil) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.btnColor.withOpacity(.2)),
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
          _row("Commodity", widget.trip.currentJourneyLeg?.commodity ??''),
          _row("Weight", "${widget.trip.currentJourneyLeg?.weight}${widget.trip.currentJourneyLeg?.uom}"),
          _row("Trip No", widget.trip.tripNo),
          _row("Status", widget.trip.tripStatus),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
