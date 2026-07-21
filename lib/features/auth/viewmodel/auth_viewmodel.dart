import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/auth/model/auth_model.dart';
import 'package:tranzoop_mobile_app/features/auth/model/business_model.dart';
import 'package:tranzoop_mobile_app/features/auth/service/auth_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String errorMessage = "";
  SendOtpResponse? sendOtpResponse;
  VerifyOtpResponse? verifyOtpResponse;
  DriverResponse? driver;
  BusinessModel? business;

  Future<bool> sendOtp(SendOtpRequest request) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _apiService.post(
        endpoint: "send-otp",
        body: request.toJson(),
      );
      isLoading = false;

      if (response.statusCode == 200) {
        sendOtpResponse = SendOtpResponse.fromJson(jsonDecode(response.body));
        notifyListeners();
        return true;
      } else {
        final data = SendOtpResponse.fromJson(jsonDecode(response.body));
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

  Future<bool> verifyOtp(VerifyOtpRequest request) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _apiService.post(
        endpoint: "verify-otp",
        body: request.toJson(),
      );
      isLoading = false;

      if (response.statusCode == 200) {
        verifyOtpResponse = VerifyOtpResponse.fromJson(jsonDecode(response.body));
        await _pref.saveUserData(
          verifyOtpResponse!.token,
          verifyOtpResponse!.id,
        );
        notifyListeners();
        return true;
      } else {
        final data = VerifyOtpResponse.fromJson(jsonDecode(response.body));
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