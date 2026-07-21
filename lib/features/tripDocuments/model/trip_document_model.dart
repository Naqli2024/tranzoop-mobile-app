class TripDocumentResponse {
  final bool success;
  final List<TripDocument> data;

  TripDocumentResponse({
    required this.success,
    required this.data,
  });

  factory TripDocumentResponse.fromJson(Map<String, dynamic> json) {
    return TripDocumentResponse(
      success: json["success"] ?? false,
      data: (json["data"] as List)
          .map((e) => TripDocument.fromJson(e))
          .toList(),
    );
  }
}

class TripDocument {
  final String id;
  final String documentType;
  final String uploadedBy;
  final DateTime createdAt;
  final String fileUrl;

  TripDocument({
    required this.id,
    required this.documentType,
    required this.uploadedBy,
    required this.createdAt,
    required this.fileUrl,
  });

  factory TripDocument.fromJson(Map<String, dynamic> json) {
    return TripDocument(
      id: json["_id"] ?? "",
      documentType: json["documentType"] ?? "",
      uploadedBy: json["uploadedBy"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
      fileUrl: json["fileUrl"] ?? "",
    );
  }
}