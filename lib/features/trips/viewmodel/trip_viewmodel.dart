import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/model/driver_model.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/service/home_api_service.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/model/loading_unloading_model.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';
import 'package:tranzoop_mobile_app/features/trips/service/customer_api_service.dart';
import 'package:tranzoop_mobile_app/features/trips/service/trip_api_service.dart';

class TripViewModel extends ChangeNotifier {
  final TripApiService _service = TripApiService();
  final CustomerApiService _customerService = CustomerApiService();
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
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return;
      }

      final response = await _service.getTripDetails(
        endpoint: tripId,
        token: token,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        trip = TripDetails.fromJson(jsonDecode(response.body));
        if (trip?.data != null && trip!.data.journeyLegs.isNotEmpty) {
          final currentLegNo = trip!.data.currentLeg;

          final currentLeg = trip!.data.journeyLegs.firstWhere((leg) => leg.legNo == currentLegNo,
            orElse: () => trip!.data.journeyLegs.first,
          );

          customer = await _customerService.getCustomer(currentLeg.customerId);
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
      String tripId,
      StartTripRequest request,
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
        request: request,
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

          trips.add(trip.data);
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