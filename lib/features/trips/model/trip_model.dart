class TripDetails {
  final bool success;
  final TripData data;

  TripDetails({
    required this.success,
    required this.data,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      success: json['success'] ?? false,
      data: TripData.fromJson(json['data'] ?? {}),
    );
  }
}

class TripData {
  final String id;
  final String businessId;
  final String fleetSource;
  final String journeyType;
  final String vehicleCategory;
  final String commodity;
  final int weight;
  final String uom;
  final int freightAmount;
  final int advanceAmount;
  final String loadType;
  final String paymentType;

  final Origin origin;
  final Destination destination;
  final Loading loading;
  final Unloading unloading;

  final Vehicle vehicle;
  final Driver driver1;
  final Driver? driver2;

  final List<JourneyLeg> journeyLegs;
  final int currentLeg;

  final String lrNo;
  final String tripNo;
  final String tripStatus;

  final int driverAdvance;
  final int dieselAmount;
  final int tollAmount;
  final int loadingAmount;
  final int unloadingAmount;
  final int commissionAmount;
  final int miscAmount;

  final int totalFuelCost;
  final int totalFuelQuantity;
  final int totalFuelEntries;
  final int totalExpense;
  final int totalExpenseEntries;
  final int profit;
  final int distanceTravelled;

  final DateTime createdAt;
  final DateTime updatedAt;

  TripData({
    required this.id,
    required this.businessId,
    required this.fleetSource,
    required this.journeyType,
    required this.vehicleCategory,
    required this.commodity,
    required this.weight,
    required this.uom,
    required this.freightAmount,
    required this.advanceAmount,
    required this.loadType,
    required this.paymentType,
    required this.origin,
    required this.destination,
    required this.loading,
    required this.unloading,
    required this.vehicle,
    required this.driver1,
    this.driver2,
    required this.journeyLegs,
    required this.currentLeg,
    required this.lrNo,
    required this.tripNo,
    required this.tripStatus,
    required this.driverAdvance,
    required this.dieselAmount,
    required this.tollAmount,
    required this.loadingAmount,
    required this.unloadingAmount,
    required this.commissionAmount,
    required this.miscAmount,
    required this.totalFuelCost,
    required this.totalFuelQuantity,
    required this.totalFuelEntries,
    required this.totalExpense,
    required this.totalExpenseEntries,
    required this.profit,
    required this.distanceTravelled,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      fleetSource: json["fleetSource"] ?? "",
      journeyType: json["journeyType"] ?? "",
      vehicleCategory: json["vehicleCategory"] ?? "",
      commodity: json["commodity"] ?? "",
      weight: json["weight"] ?? 0,
      uom: json["uom"] ?? "",
      freightAmount: json["freightAmount"] ?? 0,
      advanceAmount: json["advanceAmount"] ?? 0,
      loadType: json["loadType"] ?? "",
      paymentType: json["paymentType"] ?? "",

      origin: Origin.fromJson(json["origin"] ?? {}),
      destination: Destination.fromJson(json["destination"] ?? {}),
      loading: Loading.fromJson(json["loading"] ?? {}),
      unloading: Unloading.fromJson(json["unloading"] ?? {}),

      vehicle: Vehicle.fromJson(json["vehicleId"] ?? {}),
      driver1: Driver.fromJson(json["driver1"] ?? {}),
      driver2: json["driver2"] == null
          ? null
          : Driver.fromJson(json["driver2"]),

      journeyLegs: (json["journeyLegs"] as List? ?? [])
          .map((e) => JourneyLeg.fromJson(e))
          .toList(),

      currentLeg: json["currentLeg"] ?? 0,

      lrNo: json["lrNo"] ?? "",
      tripNo: json["tripNo"] ?? "",
      tripStatus: json["tripStatus"] ?? "",

      driverAdvance: json["driverAdvance"] ?? 0,
      dieselAmount: json["dieselAmount"] ?? 0,
      tollAmount: json["tollAmount"] ?? 0,
      loadingAmount: json["loadingAmount"] ?? 0,
      unloadingAmount: json["unloadingAmount"] ?? 0,
      commissionAmount: json["commissionAmount"] ?? 0,
      miscAmount: json["miscAmount"] ?? 0,

      totalFuelCost: json["totalFuelCost"] ?? 0,
      totalFuelQuantity: json["totalFuelQuantity"] ?? 0,
      totalFuelEntries: json["totalFuelEntries"] ?? 0,
      totalExpense: json["totalExpense"] ?? 0,
      totalExpenseEntries: json["totalExpenseEntries"] ?? 0,
      profit: json["profit"] ?? 0,
      distanceTravelled: json["distanceTravelled"] ?? 0,

      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
    );
  }
}

