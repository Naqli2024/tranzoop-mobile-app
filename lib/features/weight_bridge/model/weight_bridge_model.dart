import 'dart:io';

class WeighbridgeRequest {
  final double grossWeight;
  final double weighbridgeFee;
  final String uom;
  final File receipt;

  WeighbridgeRequest({
    required this.grossWeight,
    required this.weighbridgeFee,
    required this.uom,
    required this.receipt,
  });
}

class WeighbridgeResponse {
  final bool success;
  final String message;

  WeighbridgeResponse({
    required this.success,
    required this.message,
  });

  factory WeighbridgeResponse.fromJson(Map<String,dynamic> json){
    return WeighbridgeResponse(
      success: json["success"] ?? true,
      message: json["message"] ?? "",
    );
  }
}