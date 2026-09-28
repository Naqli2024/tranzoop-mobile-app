import 'package:bizoop_driver_app/features/trips/model/customer_model.dart';

class TripDetails {
  final bool success;
  final TripData? data;

  TripDetails({
    required this.success,
    this.data,
  });

  factory TripDetails.fromJson(Map<String, dynamic> json) {
    return TripDetails(
      success: json["success"] ?? false,
      data: json["data"] != null
          ? TripData.fromJson(
        Map<String, dynamic>.from(json["data"]),
      )
          : null,
    );
  }
}


class TripData {
  final String id;
  final String businessId;
  final String fleetSource;

  final Vehicle? vehicleId;

  final String vehicleCategory;
  final String journeyType;
  final int currentLeg;
  final String tripStatus;

  final List<JourneyLeg> journeyLegs;

  final double totalFuelCost;
  final double totalFuelQuantity;
  final double totalExpense;
  final double profit;
  final double distanceTravelled;

  final List<dynamic> totalFuelEntries;
  final List<dynamic> totalExpenseEntries;

  final String createdAt;
  final String updatedAt;
  final String tripNo;

  final Settlement settlement;

  TripData({
    required this.id,
    required this.businessId,
    required this.fleetSource,
    required this.vehicleId,
    required this.vehicleCategory,
    required this.journeyType,
    required this.currentLeg,
    required this.tripStatus,
    required this.journeyLegs,
    required this.totalFuelCost,
    required this.totalFuelQuantity,
    required this.totalExpense,
    required this.profit,
    required this.distanceTravelled,
    required this.totalFuelEntries,
    required this.totalExpenseEntries,
    required this.createdAt,
    required this.updatedAt,
    required this.tripNo,
    required this.settlement,
  });

  factory TripData.fromJson(Map<String, dynamic> json) {
    return TripData(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      fleetSource: json["fleetSource"] ?? "",

      vehicleId: json["vehicleId"] != null &&
          json["vehicleId"] is Map
          ? Vehicle.fromJson(
        Map<String, dynamic>.from(json["vehicleId"]),
      )
          : null,

      vehicleCategory: json["vehicleCategory"] ?? "",
      journeyType: json["journeyType"] ?? "",
      currentLeg: json["currentLeg"] ?? 0,
      tripStatus: json["tripStatus"] ?? "",

      journeyLegs: (json["journeyLegs"] as List? ?? [])
          .map(
            (e) => JourneyLeg.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      totalFuelCost:
      (json["totalFuelCost"] as num?)?.toDouble() ?? 0.0,

      totalFuelQuantity:
      (json["totalFuelQuantity"] as num?)?.toDouble() ?? 0.0,

      totalExpense:
      (json["totalExpense"] as num?)?.toDouble() ?? 0.0,

      profit:
      (json["profit"] as num?)?.toDouble() ?? 0.0,

      distanceTravelled:
      (json["distanceTravelled"] as num?)?.toDouble() ?? 0.0,

      totalFuelEntries:
      List<dynamic>.from(json["totalFuelEntries"] ?? []),

      totalExpenseEntries:
      List<dynamic>.from(json["totalExpenseEntries"] ?? []),

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      tripNo: json["tripNo"] ?? "",

      settlement: json["settlement"] != null
          ? Settlement.fromJson(
        Map<String, dynamic>.from(json["settlement"]),
      )
          : Settlement(
        status: "",
        settledAmount: 0,
      ),
    );
  }
}

class Settlement {
  final String status;
  final double settledAmount;

