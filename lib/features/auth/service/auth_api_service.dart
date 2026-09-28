import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/auth/model/business_model.dart';

class AuthApiService {

  static const String baseUrl = ApiUrl.authBaseUrl;
  static const String driverBaseUrl = ApiUrl.driverBaseUrl;
  static const String businessBaseUrl = ApiUrl.businessBaseUrl;

  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      return response;
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> getDriverById({
    required String driverId,
    required String token,
  }) async {
    try {
      return await http.get(
        Uri.parse("$driverBaseUrl$driverId"),
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

  Future<BusinessModel> getBusiness(String businessId) async {
    try {
      final response = await http.get(
        Uri.parse("$businessBaseUrl$businessId"),
      );

      if (response.statusCode == 200) {
        return BusinessModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to load business");
      }
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }
}