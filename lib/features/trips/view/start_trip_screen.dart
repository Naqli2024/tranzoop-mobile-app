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
import 'package:tranzoop_mobile_app/features/loading_unloading/view/unloading_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:tranzoop_mobile_app/features/trips/service/route_service.dart';
import 'package:tranzoop_mobile_app/features/trips/view/in_transit_screen.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class StartTripScreen extends StatefulWidget {
  final CurrentTrip trip;

  const StartTripScreen({
    super.key,
    required this.trip
  });

  @override
  State<StartTripScreen> createState() => _StartTripScreenState();
}

class _StartTripScreenState extends State<StartTripScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final TextEditingController odometerController = TextEditingController();
  final RouteService _routeService = RouteService();
  BasicWidgets basicWidgets = BasicWidgets();
  MapLibreMapController? _mapController;
  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  List<LatLng> _routePoints = [];
  bool _mapReady = false;

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
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> startTrip() async {
    final vm = context.read<TripViewModel>();
    final success = await vm.startTrip(
      widget.trip.id,
      StartTripRequest(
      startOdometer: double.parse(
        odometerController.text.trim(),
      ),
    ),);
    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InTransitScreen(trip: widget.trip),
        ),
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
    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position =
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    _currentLocation = LatLng(
      position.latitude,
      position.longitude,
    );
  }

  Future<void> _getDestinationLocation() async {
    String address =
        "${widget.trip.destination.location}, "
        "${widget.trip.destination.city}, "
        "${widget.trip.destination.state}";

    List<Location> locations =
    await locationFromAddress(address);

    if (locations.isNotEmpty) {
      _destinationLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );
    }
  }

  Future<void> _drawRoute() async {
    if (_currentLocation == null ||
        _destinationLocation == null ||
        _mapController == null) {
      return;
    }

    final result = await _routeService.getRoute(
      startLat: _currentLocation!.latitude,
      startLng: _currentLocation!.longitude,
      endLat: _destinationLocation!.latitude,
      endLng: _destinationLocation!.longitude,
    );

    if (result == null) return;

    final trip = result["trip"];

    final shape = trip["legs"][0]["shape"];

    _routePoints = _decodePolyline(shape);

    await _mapController!.clearLines();

    await _mapController!.addLine(
      LineOptions(
        geometry: _routePoints,
        lineColor: "#2962FF",
        lineWidth: 5,
      ),
    );

    await _addMarkers();

    await _fitCamera();
  }

  Future<void> _addMarkers() async {
    if (_mapController == null) return;

    await _mapController!.clearSymbols();

    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: _currentLocation!,
        iconImage: "marker-15",
        textField: "You",
      ),
    );

    await _mapController!.addSymbol(
      SymbolOptions(
        geometry: _destinationLocation!,
        iconImage: "marker-15",
        textField: "Destination",
      ),
    );
  }

  Future<void> _fitCamera() async {
    if (_mapController == null ||
        _currentLocation == null ||
        _destinationLocation == null) {
      return;
    }

    await _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            _currentLocation!.latitude <
                _destinationLocation!.latitude
                ? _currentLocation!.latitude
                : _destinationLocation!.latitude,
            _currentLocation!.longitude <
                _destinationLocation!.longitude
                ? _currentLocation!.longitude
                : _destinationLocation!.longitude,
          ),
          northeast: LatLng(
            _currentLocation!.latitude >
                _destinationLocation!.latitude
                ? _currentLocation!.latitude
                : _destinationLocation!.latitude,
            _currentLocation!.longitude >
                _destinationLocation!.longitude
                ? _currentLocation!.longitude
                : _destinationLocation!.longitude,
          ),
        ),
        left: 60,
        right: 60,
        top: 120,
        bottom: 350,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final viewUtil = ViewUtil(context);
    final vm = context.watch<AuthViewModel>();
    final cusVm = context.watch<HomeViewModel>();
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .30,
            child: Stack(
              children: [
                MapLibreMap(
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
                  onMapCreated: (controller) async {
                    _mapController = controller;
                    _mapReady = true;

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
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(30)),
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
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
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
              onSubmit: _showArrivalBottomSheet,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showArrivalBottomSheet() async {
    odometerController.clear();
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
                color: Colors.green,
                size: viewUtil.isTablet ? 45 : 34,
              ),
              const SizedBox(height: 10),
              Text(
                "Trip Start Details",
                style: TextStyle(
                  fontSize: viewUtil.isTablet ? 24 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              basicWidgets.buildTextField(
                "Enter Start Odometer Reading *",
                odometerController,
                context: context,
                isNumber: true,
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.btnColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (odometerController.text.trim().isEmpty) {
                      BasicWidgets().error(
                        context,
                        "Please enter odometer reading",
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await startTrip();
                  },
                  child: const Text(
                    "Start Trip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
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
            child: Icon(Icons.check,
                color: Colors.green, size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Ready to start your trip",
                  style: TextStyle(
                    fontSize: viewUtil.isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Everything looks good.\nYou're ready to begin your journey.",
                ),
              ],
            ),
          )
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  widget.trip.origin.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ?20 :15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${widget.trip.origin.city},${widget.trip.origin.state}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: viewUtil.isTablet ?16 :13,
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  "Delivery Location",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: viewUtil.isTablet ?18 :12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.trip.destination.location,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: viewUtil.isTablet ?20 :15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "${widget.trip.destination.city},${widget.trip.destination.state}",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: viewUtil.isTablet ?16 :13,
                  ),
                )
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

  Widget _cargoCard(ViewUtil viewUtil) {
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
          _row("Commodity", widget.trip.commodity),
          _row("Weight", "${widget.trip.weight} Ton"),
          _row("Trip No", widget.trip.tripNo),
          _row("Status", widget.trip.tripStatus),
        ],
      ),
    );
  }

  Widget _row(String title, String value) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}