class BusinessModel {
  final String id;
  final String transportName;
  final String address;
  final String mobile;
  final bool isVerified;
  final String gstNo;
  final String businessType;
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessModel({
    required this.id,
    required this.transportName,
    required this.address,
    required this.mobile,
    required this.isVerified,
    required this.gstNo,
    required this.businessType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['_id'] ?? '',
      transportName: json['transportName'] ?? '',
      address: json['address'] ?? '',
      mobile: json['mobile'] ?? '',
      isVerified: json['isVerified'] ?? false,
      gstNo: json['gstNo'] ?? '',
      businessType: json['businessType'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}