class CustomerResponse {
  final bool success;
  final Customer data;

  CustomerResponse({
    required this.success,
    required this.data,
  });

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      success: json['success'],
      data: Customer.fromJson(json['data']),
    );
  }
}

class Customer {
  final String id;
  final String companyName;
  final String contactPerson;
  final int mobile;
  final String billingAddress;

  Customer({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.mobile,
    required this.billingAddress,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] ?? '',
      companyName: json['companyName'] ?? '',
      contactPerson: json['contactPerson'] ?? '',
      mobile: json['mobile'] ?? 0,
      billingAddress: json['billingAddress'] ?? '',
    );
  }
}