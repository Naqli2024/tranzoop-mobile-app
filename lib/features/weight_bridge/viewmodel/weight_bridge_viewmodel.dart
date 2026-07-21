import 'package:flutter/material.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/weight_bridge/model/weight_bridge_model.dart';
import 'package:tranzoop_mobile_app/features/weight_bridge/service/weightbridge_api_service.dart';

class WeighbridgeViewModel extends ChangeNotifier {
  final WeighbridgeService _service = WeighbridgeService();
  final SharedPrefService _pref = SharedPrefService();
  bool isLoading = false;
  String successMessage = "";
  String errorMessage = "";

  Future<bool> uploadWeighbridge(
      String tripId,
      WeighbridgeRequest request,
      ) async {
    try {
      isLoading = true;
      notifyListeners();
      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      final response = await _service.uploadWeighbridge(
        tripId,
        token,
        request,
      );
      successMessage = response.message;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}