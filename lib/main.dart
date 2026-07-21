import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tranzoop_mobile_app/core/app_colors.dart';
import 'package:tranzoop_mobile_app/core/utils/shared_preferences.dart';
import 'package:tranzoop_mobile_app/features/auth/view/splash_screen.dart';
import 'package:tranzoop_mobile_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/fuel_entry/viewmodel/fuel_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/inspection/viewmodel/inspection_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/loading_unloading/viewmodal/loading_unloading_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/tripDocuments/viewmodel/trip_document_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:tranzoop_mobile_app/features/weight_bridge/viewmodel/weight_bridge_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [
      SystemUiOverlay.top,
    ],
  );
  final SharedPrefService pref = SharedPrefService();
  final bool isLoggedIn = await pref.isLoggedIn();
  runApp(
    MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ChangeNotifierProvider(create: (_) => InspectionViewModel()),
      ChangeNotifierProvider(create: (_) => LoadingUnloadingViewmodel()),
      ChangeNotifierProvider(create: (_) => TripViewModel()),
      ChangeNotifierProvider(create: (_) => WeighbridgeViewModel()),
      ChangeNotifierProvider(create: (_) => FuelViewModel()),
      ChangeNotifierProvider(create: (_) => TripDocumentViewModel()),
    ],
    child: MyApp(isLoggedIn: isLoggedIn),
  ),);
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.btnColor,
        ),
      ),
      home: SplashScreen(isLoggedIn: isLoggedIn),
    );
  }
}
