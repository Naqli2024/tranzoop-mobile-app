import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/current_trip_model.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/driver_model.dart';
import 'package:bizoop_driver_app/features/homeScreen/service/home_api_service.dart';
import 'package:bizoop_driver_app/features/homeScreen/service/location_tracking_service.dart';
import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';
import 'package:bizoop_driver_app/features/trips/service/customer_api_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeApiService _homeService = HomeApiService();
  final CustomerApiService _customerService = CustomerApiService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";
  CurrentTripResponse? tripData;
  DriverSummaryResponse? driverData;
  Customer? customer;
  bool tracking = false;

  Future<void> fetchCurrentTrip() async {
    final token = await _pref.getToken();

    if (token == null || token.isEmpty) return;

    final response = await _homeService.getCurrentTrip(
      "current-trip",
      token,
    );

    if (response.statusCode == 200) {
      tripData = CurrentTripResponse.fromJson(
        jsonDecode(response.body),
      );

      final currentTrip = tripData?.data;

      if (currentTrip?.currentJourneyLeg != null) {
        final currentLeg = currentTrip!.currentJourneyLeg!;

        customer = await _customerService.getCustomer(
          currentLeg.customerId,
        );
      }

      notifyListeners();
    }
  }

  Future<void> fetchDriverData() async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();
      final driverId = await _pref.getDriverId();

      if (token == null || driverId == null) {
        errorMessage = "Driver not found";
        return;
      }

      final response = await _homeService.getDriverDetails(
        "$driverId/dashboard",
        token,
      );
      if (response.statusCode == 200) {
        driverData = DriverSummaryResponse.fromJson(
          jsonDecode(response.body),
        );
      } else {
        errorMessage = jsonDecode(response.body)["message"];
      }
    } catch (e) {
      errorMessage = e.toString();
      return;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTracking() async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      // --------------------------------------------------
      // 1. Check whether device location/GPS is ON
      // --------------------------------------------------
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();

        errorMessage =
        "Please turn on device location to continue.";

        return false;
      }

      // --------------------------------------------------
      // 2. Request location permission
      // --------------------------------------------------
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        errorMessage =
        "Location permission is required to track your trip.";

        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();

        errorMessage =
        "Please allow location permission from app settings.";

        return false;
      }

      // --------------------------------------------------
      // 3. Notification permission
      // --------------------------------------------------
      if (Platform.isAndroid) {
        final notificationStatus =
        await Permission.notification.status;

        if (!notificationStatus.isGranted) {
          final result =
          await Permission.notification.request();

          if (!result.isGranted) {
            errorMessage =
            "Notification permission is required for tracking.";

            return false;
          }
        }
      }

      // --------------------------------------------------
      // 4. Start foreground location service
      // --------------------------------------------------
      if (!await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.startService(
          serviceId: 100,
          notificationTitle: "BIZOOP",
          notificationText: "Location tracking active",
          callback: startCallback,
        );
      }

      // --------------------------------------------------
      // 5. Send initial location
      // --------------------------------------------------
      await _sendCurrentLocation();

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _sendCurrentLocation() async {
    try {
      final driverId = await _pref.getDriverId();
      final token = await _pref.getToken();

      if (driverId == null || token == null) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("FIRST LAT : ${position.latitude}");
      print("FIRST LNG : ${position.longitude}");

      final response = await _homeService.updateDriverLocation(
        driverId: driverId,
        token: token,
        request: DriverLocationRequest(
          lat: position.latitude,
          lng: position.longitude,
        ),
      );

      print("First Location Response: $response");
    } catch (e) {
      print("First location error: $e");
    }
  }

  Future<void> stopTracking() async {
    await FlutterForegroundTask.stopService();
  }

}