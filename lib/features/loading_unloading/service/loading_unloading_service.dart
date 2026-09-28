import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';

class LoadingUnloadingService {
  static const baseUrl = ApiUrl.tripBaseUrl;

  Future<http.Response> loading({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    try {
      return http.put(
        Uri.parse("$baseUrl$tripId/loading"),
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

  Future<http.Response> unloading({
    required String tripId,
    required String token,
    required Map<String, dynamic> body,
  }) {
    try {
      return http.put(
        Uri.parse("$baseUrl$tripId/unloading"),
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

  Future<LoadingUnloadingExpenseResponse> uploadLoadingUnloadingExpense({
    required String tripId,
    required String token,
    required LoadingUnloadingExpenseRequest request,
  }) async {
    try {
      var uri = Uri.parse("$baseUrl$tripId/expenses");

      var multipartRequest = http.MultipartRequest(
        "POST",
        uri,
      );

      multipartRequest.headers.addAll({
        "Authorization": "Bearer $token",
      });

      multipartRequest.fields["expenseType"] = request.expenseType;
      multipartRequest.fields["amount"] = request.amount.toString();

      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          "bill",
          request.bill!.path,
          contentType: http.MediaType("image", "jpeg"),
        ),
      );

      final streamed = await multipartRequest.send();

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoadingUnloadingExpenseResponse.fromJson(
          jsonDecode(response.body),
        );
      }

      // Get backend error message
      String message = "Something went wrong";

      try {
        final data = jsonDecode(response.body);

        if (data["message"] != null) {
          message = data["message"].toString();
        }
      } catch (_) {
        message = response.body;
      }

      throw Exception(message);
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      print("Loading/Unloading API Error: $e");

      // IMPORTANT: preserve the original exception
      rethrow;
    }
  }
}