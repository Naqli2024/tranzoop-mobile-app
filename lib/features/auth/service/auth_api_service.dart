import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';
import 'package:tranzoop_mobile_app/features/auth/model/business_model.dart';

class AuthApiService {

  static const String baseUrl = ApiUrl.authBaseUrl;
  static const String driverBaseUrl = ApiUrl.driverBaseUrl;
  static const String businessBaseUrl = ApiUrl.businessBaseUrl;

  Future<http.Response> post({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );
    return response;
  }

  Future<http.Response> getDriverById({
    required String driverId,
    required String token,
  }) async {
    return await http.get(
      Uri.parse("$driverBaseUrl$driverId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<BusinessModel> getBusiness(String businessId) async {
    final response = await http.get(
      Uri.parse("$businessBaseUrl$businessId"),
    );

    if (response.statusCode == 200) {
      return BusinessModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load business");
    }
  }
}