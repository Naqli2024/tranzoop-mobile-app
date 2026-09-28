import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/auth/model/auth_model.dart';
import 'package:bizoop_driver_app/features/auth/model/business_model.dart';
import 'package:bizoop_driver_app/features/auth/service/auth_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String errorMessage = "";
  LoginResponse? loginResponse;
  DriverResponse? driver;
  BusinessModel? business;

  Future<bool> login(LoginRequest request) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _apiService.post(
        endpoint: "login",
        body: request.toJson(),
      );
      isLoading = false;

      if (response.statusCode == 200) {
        loginResponse = LoginResponse.fromJson(jsonDecode(response.body));
        await _pref.saveUserData(
          loginResponse!.token,
          loginResponse!.driver.id,
        );
        notifyListeners();
        return true;
      } else {
        final data = LoginResponse.fromJson(jsonDecode(response.body));
        errorMessage = data.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDriverData() async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final token = await _pref.getToken();
      final driverId = await _pref.getDriverId();

      if (token == null || driverId == null) {
        errorMessage = "Driver not found";
        return;
      }

      final response = await _apiService.getDriverById(
        driverId: driverId,
        token: token,
      );

      if (response.statusCode == 200) {
        driver = DriverResponse.fromJson(
          jsonDecode(response.body),
        );
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data["message"];
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBusiness(String id) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      business = await _apiService.getBusiness(id);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}