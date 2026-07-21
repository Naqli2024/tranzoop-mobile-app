class TyreInspection {
  final String position;
  final double treadDepthMM;
  final bool airPressureOK;
  final bool sideWallDamage;
  final bool puncture;
  final String remarks;

  TyreInspection({
    required this.position,
    this.treadDepthMM = 0,
    this.airPressureOK = true,
    this.sideWallDamage = false,
    this.puncture = false,
    this.remarks = '',
  });

  bool get isOk => airPressureOK && !sideWallDamage && !puncture;

  TyreInspection copyWith({
    double? treadDepthMM,
    bool? airPressureOK,
    bool? sideWallDamage,
    bool? puncture,
    String? remarks,
  }) {
    return TyreInspection(
      position: position,
      treadDepthMM: treadDepthMM ?? this.treadDepthMM,
      airPressureOK: airPressureOK ?? this.airPressureOK,
      sideWallDamage: sideWallDamage ?? this.sideWallDamage,
      puncture: puncture ?? this.puncture,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "position": position,
      "treadDepthMM": treadDepthMM,
      "airPressureOK": airPressureOK,
      "sideWallDamage": sideWallDamage,
      "puncture": puncture,
      "remarks": remarks,
    };
  }

  factory TyreInspection.fromJson(Map<String, dynamic> json) {
    return TyreInspection(
      position: json["position"] ?? "",
      treadDepthMM: (json["treadDepthMM"] ?? 0).toDouble(),
      airPressureOK: json["airPressureOK"] ?? true,
      sideWallDamage: json["sideWallDamage"] ?? false,
      puncture: json["puncture"] ?? false,
      remarks: json["remarks"] ?? "",
    );
  }
}

class PreTripInspection {
  final String tripId;
  final String vehicleId;
  final String inspectedBy;
  final bool engineOil;
  final bool coolant;
  final bool brakes;
  final List<TyreInspection> tyres;
  final bool lights;
  final bool horn;
  final bool fuel;
  final bool documents;
  final bool fireExtinguisher;
  final bool firstAidKit;
  final String remarks;

  PreTripInspection({
    required this.tripId,
    required this.vehicleId,
    required this.inspectedBy,
    required this.engineOil,
    required this.coolant,
    required this.brakes,
    required this.tyres,
    required this.lights,
    required this.horn,
    required this.fuel,
    required this.documents,
    required this.fireExtinguisher,
    required this.firstAidKit,
    required this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      "tripId": tripId,
      "vehicleId": vehicleId,
      "inspectedBy": inspectedBy,
      "engineOil": engineOil,
      "coolant": coolant,
      "brakes": brakes,
      "tyres": tyres.map((t) => t.toJson()).toList(),
      "lights": lights,
      "horn": horn,
      "fuel": fuel,
      "documents": documents,
      "fireExtinguisher": fireExtinguisher,
      "firstAidKit": firstAidKit,
      "remarks": remarks,
    };
  }
}

class InspectionDetailsResponse {
  final bool success;
  final InspectionDetails data;

  InspectionDetailsResponse({
    required this.success,
    required this.data,
  });

  factory InspectionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return InspectionDetailsResponse(
      success: json["success"] ?? false,
      data: InspectionDetails.fromJson(json["data"] ?? {}),
    );
  }
}

class InspectionDetails {
  final String id;
  final String tripId;
  final String vehicleId;
  final String inspectedBy;

  final bool engineOil;
  final bool coolant;
  final bool brakes;
  final List<TyreInspection> tyres;
  final bool lights;
  final bool horn;
  final bool fuel;
  final bool documents;
  final bool fireExtinguisher;
  final bool firstAidKit;

  final String remarks;

  final int? odometer;
  final int? fuelRemaining;
  final bool? battery;
  final bool? windshield;
  final bool? bodyDamage;

  final List<String> photos;

  final String createdAt;

  InspectionDetails({
    required this.id,
    required this.tripId,
    required this.vehicleId,
    required this.inspectedBy,
    required this.engineOil,
    required this.coolant,
    required this.brakes,
    required this.tyres,
    required this.lights,
    required this.horn,
    required this.fuel,
    required this.documents,
    required this.fireExtinguisher,
    required this.firstAidKit,
    required this.remarks,
    this.odometer,
    this.fuelRemaining,
    this.battery,
    this.windshield,
    this.bodyDamage,
    required this.photos,
    required this.createdAt,
  });

