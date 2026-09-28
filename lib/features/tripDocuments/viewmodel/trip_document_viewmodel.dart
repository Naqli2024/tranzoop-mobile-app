import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/tripDocuments/model/trip_document_model.dart';
import 'package:bizoop_driver_app/features/tripDocuments/service/trip_document_service.dart';

class TripDocumentViewModel extends ChangeNotifier {
  final TripDocumentService _documentService = TripDocumentService();
  final SharedPrefService _pref = SharedPrefService();

  bool isLoading = false;
  String errorMessage = "";
  List<TripDocument> documents = [];

  Future<void> fetchDocuments(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();
      if (token == null) return;

      final response = await _documentService.fetchDocuments(
        token: token,
        tripId: tripId,
      );
      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        documents = TripDocumentResponse.fromJson(json).data;
      } else {
        errorMessage = json["message"];
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();

    }
  }
}