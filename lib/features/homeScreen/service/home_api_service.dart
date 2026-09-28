import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/homeScreen/model/driver_model.dart';

class HomeApiService {
  static const String baseUrl = ApiUrl.driverBaseUrl;

  Future<http.Response> getCurrentTrip( String endpoint,String token) async {
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

  Future<http.Response> getDriverDetails( String endpoint,String token) async {
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

  Future<http.Response> updateDriverLocation({
    required String driverId,
    required String token,
    required DriverLocationRequest request,
  }) async {
    try {
      return await http.patch(
        Uri.parse(
          "$baseUrl$driverId/location",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode(request.toJson()),
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }
}