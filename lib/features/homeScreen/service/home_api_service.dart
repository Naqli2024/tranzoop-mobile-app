import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';

class HomeApiService {
  static const String baseUrl = ApiUrl.driverBaseUrl;

  Future<http.Response> getCurrentTrip( String endpoint,String token) async {
    return await http.get(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }

  Future<http.Response> getDriverDetails( String endpoint,String token) async {
    return await http.get(
      Uri.parse(baseUrl +endpoint),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
}