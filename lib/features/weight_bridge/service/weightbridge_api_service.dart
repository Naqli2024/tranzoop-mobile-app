import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/features/weight_bridge/model/weight_bridge_model.dart';

class WeighbridgeService {

  Future<WeighbridgeResponse> uploadWeighbridge(
      String tripId,
      String token,
      WeighbridgeRequest request,
      ) async {
    try {
      final uri = Uri.parse("${ApiUrl.tripBaseUrl}${"$tripId/weighbridge"}");
      var multipartRequest = http.MultipartRequest(
        "POST",
        uri,
      );

      multipartRequest.headers.addAll({
        "Authorization": "Bearer $token",
      });

      multipartRequest.fields["grossWeight"] =
          request.grossWeight.toString();

      multipartRequest.fields["weighbridgeFee"] =
          request.weighbridgeFee.toString();

      if (request.receipt != null) {
        multipartRequest.files.add(
          await http.MultipartFile.fromPath(
            "receipt",
            request.receipt!.path,
            contentType: http.MediaType("image", "jpeg"),
          ),
        );
      }

      final streamed = await multipartRequest.send();

      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return WeighbridgeResponse.fromJson(
          jsonDecode(response.body),
        );
      }

      throw Exception(jsonDecode(response.body)["message"]);
    } on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      print(e);
      throw Exception("Something went wrong,Please try again");
    }
  }
}