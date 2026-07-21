import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tranzoop_mobile_app/core/utils/api_urls.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/model/fuel_bill_model.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/model/fuel_model.dart';

class FuelService {
  Future<http.Response> getFuelBills({
    required String token,
    required String tripId,
  }) async {
   return await http.get(
      Uri.parse("${ApiUrl.tripBaseUrl}$tripId/fuel"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
  }


  Future<FuelResponse> uploadFuel({
    required String token,
    required String tripId,
    required FuelRequest request,
  }) async {
    final uri =
    Uri.parse("${ApiUrl.tripBaseUrl}$tripId/fuel");

    final multipartRequest = http.MultipartRequest("POST", uri);

    multipartRequest.headers["Authorization"] = "Bearer $token";

    multipartRequest.fields["odometer"] =
        request.odometer.toString();

    multipartRequest.fields["fuelType"] =
        request.fuelType;

    multipartRequest.fields["quantity"] =
        request.quantity.toString();

    multipartRequest.fields["rate"] =
        request.rate.toString();

    if (request.bill != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          "bill",
          request.bill!.path,
          contentType: http.MediaType("image", "jpeg"),
        ),
      );
    }

    final streamedResponse =
    await multipartRequest.send();

    final response =
    await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FuelResponse.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(jsonDecode(response.body)["message"]);
  }

  Future<FuelResponse> updateFuel({
    required String token,
    required String fuelId,
    required FuelRequest request,
  }) async {
    final uri =
    Uri.parse("${ApiUrl.tripBaseUrl}fuel/$fuelId");

    final multipartRequest = http.MultipartRequest("PUT", uri);

    multipartRequest.headers["Authorization"] =
    "Bearer $token";

    multipartRequest.fields["odometer"] =
        request.odometer.toString();

    multipartRequest.fields["fuelType"] =
        request.fuelType;

    multipartRequest.fields["quantity"] =
        request.quantity.toString();

    multipartRequest.fields["rate"] =
        request.rate.toString();

    if (request.bill != null) {
      multipartRequest.files.add(
        await http.MultipartFile.fromPath(
          "bill",
          request.bill!.path,
          contentType: http.MediaType("image", "jpeg"),
        ),
      );
    }

    final streamedResponse =
    await multipartRequest.send();

    final response =
    await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return FuelResponse.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(jsonDecode(response.body)["message"]);
  }
}