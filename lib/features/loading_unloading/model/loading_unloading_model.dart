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

class UnloadingRequest {
  final String odometer;
  final String unloadingBy;
  final String receiverName;
  final String receiverMobile;

  UnloadingRequest({
    required this.odometer,
    required this.unloadingBy,
    required this.receiverName,
    required this.receiverMobile
  });

  Map<String, dynamic> toJson() => {
    "odometer": odometer,
    "unloadingBy": unloadingBy,
    "receiverName": receiverName,
    "receiverMobile": receiverMobile,
  };
}