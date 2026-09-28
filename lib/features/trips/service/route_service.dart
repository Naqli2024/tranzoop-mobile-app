import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RouteService {
  static const String _url =
      "https://maps.googleapis.com/maps/api/directions/json";

  Future<Map<String, dynamic>?> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

    final uri = Uri.parse(_url).replace(queryParameters: {
      "origin": "$startLat,$startLng",
      "destination": "$endLat,$endLng",
      "mode": "driving",
      "key": apiKey,
    });

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data["status"] == "OK" &&
          (data["routes"] as List).isNotEmpty) {
        return data;
      }

      return null;
    }
    return null;
  }
}