import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/model/fuel_bill_model.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/service/fuel_api_service.dart';
import '../model/fuel_model.dart';

class FuelViewModel extends ChangeNotifier {
  final FuelService _service = FuelService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";
  FuelBillResponse? bills;


  Future<void> getFuelBills(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      final response = await _service.getFuelBills(
        token: token!,
        tripId: tripId,
      );

      if (response.statusCode == 200) {
        bills = FuelBillResponse.fromJson(
          jsonDecode(response.body),
        );
      }

      errorMessage = "";
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> uploadFuel(
      BuildContext context,
      String tripId,
      FuelRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      final response = await _service.uploadFuel(
        token: token,
        tripId: tripId,
        request: request,
      );

      successMessage = response.message;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFuel(
      BuildContext context,
      String fuelId,
      FuelRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _service.updateFuel(
        token: token,
        fuelId: fuelId,
        request: request,
      );

      successMessage = response.message;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}