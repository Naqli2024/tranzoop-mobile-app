import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/trips/model/trip_model.dart';

class TripApiService {
  static const baseUrl = ApiUrl.tripBaseUrl;

  Future<http.Response> getTripDetails({
    required String endpoint,
    required String token,
  }) async {
    try {
      return await http.get(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> reachedPickup({
    required String tripId,
    required String token,
  }) async {
    try {
      return await http.put(
        Uri.parse("$baseUrl$tripId/reached-pickup"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> startTrip({
    required String tripId,
    required String token,
  }) async {
    try {
      return await http.put(
        Uri.parse("$baseUrl$tripId/start"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> arrive({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    try {
      return http.put(
        Uri.parse("$baseUrl$tripId/arrive"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> closeTrip({
    required String tripId,
    required String token,
  }) {
    try {
      return http.put(
        Uri.parse("$baseUrl$tripId/close"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> resendOtp({required String tripId, required String token}) async {
    try {
      return http.post(
        Uri.parse("$baseUrl$tripId/resend-delivery-otp"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> verifyOtp({required String tripId, required String token, required String otp}) async {
    try {
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
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }
}