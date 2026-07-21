class DriverSummaryResponse {
  final bool success;
  final DriverDashboard data;

  DriverSummaryResponse({
    required this.success,
    required this.data,
  });

  factory DriverSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DriverSummaryResponse(
      success: json["success"] ?? false,
      data: DriverDashboard.fromJson(json["data"] ?? {}),
    );
  }
}

class DriverDashboard {
  final DriverSummary summary;
  final List<TripHistory> tripHistory;

  DriverDashboard({
    required this.summary,
    required this.tripHistory,
  });

  factory DriverDashboard.fromJson(Map<String, dynamic> json) {
    return DriverDashboard(
      summary: DriverSummary.fromJson(json["summary"] ?? {}),
      tripHistory: (json["tripHistory"] as List? ?? [])
          .map((e) => TripHistory.fromJson(e))
          .toList(),
    );
  }
}

class DriverSummary {
  final String driverName;
  final int mobile;
  final String availableStatus;

  final int totalTrips;
  final int completedTrips;
  final int runningTrips;
  final int cancelledTrips;

  final int totalDistance;
  final int totalFuel;
  final int fuelEntries;
  final int revenue;

  final String joiningDate;
  final String licenseExpiryDate;

  DriverSummary({
    required this.driverName,
    required this.mobile,
    required this.availableStatus,
    required this.totalTrips,
    required this.completedTrips,
    required this.runningTrips,
    required this.cancelledTrips,
    required this.totalDistance,
    required this.totalFuel,
    required this.fuelEntries,
    required this.revenue,
    required this.joiningDate,
    required this.licenseExpiryDate,
  });

  factory DriverSummary.fromJson(Map<String, dynamic> json) {
    return DriverSummary(
      driverName: json["driverName"] ?? "",
      mobile: json["mobile"] ?? 0,
      availableStatus: json["availableStatus"] ?? "",
      totalTrips: json["totalTrips"] ?? 0,
      completedTrips: json["completedTrips"] ?? 0,
      runningTrips: json["runningTrips"] ?? 0,
      cancelledTrips: json["cancelledTrips"] ?? 0,
      totalDistance: json["totalDistance"] ?? 0,
      totalFuel: json["totalFuel"] ?? 0,
      fuelEntries: json["fuelEntries"] ?? 0,
      revenue: json["revenue"] ?? 0,
      joiningDate: json["joiningDate"] ?? "",
      licenseExpiryDate: json["licenseExpiryDate"] ?? "",
    );
  }
}

class TripHistory {
  final String tripId;
  final String tripNo;
  final String tripStatus;
  final String startTime;
  final int distanceTravelled;
  final int freightAmount;
  final int totalFuelQuantity;

  TripHistory({
    required this.tripId,
    required this.tripNo,
    required this.tripStatus,
    required this.startTime,
    required this.distanceTravelled,
    required this.freightAmount,
    required this.totalFuelQuantity,
  });

  factory TripHistory.fromJson(Map<String, dynamic> json) {
    return TripHistory(
      tripId: json["tripId"] ?? "",
      tripNo: json["tripNo"] ?? "",
      tripStatus: json["tripStatus"] ?? "",
      startTime: json["startTime"] ?? "",
      distanceTravelled: json["distanceTravelled"] ?? 0,
      freightAmount: json["freightAmount"] ?? 0,
      totalFuelQuantity: json["totalFuelQuantity"] ?? 0,
    );
  }
}