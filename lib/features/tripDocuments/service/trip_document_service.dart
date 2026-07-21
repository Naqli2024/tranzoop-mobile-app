import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';

class TripDocumentService {

  Future<http.Response> fetchDocuments({
    required String token,
    required String tripId,
  }) {
    return http.get(
      Uri.parse("${ApiUrl.tripBaseUrl}$tripId/documents"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }
}