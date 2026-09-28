import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/bills/model/trip_expense_modal.dart';
import 'package:bizoop_driver_app/features/bills/service/trip_expense_service.dart';
import 'package:bizoop_driver_app/features/loading_unloading/model/loading_unloading_model.dart';

class TripExpenseViewModel extends ChangeNotifier {
  final TripExpenseService _service = TripExpenseService();
  final SharedPrefService _pref = SharedPrefService();

  bool isLoading = false;
  String errorMessage = "";
  String successMessage = "";
  TripExpenseResponse? expenses;

  Future<void> fetchExpenses(String tripId) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) return;

      final response = await _service.getExpenses(
        token: token,
        tripId: tripId,
      );
      if (response.statusCode == 200) {
        expenses = TripExpenseResponse.fromJson(
          jsonDecode(response.body),
        );
      }
      errorMessage = "";
    } catch (e) {
      print("fetchExpenses error: $e");
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> updateExpense({
    required String expenseId,
    required LoadingUnloadingExpenseRequest request,
  }) async {

    try {
      isLoading = true;
      notifyListeners();
      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }
      final response = await _service.updateExpense(
        expenseId: expenseId,
        token: token,
        request: request,
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
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required String tripId,
    required LoadingUnloadingExpenseRequest request,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final token = await _pref.getToken();

      if (token == null) {
        errorMessage = "Token not found";
        return false;
      }

      final response = await _service.uploadLoadingUnloadingExpense(
        tripId: tripId,
        token: token,
        request: request,
      );

      successMessage = response.message;
      errorMessage = "";

      await fetchExpenses(tripId);

      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}