import 'dart:convert';

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
  final String vehicleCategory;
  final String journeyType;
  final int currentLeg;
  final String tripStatus;

  final List<JourneyLeg> journeyLegs;

  final double totalFuelCost;
  final double totalFuelQuantity;
  final double totalExpense;
  final double profit;
  final int distanceTravelled;

  final List<dynamic> totalFuelEntries;
  final List<dynamic> totalExpenseEntries;

  final String createdAt;
  final String updatedAt;
  final String tripNo;

  final Settlement settlement;
  final JourneyLeg? currentJourneyLeg;

  final dynamic loadingExpense;
  final dynamic unloadingExpense;

  final CurrentLegWeighbridge? currentLegWeighbridge;

  CurrentTrip({
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
    this.currentJourneyLeg,
    this.loadingExpense,
    this.unloadingExpense,
    this.currentLegWeighbridge,
  });

  factory CurrentTrip.fromJson(Map<String, dynamic> json) {
    return CurrentTrip(
      id: json["_id"] ?? "",
      businessId: json["businessId"] ?? "",
      fleetSource: json["fleetSource"] ?? "",
      vehicleId: json["vehicleId"] ?? "",
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

      totalFuelCost: (json["totalFuelCost"] ?? 0).toDouble(),
      totalFuelQuantity: (json["totalFuelQuantity"] ?? 0).toDouble(),
      totalExpense: (json["totalExpense"] ?? 0).toDouble(),
      profit: (json["profit"] ?? 0).toDouble(),
      distanceTravelled: json["distanceTravelled"] ?? 0,

      totalFuelEntries:
      List<dynamic>.from(json["totalFuelEntries"] ?? []),

      totalExpenseEntries:
      List<dynamic>.from(json["totalExpenseEntries"] ?? []),

      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      tripNo: json["tripNo"] ?? "",

      settlement: Settlement.fromJson(
        json["settlement"] ?? {},
      ),

      currentJourneyLeg: json["currentJourneyLeg"] != null
          ? JourneyLeg.fromJson(
        Map<String, dynamic>.from(json["currentJourneyLeg"]),
      )
          : null,

      loadingExpense: json["loadingExpense"],
      unloadingExpense: json["unloadingExpense"],

      currentLegWeighbridge: json["currentLegWeighbridge"] != null
          ? CurrentLegWeighbridge.fromJson(
        Map<String, dynamic>.from(
          json["currentLegWeighbridge"],
        ),
      )
          : null,
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
      settledAmount: (json["settledAmount"] ?? 0).toDouble(),
    );
  }
}

class JourneyLeg {
  final int legNo;
  final String from;
  final String to;

  final String customerId;
  final String brokerId;

  final String commodity;
  final double weight;
  final String uom;

  final double amountPerTon;
  final double estimatedFreightAmount;

  final String loadType;
  final String paymentType;

  final String driver1;
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

      customerId: json["customerId"] ?? "",
      brokerId: json["brokerId"] ?? "",

      commodity: json["commodity"] ?? "",
      weight: (json["weight"] ?? 0).toDouble(),
      uom: json["uom"] ?? "",

      amountPerTon: (json["amountPerTon"] ?? 0).toDouble(),
      estimatedFreightAmount:
      (json["estimatedFreightAmount"] ?? 0).toDouble(),

      loadType: json["loadType"] ?? "",
      paymentType: json["paymentType"] ?? "",

      driver1: json["driver1"] ?? "",
      driverSalary: (json["driverSalary"] ?? 0).toDouble(),

      driverAdvance: (json["driverAdvance"] as List? ?? [])
          .map(
            (e) => DriverAdvance.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )
          .toList(),

      legStatus: json["legStatus"] ?? "",
      id: json["_id"] ?? "",

      loading: LegLoading.fromJson(
        json["loading"] ?? {},
      ),

      unloading: LegUnloading.fromJson(
        json["unloading"] ?? {},
      ),

      pc: LegPC.fromJson(
        json["PC"] ?? {},
      ),

      weighbridge: LegWeighbridge.fromJson(
        json["weighbridge"] ?? {},
      ),

      tripExpense:
      List<dynamic>.from(json["tripExpense"] ?? []),
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
      amount: (json["amount"] ?? 0).toDouble(),
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
      amount: (json["amount"] ?? 0).toDouble(),
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

class CurrentLegWeighbridge {
  final String status;
  final String? fileUrl;

  CurrentLegWeighbridge({
    required this.status,
    this.fileUrl,
  });

  factory CurrentLegWeighbridge.fromJson(
      Map<String, dynamic> json,
      ) {
    return CurrentLegWeighbridge(
      status: json["status"] ?? "",
      fileUrl: json["fileUrl"],
    );
  }
}