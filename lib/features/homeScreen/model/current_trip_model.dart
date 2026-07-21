class CurrentTripResponse {
  final bool success;
  final CurrentTrip? data;

  CurrentTripResponse({
    required this.success,
    this.data,
  });

  factory CurrentTripResponse.fromJson(Map<String, dynamic> json) {
    return CurrentTripResponse(
      success: json["success"] ?? false,
      data: json["data"] != null
          ? CurrentTrip.fromJson(json["data"])
          : null,
    );
  }
}

class CurrentTrip {
  final String id;
  final String businessId;
  final String fleetSource;
  final String vehicleId;
  final String journeyType;
  final String vehicleCategory;
  final String commodity;
  final int weight;
  final String uom;
  final double freightAmount;
  final double advanceAmount;
  final String loadType;
  final String paymentType;
  final String customerId;
  final String brokerId;

  final List<JourneyLeg> journeyLegs;
  final int currentLeg;

  final String lrNo;
  final String driverId;

  final double driverAdvance;
  final double dieselAmount;
  final double tollAmount;
  final double loadingAmount;
  final double unloadingAmount;
  final double commissionAmount;
  final double miscAmount;

  final String tripStatus;

  final double totalFuelCost;
  final double totalFuelQuantity;
  final int totalFuelEntries;

  final double totalExpense;
  final int totalExpenseEntries;

  final double profit;
  final int distanceTravelled;

  final String createdAt;
  final String updatedAt;
  final String? pickupReachedAt;

  final String tripNo;

  final Origin origin;
  final Destination destination;
  final Loading loading;
  final Unloading unloading;

  CurrentTrip({
    required this.id,
    required this.businessId,
    required this.fleetSource,
    required this.vehicleId,
    required this.journeyType,
    required this.vehicleCategory,
    required this.commodity,
    required this.weight,
    required this.uom,
    required this.freightAmount,
    required this.advanceAmount,
    required this.loadType,
    required this.paymentType,
    required this.customerId,
    required this.brokerId,
    required this.journeyLegs,
    required this.currentLeg,
    required this.lrNo,
    required this.driverId,
    required this.driverAdvance,
    required this.dieselAmount,
    required this.tollAmount,
    required this.loadingAmount,
    required this.unloadingAmount,
    required this.commissionAmount,
    required this.miscAmount,
    required this.tripStatus,
    required this.totalFuelCost,
    required this.totalFuelQuantity,
    required this.totalFuelEntries,
    required this.totalExpense,
    required this.totalExpenseEntries,
    required this.profit,
    required this.distanceTravelled,
    required this.createdAt,
    required this.updatedAt,
    this.pickupReachedAt,
    required this.tripNo,
    required this.origin,
    required this.destination,
    required this.loading,
    required this.unloading,
  });

  factory CurrentTrip.fromJson(Map<String, dynamic> json) {
    return CurrentTrip(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      fleetSource: json["fleetSource"] ?? "",
      vehicleId: json["vehicleId"] ?? "",
      journeyType: json["journeyType"] ?? "",
      vehicleCategory: json["vehicleCategory"] ?? "",
      commodity: json["commodity"] ?? "",
      weight: json["weight"] ?? 0,
      uom: json["uom"] ?? "",
      freightAmount: (json["freightAmount"] ?? 0).toDouble(),
      advanceAmount: (json["advanceAmount"] ?? 0).toDouble(),
      loadType: json["loadType"] ?? "",
      paymentType: json["paymentType"] ?? "",
      customerId: json["customerId"] ?? "",
      brokerId: json["brokerId"] ?? "",
      journeyLegs: (json["journeyLegs"] as List? ?? [])
          .map((e) => JourneyLeg.fromJson(e))
          .toList(),
      currentLeg: json["currentLeg"] ?? 0,
      lrNo: json["lrNo"] ?? "",
      driverId: json["driver1"] ?? "",
      driverAdvance: (json["driverAdvance"] ?? 0).toDouble(),
      dieselAmount: (json["dieselAmount"] ?? 0).toDouble(),
      tollAmount: (json["tollAmount"] ?? 0).toDouble(),
      loadingAmount: (json["loadingAmount"] ?? 0).toDouble(),
      unloadingAmount: (json["unloadingAmount"] ?? 0).toDouble(),
      commissionAmount: (json["commissionAmount"] ?? 0).toDouble(),
      miscAmount: (json["miscAmount"] ?? 0).toDouble(),
      tripStatus: json["tripStatus"] ?? "",
      totalFuelCost: (json["totalFuelCost"] ?? 0).toDouble(),
      totalFuelQuantity: (json["totalFuelQuantity"] ?? 0).toDouble(),
      totalFuelEntries: json["totalFuelEntries"] ?? 0,
      totalExpense: (json["totalExpense"] ?? 0).toDouble(),
      totalExpenseEntries: json["totalExpenseEntries"] ?? 0,
      profit: (json["profit"] ?? 0).toDouble(),
      distanceTravelled: json["distanceTravelled"] ?? 0,
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      pickupReachedAt: json["pickupReachedAt"],
      tripNo: json["tripNo"] ?? "",
      origin: Origin.fromJson(json["origin"] ?? {}),
      destination: Destination.fromJson(json["destination"] ?? {}),
      loading: Loading.fromJson(json["loading"] ?? {}),
      unloading: Unloading.fromJson(json["unloading"] ?? {}),
    );
  }
}

class Origin {
  final String location;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  Origin({
    required this.location,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory Origin.fromJson(Map<String, dynamic> json) {
    return Origin(
      location: json["location"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
    );
  }
}

class Destination {
  final String location;
  final String city;
  final String state;
  final double latitude;
  final double longitude;

  Destination({
    required this.location,
    required this.city,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      location: json["location"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      latitude: (json["latitude"] ?? 0).toDouble(),
      longitude: (json["longitude"] ?? 0).toDouble(),
    );
  }
}

class Loading {
  final String status;

  Loading({required this.status});

  factory Loading.fromJson(Map<String, dynamic> json) {
    return Loading(
      status: json["status"] ?? "",
    );
  }
}

class Unloading {
  final String status;

  Unloading({required this.status});

  factory Unloading.fromJson(Map<String, dynamic> json) {
    return Unloading(
      status: json["status"] ?? "",
    );
  }
}

class JourneyLeg {
  final int legNo;
  final String from;
  final String to;
  final String customerId;
  final String brokerId;
  final String status;
  final String id;

  JourneyLeg({
    required this.legNo,
    required this.from,
    required this.to,
    required this.customerId,
    required this.brokerId,
    required this.status,
    required this.id,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) {
    return JourneyLeg(
      legNo: json["legNo"] ?? 0,
      from: json["from"] ?? "",
      to: json["to"] ?? "",
      customerId: json["customerId"] ?? "",
      brokerId: json["brokerId"] ?? "",
      status: json["status"] ?? "",
      id: json["_id"] ?? "",
    );
  }
}