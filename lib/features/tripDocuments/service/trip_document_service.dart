import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';

class TripDocumentService {

  Future<http.Response> fetchDocuments({
    required String token,
    required String tripId,
  }) {
    try {
      return http.get(
        Uri.parse("${ApiUrl.tripBaseUrl}$tripId/documents"),
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