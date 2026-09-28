import 'dart:io';

class LoadingRequest {
  final DateTime loadingStartTime;
  final DateTime loadingEndTime;
  final double loadedWeight;
  final String loadedBy;

  LoadingRequest({
    required this.loadingStartTime,
    required this.loadingEndTime,
    required this.loadedWeight,
    required this.loadedBy,
  });

  Map<String, dynamic> toJson() {
    return {
      "loadingStartTime": loadingStartTime.toUtc().toIso8601String(),
      "loadingEndTime": loadingEndTime.toUtc().toIso8601String(),
      "loadedWeight": loadedWeight,
      "loadedBy": loadedBy,
    };
  }
}

class LoadingUnloadingExpenseRequest {
  final String expenseType;
  final double amount;
  final File? bill;

  LoadingUnloadingExpenseRequest({
    required this.expenseType,
    required this.amount,
    this.bill,
  });
}

class LoadingUnloadingExpenseResponse {
  final bool success;
  final String message;

  LoadingUnloadingExpenseResponse({
    required this.success,
    required this.message,
  });

  factory LoadingUnloadingExpenseResponse.fromJson(Map<String,dynamic> json){
    return LoadingUnloadingExpenseResponse(
      success: json["success"] ?? true,
      message: json["message"] ?? "",
    );
  }
}

class UnloadingRequest {
  final String unloadingBy;
  final String receiverName;
  final String receiverMobile;

  UnloadingRequest({
    required this.unloadingBy,
    required this.receiverName,
    required this.receiverMobile
  });

  Map<String, dynamic> toJson() => {
    "unloadingBy": unloadingBy,
    "receiverName": receiverName,
    "receiverMobile": receiverMobile,
  };
}