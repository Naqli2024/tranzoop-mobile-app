import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';
import 'package:tranzoop_mobile_app/features/trips/model/trip_model.dart';

class LoadingUnloadingService {
  static const baseUrl = ApiUrl.tripBaseUrl;

  Future<http.Response> loading({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    return http.put(
      Uri.parse("$baseUrl$tripId/loading"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> unloading({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    return http.put(
      Uri.parse("$baseUrl$tripId/unloading"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
  }


}