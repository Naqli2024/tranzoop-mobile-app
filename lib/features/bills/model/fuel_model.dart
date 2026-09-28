import 'dart:io';

class FuelRequest {
  final double odometer;
  final String fuelType;
  final double quantity;
  final double rate;
  final File? bill;

  FuelRequest({
    required this.odometer,
    required this.fuelType,
    required this.quantity,
    required this.rate,
    this.bill,
  });
}

class FuelResponse {
  final bool success;
  final String message;

  FuelResponse({
    required this.success,
    required this.message,
  });

  factory FuelResponse.fromJson(Map<String,dynamic> json){
    return FuelResponse(
      success: json["success"] ?? false,
      message: json["message"] ?? "",
    );
  }
}