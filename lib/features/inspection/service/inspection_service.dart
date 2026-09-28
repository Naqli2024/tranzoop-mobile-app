import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';

class InspectionService {
  final String baseUrl = ApiUrl.inspectionBaseUrl;

  Future<http.Response> submitPreTripInspection({
    required String endpoint,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      return await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> updatePreTripInspection({
    required String endpoint,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      return await http.put(
        Uri.parse("$baseUrl$endpoint/pretrip"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> getPreTripInspectionById({
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

  Future<http.Response> getAllPreTripInspection({
    required String token,
  }) async {
    try {
      return await http.get(
        Uri.parse(baseUrl),
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

  Future<http.Response> submitPostTripInspection({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    try {
      return http.post(
        Uri.parse(
          "$baseUrl$tripId/posttripinspection",
        ),
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

  Future<http.Response> updatePostTripInspection({
    required String endpoint,
    required Map<String, dynamic> body,
    required String token,
  }) async {
    try {
      return await http.put(
        Uri.parse("$baseUrl$endpoint/post-trip"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<http.Response> getPostTripInspectionById({
    required String endpoint,
    required String token,
  }) async {
    try {
      return await http.get(
        Uri.parse("${baseUrl}posttripinspection/$endpoint"),
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

  Future<http.Response> getAllPostTripInspection({
    required String token,
    required String endpoint,
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
}