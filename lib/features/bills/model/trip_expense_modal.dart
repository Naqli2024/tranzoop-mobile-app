import 'dart:io';

class TripExpenseResponse {
  final bool success;
  final List<TripExpense> data;

  TripExpenseResponse({
    required this.success,
    required this.data,
  });

  factory TripExpenseResponse.fromJson(Map<String, dynamic> json) {
    return TripExpenseResponse(
      success: json["success"] ?? false,
      data: (json["data"] as List)
          .map((e) => TripExpense.fromJson(e))
          .toList(),
    );
  }
}

class TripExpenseDriver {
  final String id;
  final String name;
  final String mobile;
  final String driverId;

  TripExpenseDriver({
    required this.id,
    required this.name,
    required this.mobile,
    required this.driverId,
  });

  factory TripExpenseDriver.fromJson(Map<String, dynamic> json) {
    return TripExpenseDriver(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      // mobile comes back as a number (9876543210), not a string
      mobile: json["mobile"]?.toString() ?? "",
      driverId: json["driverId"] ?? "",
    );
  }
}

class TripExpense {
  final String id;
  final String businessId;
  final String tripId;
  final int legNo;
  final TripExpenseDriver? driver;
  final String expenseType;
  final double amount;
  final String filePath;
  final String billUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  TripExpense({
    required this.id,
    required this.businessId,
    required this.tripId,
    required this.legNo,
    required this.driver,
    required this.expenseType,
    required this.amount,
    required this.filePath,
    required this.billUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripExpense.fromJson(Map<String, dynamic> json) {
    return TripExpense(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      tripId: json["tripId"] ?? "",
      legNo: json["legNo"] ?? 0,
      driver: json["driverId"] is Map<String, dynamic>
          ? TripExpenseDriver.fromJson(json["driverId"])
          : null,
      expenseType: json["expenseType"] ?? "",
      amount: (json["amount"] ?? 0).toDouble(),
      filePath: json["filePath"] ?? "",
      billUrl: json["billUrl"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class UpdateTripExpenseRequest {
  final double amount;
  final File? bill;

  UpdateTripExpenseRequest({
    required this.amount,
    this.bill,
  });
}