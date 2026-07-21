import 'dart:convert';
import 'package:http/http.dart' as http;

class RouteService {
  static const String _url =
      "https://valhalla1.openstreetmap.de/route";

  Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final body = {
      "locations": [
        {
          "lat": startLat,
          "lon": startLng,
        },
        {
          "lat": endLat,
          "lon": endLng,
        }
      ],
      "costing": "auto",
      "directions_options": {
        "units": "kilometers"
      }
    };

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }
}