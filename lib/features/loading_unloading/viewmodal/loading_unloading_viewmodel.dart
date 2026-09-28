import 'dart:convert';
import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/loading_unloading/service/loading_unloading_service.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';

class LoadingUnloadingViewmodel extends ChangeNotifier {
  final LoadingUnloadingService _loadingUnloadingService = LoadingUnloadingService();
  final SharedPrefService _pref = SharedPrefService();

  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";
  TripDetails? trip;
  Customer? customer;

  Future<bool> loadingTrip(
      String tripId,
      LoadingRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _loadingUnloadingService.loading(
        tripId: tripId,
        token: token,
        body: request.toJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        successMessage = data["message"];
        return true;
      }

      errorMessage = data["message"];
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> unloadingTrip(
      String tripId,
      UnloadingRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _loadingUnloadingService.unloading(
        tripId: tripId,
        token: token,
        body: request.toJson(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        successMessage = data["message"];
        return true;
      }

      errorMessage = data["message"];
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadingUnloadingExpense(
      String tripId,
      LoadingUnloadingExpenseRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();
      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      final response = await _loadingUnloadingService.uploadLoadingUnloadingExpense(
        tripId: tripId, token: token, request: request,
      );
      successMessage = response.message;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print(e);
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

}