  Settlement({
    required this.status,
    required this.settledAmount,
  });

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      status: json["status"] ?? "",
      settledAmount:
      (json["settledAmount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Vehicle {
  final String id;
  final String businessId;
  final String regNo;
  final String fleet;
  final String type;
  final String make;
  final String model;

  final int year;

  final String engineNo;
  final String chassisNo;
  final String axle;

  final double gvw;
  final double currentKm;

  final String healthStatus;
  final String ownerShip;

  final String insuranceExpiryDate;
  final String rcBookExpiryDate;
  final String fcExpiryDate;
  final String taxExpiryDate;
  final String permitExpiryDate;
  final String pollutionExpiryDate;

  final String permitType;

  final double purchaseCost;

  final bool tollTagAvailable;

  final String status;

  final double currentEngineHours;
  final double lastPmHours;
  final double pmIntervalHours;

  final double fitnessScore;

  final List<dynamic> loggedHrs;
  final List<dynamic> complianceDocs;
  final List<dynamic> routes;
  final List<dynamic> ticketLogs;

  final String createdAt;
  final String updatedAt;

  final AssignedDriver assignedDriver;

  Vehicle({
    required this.id,
    required this.businessId,
    required this.regNo,
    required this.fleet,
    required this.type,
    required this.make,
    required this.model,
    required this.year,
    required this.engineNo,
    required this.chassisNo,
    required this.axle,
    required this.gvw,
    required this.currentKm,
    required this.healthStatus,
    required this.ownerShip,
    required this.insuranceExpiryDate,
    required this.rcBookExpiryDate,
    required this.fcExpiryDate,
    required this.taxExpiryDate,
    required this.permitExpiryDate,
    required this.pollutionExpiryDate,
    required this.permitType,
    required this.purchaseCost,
    required this.tollTagAvailable,
    required this.status,
    required this.currentEngineHours,
    required this.lastPmHours,
    required this.pmIntervalHours,
    required this.fitnessScore,
    required this.loggedHrs,
    required this.complianceDocs,
    required this.routes,
    required this.ticketLogs,
    required this.createdAt,
    required this.updatedAt,
    required this.assignedDriver,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      regNo: json["regNo"] ?? "",
      fleet: json["fleet"] ?? "",
      type: json["type"] ?? "",
      make: json["make"] ?? "",
      model: json["model"] ?? "",
      year: json["year"] ?? 0,

      engineNo: json["engineNo"] ?? "",
      chassisNo: json["chassisNo"] ?? "",
      axle: json["axle"] ?? "",

      gvw: (json["gvw"] as num?)?.toDouble() ?? 0.0,
      currentKm:
      (json["currentKm"] as num?)?.toDouble() ?? 0.0,

      healthStatus: json["healthStatus"] ?? "",
      ownerShip: json["ownerShip"] ?? "",

      insuranceExpiryDate:
      json["insuranceExpiryDate"] ?? "",

      rcBookExpiryDate:
      json["rcBookExpiryDate"] ?? "",

      fcExpiryDate:
      json["fcExpiryDate"] ?? "",

      taxExpiryDate:
      json["taxExpiryDate"] ?? "",

      permitExpiryDate:
      json["permitExpiryDate"] ?? "",

      pollutionExpiryDate:
      json["pollutionExpiryDate"] ?? "",

      permitType: json["permitType"] ?? "",

      purchaseCost:
      (json["purchaseCost"] as num?)?.toDouble() ?? 0.0,

      tollTagAvailable:
      json["tollTagAvailable"] ?? false,

      status: json["status"] ?? "",

      currentEngineHours:
      (json["currentEngineHours"] as num?)?.toDouble() ?? 0.0,

      lastPmHours:
      (json["lastPmHours"] as num?)?.toDouble() ?? 0.0,

      pmIntervalHours:
      (json["pmIntervalHours"] as num?)?.toDouble() ?? 0.0,

      fitnessScore:
      (json["fitnessScore"] as num?)?.toDouble() ?? 0.0,

      loggedHrs:
      List<dynamic>.from(json["loggedHrs"] ?? []),

      complianceDocs:
      List<dynamic>.from(json["complianceDocs"] ?? []),

      routes:
      List<dynamic>.from(json["routes"] ?? []),

      ticketLogs:
      List<dynamic>.from(json["ticketLogs"] ?? []),

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",

      assignedDriver: json["assignedDriver"] != null
          ? AssignedDriver.fromJson(
        Map<String, dynamic>.from(json["assignedDriver"]),
      )
          : AssignedDriver(status: ""),
    );
  }
}


class AssignedDriver {
  final String status;

  AssignedDriver({
    required this.status,
  });

  factory AssignedDriver.fromJson(Map<String, dynamic> json) {
    return AssignedDriver(
      status: json["status"] ?? "",
    );
  }
}

class JourneyLeg {
  final int legNo;
  final String from;
  final String to;
  final Customer? customerId;
  final Broker? brokerId;
  final String commodity;
  final double weight;
  final String uom;
  final double amountPerTon;
  final double estimatedFreightAmount;
  final String loadType;
  final String paymentType;
  final Driver? driver1;
  final double driverSalary;
  final List<DriverAdvance> driverAdvance;
  final String legStatus;
  final String id;
  final LegLoading loading;
  final LegUnloading unloading;
  final LegPC pc;
  final LegWeighbridge weighbridge;
  final List<dynamic> tripExpense;

  JourneyLeg({
    required this.legNo,
    required this.from,
    required this.to,
    required this.customerId,
    required this.brokerId,
    required this.commodity,
    required this.weight,
    required this.uom,
    required this.amountPerTon,
    required this.estimatedFreightAmount,
    required this.loadType,
    required this.paymentType,
    required this.driver1,
    required this.driverSalary,
    required this.driverAdvance,
    required this.legStatus,
    required this.id,
    required this.loading,
    required this.unloading,
    required this.pc,
    required this.weighbridge,
    required this.tripExpense,
  });

  factory JourneyLeg.fromJson(Map<String, dynamic> json) {
    return JourneyLeg(
      legNo: json["legNo"] ?? 0,
      from: json["from"] ?? "",
      to: json["to"] ?? "",

      customerId: json["customerId"] != null &&
          json["customerId"] is Map
          ? Customer.fromJson(
        Map<String, dynamic>.from(json["customerId"]),
      )
          : null,

      brokerId: json["brokerId"] != null &&
          json["brokerId"] is Map
          ? Broker.fromJson(
        Map<String, dynamic>.from(json["brokerId"]),
      )
          : null,

      commodity: json["commodity"] ?? "",
      weight: (json["weight"] ?? 0).toDouble(),
      uom: json["uom"] ?? "",
      amountPerTon: (json["amountPerTon"] ?? 0).toDouble(),
      estimatedFreightAmount:
      (json["estimatedFreightAmount"] ?? 0).toDouble(),
      loadType: json["loadType"] ?? "",
      paymentType: json["paymentType"] ?? "",

      driver1: json["driver1"] != null &&
          json["driver1"] is Map
          ? Driver.fromJson(
        Map<String, dynamic>.from(json["driver1"]),
      )
          : null,

      driverSalary: (json["driverSalary"] ?? 0).toDouble(),

      driverAdvance:
      (json["driverAdvance"] as List? ?? [])
          .map(
            (e) => DriverAdvance.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      legStatus: json["legStatus"] ?? "",
      id: json["_id"] ?? "",

      loading: LegLoading.fromJson(
        Map<String, dynamic>.from(
          json["loading"] ?? {},
        ),
      ),

      unloading: LegUnloading.fromJson(
        Map<String, dynamic>.from(
          json["unloading"] ?? {},
        ),
      ),

      pc: LegPC.fromJson(
        Map<String, dynamic>.from(
          json["PC"] ?? {},
        ),
      ),

      weighbridge: LegWeighbridge.fromJson(
        Map<String, dynamic>.from(
          json["weighbridge"] ?? {},
        ),
      ),

      tripExpense: List<dynamic>.from(
        json["tripExpense"] ?? [],
      ),
    );
  }
}

class Broker {
  final String id;
  final String businessId;
  final String companyName;
  final String contactPerson;
  final int mobile;
  final String email;
  final String gstNo;

  final String address;
  final String city;
  final String state;
  final String country;
  final String pincode;

  final String commissionType;
  final double commissionValue;

  final String paymentTerms;
  final String status;

  final int totalTrips;
  final double totalCommission;
  final double outstandingAmount;

  final String createdAt;
  final String updatedAt;

  final String brokerId;

  Broker({
    required this.id,
    required this.businessId,
    required this.companyName,
    required this.contactPerson,
    required this.mobile,
    required this.email,
    required this.gstNo,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.commissionType,
    required this.commissionValue,
    required this.paymentTerms,
    required this.status,
    required this.totalTrips,
    required this.totalCommission,
    required this.outstandingAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.brokerId,
  });

  factory Broker.fromJson(Map<String, dynamic> json) {
    return Broker(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      companyName: json["companyName"] ?? "",
      contactPerson: json["contactPerson"] ?? "",
      mobile: json["mobile"] ?? 0,
      email: json["email"] ?? "",
      gstNo: json["gstNo"] ?? "",

      address: json["address"] ?? "",
      city: json["city"] ?? "",
      state: json["state"] ?? "",
      country: json["country"] ?? "",
      pincode: json["pincode"] ?? "",

      commissionType: json["commissionType"] ?? "",

      commissionValue:
      (json["commissionValue"] as num?)?.toDouble() ?? 0.0,

      paymentTerms: json["paymentTerms"] ?? "",
      status: json["status"] ?? "",

      totalTrips: json["totalTrips"] ?? 0,

      totalCommission:
      (json["totalCommission"] as num?)?.toDouble() ?? 0.0,

      outstandingAmount:
      (json["outstandingAmount"] as num?)?.toDouble() ?? 0.0,

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",

      brokerId: json["brokerId"] ?? "",
    );
  }
}

class Driver {
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

  final String currentTripId;

  final int totalTrips;

  final String createdAt;
  final String updatedAt;

  final String driverId;

  final DriverVehicle vehicle;

  Driver({
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

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
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

      currentTripId: json["currentTripId"] ?? "",

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

class DriverAdvance {
  final String date;
  final double amount;
  final String id;

  DriverAdvance({
    required this.date,
    required this.amount,
    required this.id,
  });

  factory DriverAdvance.fromJson(Map<String, dynamic> json) {
    return DriverAdvance(
      date: json["date"] ?? "",
      amount:
      (json["amount"] as num?)?.toDouble() ?? 0.0,
      id: json["_id"] ?? "",
    );
  }
}

class LegLoading {
  final String status;

  LegLoading({
    required this.status,
  });

  factory LegLoading.fromJson(Map<String, dynamic> json) {
    return LegLoading(
      status: json["status"] ?? "",
    );
  }
}


class LegUnloading {
  final String status;

  LegUnloading({
    required this.status,
  });

  factory LegUnloading.fromJson(Map<String, dynamic> json) {
    return LegUnloading(
      status: json["status"] ?? "",
    );
  }
}


class LegPC {
  final double amount;

  LegPC({
    required this.amount,
  });

  factory LegPC.fromJson(Map<String, dynamic> json) {
    return LegPC(
      amount:
      (json["amount"] as num?)?.toDouble() ?? 0.0,
    );
  }
}


class LegWeighbridge {
  final String status;

  LegWeighbridge({
    required this.status,
  });

  factory LegWeighbridge.fromJson(Map<String, dynamic> json) {
    return LegWeighbridge(
      status: json["status"] ?? "",
    );
  }
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
