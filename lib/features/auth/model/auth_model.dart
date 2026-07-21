class SendOtpRequest {
  final String mobile;

  SendOtpRequest({
    required this.mobile
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
    };
  }
}

class SendOtpResponse {
  final String message;

  SendOtpResponse({
    required this.message,
  });

  factory SendOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendOtpResponse(
        message: json["message"] ?? ""
    );
  }
}

class VerifyOtpRequest {
  final String mobile;
  final String otp;

  VerifyOtpRequest({
    required this.mobile,
    required this.otp
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "otp": otp,
    };
  }
}

class VerifyOtpResponse {
  final String message;
  final String token;
  final String id;

  VerifyOtpResponse({
    required this.message,
    required this.token,
    required this.id,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      message: json["message"] ?? "",
      token: json["token"] ?? "",
      id: json["driver"]["_id"] ?? "",
    );
  }
}


class DriverResponse {
  final bool success;
  final DriverData? data;

  DriverResponse({
    required this.success,
    this.data,
  });

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    return DriverResponse(
      success: json["success"] ?? false,
      data: json["data"] != null
          ? DriverData.fromJson(json["data"])
          : null,
    );
  }
}

class DriverData {
  final String id;
  final String driverId;
  final String businessId;
  final String currentTripId;

  final String name;
  final int mobile;
  final int aadhaarNo;
  final int experience;

  final String dlNo;
  final String dlClass;
  final String licenseExpiryDate;

  final String availableStatus;

  final int score;
  final int totalTrips;

  final String createdAt;
  final String updatedAt;

  final DriverVehicle vehicle;

  DriverData({
    required this.id,
    required this.driverId,
    required this.businessId,
    required this.currentTripId,
    required this.name,
    required this.mobile,
    required this.aadhaarNo,
    required this.experience,
    required this.dlNo,
    required this.dlClass,
    required this.licenseExpiryDate,
    required this.availableStatus,
    required this.score,
    required this.totalTrips,
    required this.createdAt,
    required this.updatedAt,
    required this.vehicle,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json["_id"] ?? "",
      driverId: json["driverId"] ?? "",
      businessId: json["businessId"] ?? "",
      currentTripId: json["currentTripId"] ?? "",
      name: json["name"] ?? "",
      mobile: json["mobile"] ?? 0,
      aadhaarNo: json["aadhaarNo"] ?? 0,
      experience: json["experience"] ?? 0,
      dlNo: json["dlNo"] ?? "",
      dlClass: json["dlClass"] ?? "",
      licenseExpiryDate: json["licenseExpiryDate"] ?? "",
      availableStatus: json["availableStatus"] ?? "",
      score: json["score"] ?? 0,
      totalTrips: json["totalTrips"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      vehicle: DriverVehicle.fromJson(json["vehicle"] ?? {}),
    );
  }
}

class DriverVehicle {
  final String status;

  DriverVehicle({
    required this.status,
  });

  factory DriverVehicle.fromJson(Map<String, dynamic> json) {
    return DriverVehicle(
      status: json["status"] ?? "",
    );
  }
}

