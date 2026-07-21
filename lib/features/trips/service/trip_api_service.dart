import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';

class TripApiService {
  static const baseUrl = ApiUrl.tripBaseUrl;

  Future<http.Response> getTripDetails({
    required String endpoint,
    required String token,
  }) async {
    return await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> reachedPickup({
    required String tripId,
    required String token,
  }) async {
    return await http.put(
      Uri.parse("$baseUrl$tripId/reached-pickup"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> startTrip({
    required String tripId,
    required String token,
    required StartTripRequest request,
  }) async {
    return await http.put(
      Uri.parse("$baseUrl$tripId/start"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );
  }

  Future<http.Response> arrive({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    return http.put(
      Uri.parse("$baseUrl$tripId/arrive"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> closeTrip({
    required String tripId,
    required String token,
  }) {
    return http.put(
      Uri.parse("$baseUrl$tripId/close"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> resendOtp({required String tripId, required String token}) async {
    return http.post(
      Uri.parse("$baseUrl$tripId/resend-delivery-otp"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> verifyOtp({required String tripId, required String token, required String otp}) async {
    return http.post(
      Uri.parse("$baseUrl$tripId/verify-delivery-otp"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "otp": otp,
      }),
    );
  }
}