class Origin {
  final String location;
  final String city;
  final String state;

  Origin({
    required this.location,
    required this.city,
    required this.state,
  });

  factory Origin.fromJson(Map<String, dynamic> json) => Origin(
    location: json["location"] ?? "",
    city: json["city"] ?? "",
    state: json["state"] ?? "",
  );
}

class Destination {
  final String location;
  final String city;
  final String state;

  Destination({
    required this.location,
    required this.city,
    required this.state,
  });

  factory Destination.fromJson(Map<String, dynamic> json) => Destination(
    location: json["location"] ?? "",
    city: json["city"] ?? "",
    state: json["state"] ?? "",
  );
}

class Loading {
  final String status;

  Loading({required this.status});

  factory Loading.fromJson(Map<String, dynamic> json) =>
      Loading(status: json["status"] ?? "");
}

class Unloading {
  final String status;

  Unloading({required this.status});

  factory Unloading.fromJson(Map<String, dynamic> json) =>
      Unloading(status: json["status"] ?? "");
}

class Vehicle {
  final String id;
  final String regNo;
  final String fleet;
  final String type;
  final String make;
  final String model;
  final int year;
  final String status;
  final String ownership;

  Vehicle({
    required this.id,
    required this.regNo,
    required this.fleet,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.status,
    required this.ownership,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["_id"] ?? "",
    regNo: json["regNo"] ?? "",
    fleet: json["fleet"] ?? "",
    type: json["type"] ?? "",
    make: json["make"] ?? "",
    model: json["model"] ?? "",
    year: json["year"] ?? 0,
    status: json["status"] ?? "",
    ownership: json["ownerShip"] ?? "",
  );
}

class Driver {
  final String id;
  final String driverId;
  final String name;
  final int mobile;
  final String dlNo;
  final String dlClass;
  final String availableStatus;

  Driver({
    required this.id,
    required this.driverId,
    required this.name,
    required this.mobile,
    required this.dlNo,
    required this.dlClass,
    required this.availableStatus,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["_id"] ?? "",
    driverId: json["driverId"] ?? "",
    name: json["name"] ?? "",
    mobile: json["mobile"] ?? 0,
    dlNo: json["dlNo"] ?? "",
    dlClass: json["dlClass"] ?? "",
    availableStatus: json["availableStatus"] ?? "",
  );
}

class JourneyLeg {
  final int legNo;
  final String from;
  final String to;
  final String customerId;
  final String status;

  JourneyLeg({
    required this.legNo,
    required this.from,
    required this.to,
    required this.customerId,
    required this.status,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) => JourneyLeg(
    legNo: json["legNo"] ?? 0,
    from: json["from"] ?? "",
    to: json["to"] ?? "",
    customerId: json["customerId"] ?? "",
    status: json["status"] ?? "",
  );
}

class StartTripRequest {
  final double startOdometer;

  StartTripRequest({
    required this.startOdometer,
  });

  Map<String, dynamic> toJson() {
    return {
      "startOdometer": startOdometer,
    };
  }
}

class ArrivalRequest {
  final int arrivalOdometer;
  final String remarks;

  ArrivalRequest({
    required this.arrivalOdometer,
    required this.remarks,
  });

  Map<String, dynamic> toJson() => {
    "arrivalOdometer": arrivalOdometer,
    "remarks": remarks,
  };
}
