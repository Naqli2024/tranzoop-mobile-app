import 'dart:convert';
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bizoop_driver_app/core/utils/api_urls.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';

class LocationTaskHandler extends TaskHandler {
  final SharedPrefService _pref = SharedPrefService();
  bool _isSending = false;

  @override
  Future<void> onStart(
      DateTime timestamp,
      TaskStarter starter,
      ) async {
    FlutterForegroundTask.updateService(
      notificationTitle: "BIZOOP",
      notificationText: "Tracking Started",
    );
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {
    if (_isSending) return;

    _isSending = true;

    try {
      final driverId = await _pref.getDriverId();
      final token = await _pref.getToken();

      if (driverId == null || token == null) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      print("LAT : ${position.latitude}");
      print("LNG : ${position.longitude}");

      final response = await http.patch(
        Uri.parse("${ApiUrl.driverBaseUrl}$driverId/location"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "lat": position.latitude,
          "lng": position.longitude,
        }),
      );
    }  on SocketException {
      throw Exception("Please check your Internet Connection");
    } catch (e) {
      throw Exception("Something went wrong,Please try again");
    } finally {
      _isSending = false;
    }
  }

  @override
  Future<void> onDestroy(
      DateTime timestamp,
      bool isTimeout,
      ) async {
    print("Tracking Stopped");
  }

  @override
  void onNotificationPressed() {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationDismissed() {}
}