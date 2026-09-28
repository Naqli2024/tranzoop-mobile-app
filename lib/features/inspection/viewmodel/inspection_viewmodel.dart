import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/inspection/model/inspection_model.dart';
import 'package:bizoop_driver_app/features/inspection/service/inspection_service.dart';

class InspectionViewModel extends ChangeNotifier {
  final InspectionService _service = InspectionService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";

  // ---- Pre-trip ----
  InspectionDetailsResponse? inspectionDetails;
  String? failedInspectionId;
  String? inspectionStatus;

  // ---- Post-trip ----
  PostTripInspectionDetailsResponse? postInspectionDetails;
  String? failedPostInspectionId;
  String? postInspectionStatus;

  Future<bool> submitPreInspection(PreTripInspection request) async {
    try {
      final token = await _pref.getToken();
      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _service.submitPreTripInspection(
        endpoint: "create",
        body: request.toJson(),
        token: token,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        successMessage = data["message"] ?? "Inspection submitted";
        inspectionStatus =
            data["data"]?["inspectionStatus"] ?? "";
        return true;
      } else {
        errorMessage = data["message"] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePreInspection(PreTripInspection request,String inspectionId) async {
    try {
      final token = await _pref.getToken();
      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _service.updatePreTripInspection(
        endpoint: inspectionId,
        body: request.toJson(),
        token: token,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        successMessage = data["message"] ?? "Inspection submitted";
        inspectionStatus =
            data["data"]?["inspectionStatus"] ?? "";
        return true;
      } else {
        errorMessage = data["message"] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllPreTripInspection(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      failedInspectionId = null;
      inspectionDetails = null;
      inspectionStatus = "";

      final token = await _pref.getToken();
      final driverId = await _pref.getDriverId();

      if (token == null || driverId == null) {
        errorMessage = "Token not found";
        return;
      }

      final response = await _service.getAllPreTripInspection(
        token: token,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final List list = json["data"] ?? [];

        final inspections = list
            .where(
              (e) =>
          e["inspectedBy"] == driverId &&
              e["tripId"]["_id"] == tripId,
        )
            .toList();

        if (inspections.isNotEmpty) {
          // Get the latest inspection
          final latestInspection = inspections.last;

          inspectionStatus =
              latestInspection["inspectionStatus"]?.toString().trim() ?? "";

          // If latest inspection is Failed, keep its ID
          if (inspectionStatus?.toLowerCase() == "failed") {
            failedInspectionId = latestInspection["_id"];

            await fetchPreTripInspection(
              failedInspectionId!,
            );
          }
        } else {
          debugPrint("No inspection found for this trip");
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPreTripInspection(String inspectionId) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return;
      }
      final response = await _service.getPreTripInspectionById(
        endpoint: inspectionId,
        token: token,
      );
      if (response.statusCode == 200) {
        inspectionDetails = InspectionDetailsResponse.fromJson(
          jsonDecode(response.body),
        );
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data["message"] ?? "Unable to fetch inspection";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitPostTripInspection(PostTripInspection inspection) async {
    try {
      final token = await _pref.getToken();
      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      isLoading = true;
      errorMessage = "";
      notifyListeners();

      final response = await _service.submitPostTripInspection(
        tripId: inspection.tripId,
        token: token,
        body: inspection.toJson(),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        successMessage = data["message"] ?? "Inspection completed";
        postInspectionStatus = data["data"]?["inspectionStatus"] ?? "";
        return true;
      } else {
        errorMessage = data["message"] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePostInspection(PostTripInspection request,String inspectionId) async {
    try {
      final token = await _pref.getToken();
      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final response = await _service.updatePostTripInspection(
        endpoint: inspectionId,
        body: request.toJson(),
        token: token,
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        successMessage = data["message"] ?? "Inspection submitted";
        postInspectionStatus = data["data"]?["inspectionStatus"] ?? "";
        return true;
      } else {
        errorMessage = data["message"] ?? "Something went wrong";
        return false;
      }
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllPostTripInspection(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      failedPostInspectionId = null;
      postInspectionDetails = null;

      final token = await _pref.getToken();
      final driverId = await _pref.getDriverId();

      if (token == null || driverId == null) {
        errorMessage = "Token not found";
        return;
      }

      final response = await _service.getAllPostTripInspection(
        token: token,
        endpoint: 'posttripinspection'
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        final List list = json["data"] ?? [];
        final failedInspection = list.cast<Map<String, dynamic>>().firstWhere(
              (e) => e["inspectedBy"]?["_id"] == driverId &&
              e["inspectionStatus"] == "Failed" &&
              e["tripId"]?["_id"] == tripId,
          orElse: () => <String, dynamic>{},
        );
        if (failedInspection.isNotEmpty) {
          failedPostInspectionId = failedInspection["_id"];

          await fetchPostTripInspection(failedPostInspectionId!);
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostTripInspection(String inspectionId) async {
    try {
      isLoading = true;
      errorMessage = "";
      notifyListeners();
      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return;
      }

      final response = await _service.getPostTripInspectionById(
        endpoint: inspectionId,
        token: token,
      );
      if (response.statusCode == 200) {
        postInspectionDetails = PostTripInspectionDetailsResponse.fromJson(
          jsonDecode(response.body),
        );
      } else {
        final data = jsonDecode(response.body);
        errorMessage = data["message"] ?? "Unable to fetch inspection";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}