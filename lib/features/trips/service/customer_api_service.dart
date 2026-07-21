import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/trips/model/customer_model.dart';

class CustomerApiService {
  Future<Customer?> getCustomer(String customerId) async {
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
      return CustomerResponse.fromJson(
        jsonDecode(response.body),
      ).data;
    }

    return null;
  }
}