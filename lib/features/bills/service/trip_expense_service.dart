import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';

class TripExpenseService {
  final String baseUrl = ApiUrl.tripBaseUrl;

  Future<http.Response> getExpenses({
    required String tripId,
    required String token,
  }) async {
    try {
      return await http.get(
        Uri.parse("$baseUrl$tripId/expenses"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }

  Future<LoadingUnloadingExpenseResponse> updateExpense({
    required String expenseId,
    required String token,
    required LoadingUnloadingExpenseRequest request,
  }) async {
    try {
      final multipartRequest = http.MultipartRequest(
        "PUT",
        Uri.parse("${baseUrl}expenses/$expenseId"),
      );

      multipartRequest.headers["Authorization"] = "Bearer $token";

      multipartRequest.fields["amount"] =
          request.amount.toString();

      if (request.bill != null) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            "bill",
            request.bill!.path,
            contentType: http.MediaType("image", "jpeg"),
          ),
        );
      }

      final streamed = await multipartRequest.send();

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return LoadingUnloadingExpenseResponse.fromJson(
          jsonDecode(response.body),
        );
      }

      throw Exception(jsonDecode(response.body)["message"]);
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

      throw Exception(jsonDecode(response.body)["message"]);
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }
}