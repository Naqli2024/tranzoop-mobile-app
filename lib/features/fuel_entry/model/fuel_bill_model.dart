class FuelBill {
  final String id;
  final String businessId;
  final String tripId;
  final int legNo;
  final String driverId;
  final double odometer;
  final String fuelStation;
  final String location;
  final String fuelType;
  final double quantity;
  final double rate;
  final double amount;
  final String paymentMode;
  final String billNo;
  final String billPath;
  final String remarks;
  final String billUrl;
  final DateTime createdAt;

  FuelBill({
    required this.id,
    required this.businessId,
    required this.tripId,
    required this.legNo,
    required this.driverId,
    required this.odometer,
    required this.fuelStation,
    required this.location,
    required this.fuelType,
    required this.quantity,
    required this.rate,
    required this.amount,
    required this.paymentMode,
    required this.billNo,
    required this.billPath,
    required this.remarks,
    required this.billUrl,
    required this.createdAt,
  });

  factory FuelBill.fromJson(Map<String, dynamic> json) {
    return FuelBill(
      id: json["_id"],
      businessId: json["businessId"],
      tripId: json["tripId"],
      legNo: json["legNo"],
      driverId: json["driverId"],
      odometer: (json["odometer"] ?? 0).toDouble(),
      fuelStation: json["fuelStation"] ?? "",
      location: json["location"] ?? "",
      fuelType: json["fuelType"] ?? "",
      quantity: (json["quantity"] ?? 0).toDouble(),
      rate: (json["rate"] ?? 0).toDouble(),
      amount: (json["amount"] ?? 0).toDouble(),
      paymentMode: json["paymentMode"] ?? "",
      billNo: json["billNo"] ?? "",
      billPath: json["billPath"] ?? "",
      remarks: json["remarks"] ?? "",
      billUrl: json["billUrl"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}

class FuelBillResponse {
  final bool success;
  final int count;
  final List<FuelBill> data;

  FuelBillResponse({
    required this.success,
    required this.count,
    required this.data,
  });

  factory FuelBillResponse.fromJson(Map<String, dynamic> json) {
    return FuelBillResponse(
      success: json["success"],
      count: json["count"],
      data: (json["data"] as List)
          .map((e) => FuelBill.fromJson(e))
          .toList(),
    );
  }
}