  factory InspectionDetails.fromJson(Map<String, dynamic> json) {
    return InspectionDetails(
      id: json["_id"] ?? "",
      tripId: json["tripId"] ?? "",
      vehicleId: json["vehicleId"] ?? "",
      inspectedBy: json["inspectedBy"] ?? "",
      engineOil: json["engineOil"] ?? false,
      coolant: json["coolant"] ?? false,
      brakes: json["brakes"] ?? false,
      tyres: json["tyres"] is List
          ? (json["tyres"] as List)
          .map((t) => TyreInspection.fromJson(t as Map<String, dynamic>))
          .toList()
          : <TyreInspection>[],
      lights: json["lights"] ?? false,
      horn: json["horn"] ?? false,
      fuel: json["fuel"] ?? false,
      documents: json["documents"] ?? false,
      fireExtinguisher: json["fireExtinguisher"] ?? false,
      firstAidKit: json["firstAidKit"] ?? false,
      remarks: json["remarks"] ?? "",
      odometer: json["odometer"],
      fuelRemaining: json["fuelRemaining"],
      battery: json["battery"],
      windshield: json["windshield"],
      bodyDamage: json["bodyDamage"],
      photos: List<String>.from(json["photos"] ?? []),
      createdAt: json["createdAt"] ?? "",
    );
  }
}

class PostTripTyreInspection {
  final String position;
  final double treadDepthMM;
  final double treadLossMM;
  final bool airPressureOK;
  final bool sideWallDamage;
  final bool puncture;
  final bool unevenWear;
  final String condition;

  static const List<String> conditionOptions = [
    "Excellent",
    "Good",
    "Fair",
    "Poor",
  ];

  PostTripTyreInspection({
    required this.position,
    this.treadDepthMM = 0,
    this.treadLossMM = 0,
    this.airPressureOK = true,
    this.sideWallDamage = false,
    this.puncture = false,
    this.unevenWear = false,
    this.condition = "Good",
  });

  bool get isOk =>
      airPressureOK && !sideWallDamage && !puncture && !unevenWear;

  PostTripTyreInspection copyWith({
    double? treadDepthMM,
    double? treadLossMM,
    bool? airPressureOK,
    bool? sideWallDamage,
    bool? puncture,
    bool? unevenWear,
    String? condition,
  }) {
    return PostTripTyreInspection(
      position: position,
      treadDepthMM: treadDepthMM ?? this.treadDepthMM,
      treadLossMM: treadLossMM ?? this.treadLossMM,
      airPressureOK: airPressureOK ?? this.airPressureOK,
      sideWallDamage: sideWallDamage ?? this.sideWallDamage,
      puncture: puncture ?? this.puncture,
      unevenWear: unevenWear ?? this.unevenWear,
      condition: condition ?? this.condition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "position": position,
      "treadDepthMM": treadDepthMM,
      "treadLossMM": treadLossMM,
      "airPressureOK": airPressureOK,
      "sideWallDamage": sideWallDamage,
      "puncture": puncture,
      "unevenWear": unevenWear,
      "condition": condition,
    };
  }

  factory PostTripTyreInspection.fromJson(Map<String, dynamic> json) {
    return PostTripTyreInspection(
      position: json["position"] ?? "",
      treadDepthMM: (json["treadDepthMM"] ?? 0).toDouble(),
      treadLossMM: (json["treadLossMM"] ?? 0).toDouble(),
      airPressureOK: json["airPressureOK"] ?? true,
      sideWallDamage: json["sideWallDamage"] ?? false,
      puncture: json["puncture"] ?? false,
      unevenWear: json["unevenWear"] ?? false,
      condition: json["condition"] ?? "Good",
    );
  }
}

class PostTripInspectionDetailsResponse {
  final bool success;
  final PostTripInspectionDetails data;

  PostTripInspectionDetailsResponse({
    required this.success,
    required this.data,
  });

  factory PostTripInspectionDetailsResponse.fromJson(
      Map<String, dynamic> json) {
    return PostTripInspectionDetailsResponse(
      success: json["success"] ?? false,
      data: PostTripInspectionDetails.fromJson(json["data"] ?? {}),
    );
  }
}

class PostTripInspectionDetails {
  final String id;

  final TripSummary trip;
  final VehicleSummary vehicle;
  final DriverSummary inspectedBy;

  final bool engineOil;
  final bool coolant;
  final bool brakes;
  final bool battery;
  final bool lights;
  final bool horn;
  final bool windshield;
  final bool documents;
  final bool bodyDamage;

