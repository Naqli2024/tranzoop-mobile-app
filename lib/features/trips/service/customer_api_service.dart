import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';

class CustomerApiService {
  Future<Customer?> getCustomer(String customerId) async {
    try {
      final token = await SharedPrefService().getToken();
      final response = await http.get(
        Uri.parse(
          "${ApiUrl.customerBaseUrl}$customerId",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return CustomerResponse
            .fromJson(
          jsonDecode(response.body),
        )
            .data;
      }
      return null;
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    }
  }
}