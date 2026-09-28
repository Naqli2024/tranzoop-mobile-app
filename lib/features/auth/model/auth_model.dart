class LoginRequest {
  final String userName;
  final String password;

  LoginRequest({
    required this.userName,
    required this.password
  });

  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "password": password,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final String token;
  final Driver driver;

  LoginResponse({
    required this.success,
    required this.message,
    required this.token,
    required this.driver,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'] ?? '',
      driver: Driver.fromJson(json['driver'] ?? {}),
    );
  }
}

class Driver {
  final String id;
  final String driverId;
  final String businessId;
  final String userName;
  final String name;
  final int mobile;
  final String availableStatus;

  Driver({
    required this.id,
    required this.driverId,
    required this.businessId,
    required this.userName,
    required this.name,
    required this.mobile,
    required this.availableStatus,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['_id'] ?? '',
      driverId: json['driverId'] ?? '',
      businessId: json['businessId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? 0,
      availableStatus: json['availableStatus'] ?? '',
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
          ? DriverData.fromJson(
        Map<String, dynamic>.from(json["data"]),
      )
          : null,
    );
  }
}

class DriverData {
  final String id;
  final String businessId;
  final String userName;
  final String name;
  final int mobile;
  final int aadhaarNo;
  final int experience;

  final String dlNo;
  final String dlClass;
  final String licenseExpiryDate;

  final String availableStatus;

  final int score;

  final DriverCurrentTrip? currentTripId;

  final int totalTrips;

  final String createdAt;
  final String updatedAt;

  final String driverId;

  final DriverVehicle vehicle;

  DriverData({
    required this.id,
    required this.businessId,
    required this.userName,
    required this.name,
    required this.mobile,
    required this.aadhaarNo,
    required this.experience,
    required this.dlNo,
    required this.dlClass,
    required this.licenseExpiryDate,
    required this.availableStatus,
    required this.score,
    required this.currentTripId,
    required this.totalTrips,
    required this.createdAt,
    required this.updatedAt,
    required this.driverId,
    required this.vehicle,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      userName: json["userName"] ?? "",
      name: json["name"] ?? "",
      mobile: json["mobile"] ?? 0,
      aadhaarNo: json["aadhaarNo"] ?? 0,
      experience: json["experience"] ?? 0,
      dlNo: json["dlNo"] ?? "",
      dlClass: json["dlClass"] ?? "",
      licenseExpiryDate: json["licenseExpiryDate"] ?? "",
      availableStatus: json["availableStatus"] ?? "",
      score: json["score"] ?? 0,

      currentTripId: json["currentTripId"] != null &&
          json["currentTripId"] is Map
          ? DriverCurrentTrip.fromJson(
        Map<String, dynamic>.from(json["currentTripId"]),
      )
          : null,

      totalTrips: json["totalTrips"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      driverId: json["driverId"] ?? "",

      vehicle: json["vehicle"] != null
          ? DriverVehicle.fromJson(
        Map<String, dynamic>.from(json["vehicle"]),
      )
          : DriverVehicle(status: ""),
    );
  }
}


class DriverCurrentTrip {
  final String id;
  final String journeyType;
  final int currentLeg;
  final String tripStatus;
  final String tripNo;

  DriverCurrentTrip({
    required this.id,
    required this.journeyType,
    required this.currentLeg,
    required this.tripStatus,
    required this.tripNo,
  });

  factory DriverCurrentTrip.fromJson(Map<String, dynamic> json) {
    return DriverCurrentTrip(
      id: json["_id"] ?? "",
      journeyType: json["journeyType"] ?? "",
      currentLeg: json["currentLeg"] ?? 0,
      tripStatus: json["tripStatus"] ?? "",
      tripNo: json["tripNo"] ?? "",
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

