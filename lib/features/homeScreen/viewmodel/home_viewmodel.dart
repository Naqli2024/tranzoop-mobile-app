import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/current_trip_model.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/driver_model.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/service/home_api_service.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';
import 'package:tranzoop_mobile_app/features/trips/service/customer_api_service.dart';

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

  Future<void> fetchCurrentTrip() async {
    final token = await _pref.getToken();
    if (token == null) return;

    final response = await _homeService.getCurrentTrip("current-trip", token);

    if (response.statusCode == 200) {
      tripData = CurrentTripResponse.fromJson(jsonDecode(response.body));

      if (tripData?.data != null && tripData!.data!.journeyLegs.isNotEmpty) {
        final currentLegNo = tripData!.data!.currentLeg;

        final currentLeg = tripData!.data!.journeyLegs.firstWhere(
              (leg) => leg.legNo == currentLegNo,
          orElse: () => tripData!.data!.journeyLegs.first,
        );

        customer = await _customerService.getCustomer(currentLeg.customerId);
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

}