  final String inspectionStatus;

  final List<PostTripTyreInspection> tyres;
  final List<String> photos;

  final String createdAt;
  final String updatedAt;

  PostTripInspectionDetails({
    required this.id,
    required this.trip,
    required this.vehicle,
    required this.inspectedBy,
    required this.engineOil,
    required this.coolant,
    required this.brakes,
    required this.battery,
    required this.lights,
    required this.horn,
    required this.windshield,
    required this.documents,
    required this.bodyDamage,
    required this.inspectionStatus,
    required this.tyres,
    required this.photos,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostTripInspectionDetails.fromJson(
      Map<String, dynamic> json) {
    return PostTripInspectionDetails(
      id: json["_id"] ?? "",
      trip: TripSummary.fromJson(json["tripId"] ?? {}),
      vehicle: VehicleSummary.fromJson(json["vehicleId"] ?? {}),
      inspectedBy:
      DriverSummary.fromJson(json["inspectedBy"] ?? {}),

      engineOil: json["engineOil"] ?? false,
      coolant: json["coolant"] ?? false,
      brakes: json["brakes"] ?? false,
      battery: json["battery"] ?? false,
      lights: json["lights"] ?? false,
      horn: json["horn"] ?? false,
      windshield: json["windshield"] ?? false,
      documents: json["documents"] ?? false,
      bodyDamage: json["bodyDamage"] ?? false,

      inspectionStatus: json["inspectionStatus"] ?? "",

      tyres: (json["tyres"] as List? ?? [])
          .map((e) => PostTripTyreInspection.fromJson(e))
          .toList(),

      photos: List<String>.from(json["photos"] ?? []),

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
    );
  }
}

class TripSummary {
  final String id;
  final String tripNo;
  final String tripStatus;
  final String journeyType;

  TripSummary({
    required this.id,
    required this.tripNo,
    required this.tripStatus,
    required this.journeyType,
  });

  factory TripSummary.fromJson(Map<String, dynamic> json) {
    return TripSummary(
      id: json["_id"] ?? "",
      tripNo: json["tripNo"] ?? "",
      tripStatus: json["tripStatus"] ?? "",
      journeyType: json["journeyType"] ?? "",
    );
  }
}

class VehicleSummary {
  final String id;
  final String regNo;
  final String type;
  final String model;
  final String status;

  VehicleSummary({
    required this.id,
    required this.regNo,
    required this.type,
    required this.model,
    required this.status,
  });

  factory VehicleSummary.fromJson(
      Map<String, dynamic> json) {
    return VehicleSummary(
      id: json["_id"] ?? "",
      regNo: json["regNo"] ?? "",
      type: json["type"] ?? "",
      model: json["model"] ?? "",
      status: json["status"] ?? "",
    );
  }
}

class DriverSummary {
  final String id;
  final String name;
  final String driverId;
  final int mobile;

  DriverSummary({
    required this.id,
    required this.name,
    required this.driverId,
    required this.mobile,
  });

  factory DriverSummary.fromJson(
      Map<String, dynamic> json) {
    return DriverSummary(
      id: json["_id"] ?? "",
      name: json["name"] ?? "",
      driverId: json["driverId"] ?? "",
      mobile: json["mobile"] ?? 0,
    );
  }
}

class PostTripInspection {
  final String tripId;
  final String vehicleId;
  final String inspectedBy;
  final bool engineOil;
  final bool coolant;
  final bool brakes;
  final List<PostTripTyreInspection> tyres;
  final bool battery;
  final bool lights;
  final bool horn;
  final bool windshield;
  final bool documents;
  final bool bodyDamage;

  PostTripInspection({
    required this.tripId,
    required this.vehicleId,
    required this.inspectedBy,
    required this.engineOil,
    required this.coolant,
    required this.brakes,
    required this.tyres,
    required this.battery,
    required this.lights,
    required this.horn,
    required this.windshield,
    required this.documents,
    required this.bodyDamage,
  });

  Map<String, dynamic> toJson() {
    return {
      "tripId": tripId,
      "vehicleId": vehicleId,
      "inspectedBy": inspectedBy,
      "engineOil": engineOil,
      "coolant": coolant,
      "brakes": brakes,
      "tyres": tyres.map((t) => t.toJson()).toList(),
      "battery": battery,
      "lights": lights,
      "horn": horn,
      "windshield": windshield,
      "documents": documents,
      "bodyDamage": bodyDamage,
    };
  }
}