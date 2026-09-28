import 'dart:convert';
import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';
import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/driver_model.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';
import 'package:bizoop_driver_app/features/trips/service/trip_api_service.dart';

class TripViewModel extends ChangeNotifier {
  final TripApiService _service = TripApiService();
  final SharedPrefService _pref = SharedPrefService();

  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";
  TripDetails? trip;
  List<TripData> trips = [];
  Customer? customer;

  Future<void> fetchTrip(String tripId) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null || token.isEmpty) {
        errorMessage = "Token not found";
        return;
      }

      final response = await _service.getTripDetails(
        endpoint: tripId,
        token: token,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        trip = TripDetails.fromJson(data);

        final tripData = trip?.data;

        if (tripData != null && tripData.journeyLegs.isNotEmpty) {
          final currentLegNo = tripData.currentLeg;

          final currentLeg = tripData.journeyLegs.firstWhere(
                (leg) => leg.legNo == currentLegNo,
            orElse: () => tripData.journeyLegs.first,
          );

          // customerId is already a populated Customer object
          customer = currentLeg.customerId;
        } else {
          customer = null;
        }
      } else {
        errorMessage = data["message"] ?? "Unable to fetch trip";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startTrip(
      String tripId
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _service.startTrip(
        tripId: tripId,
        token: token,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        successMessage = data["message"];
        return true;
      } else {
        errorMessage = data["message"];
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> reachedPickup(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _service.reachedPickup(
        tripId: tripId,
        token: token,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        successMessage = data["message"];
        return true;
      } else {
        errorMessage = data["message"];
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> arriveTrip(
      String tripId,
      ArrivalRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      final response = await _service.arrive(
        tripId: tripId,
        token: token!,
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

  Future<bool> closeTrip(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      final response = await _service.closeTrip(
        tripId: tripId,
        token: token!,
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

  Future<bool> resendOtp(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      final response = await _service.resendOtp(
        tripId: tripId,
        token: token!,
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

  Future<bool> verifyOtp(String tripId, String otp) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      final response = await _service.verifyOtp(
        tripId: tripId,
        token: token!,
        otp: otp
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

  Future<void> fetchTrips(List<TripHistory> history) async {
    try {
      isLoading = true;
      trips.clear();
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) return;

      for (final item in history) {
        final response = await _service.getTripDetails(
          endpoint: item.tripId,
          token: token,
        );

        if (response.statusCode == 200) {
          final trip = TripDetails.fromJson(
            jsonDecode(response.body),
          );

          if (trip.data != null) {
            trips.add(trip.data!);
          }
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}