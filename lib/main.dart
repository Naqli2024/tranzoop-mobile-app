import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_foreground_task/models/foreground_task_options.dart';
import 'package:provider/provider.dart';
import 'package:bizoop_driver_app/core/app_colors.dart';
import 'package:bizoop_driver_app/core/utils/shared_preferences.dart';
import 'package:bizoop_driver_app/features/auth/view/splash_screen.dart';
import 'package:bizoop_driver_app/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/fuel_viewmodel.dart';
import 'package:bizoop_driver_app/features/bills/viewmodel/trip_expenses_viewmodel.dart';
import 'package:bizoop_driver_app/features/homeScreen/viewmodel/home_viewmodel.dart';
import 'package:bizoop_driver_app/features/inspection/viewmodel/inspection_viewmodel.dart';
import 'package:bizoop_driver_app/features/loading_unloading/viewmodal/loading_unloading_viewmodel.dart';
import 'package:bizoop_driver_app/features/tripDocuments/viewmodel/trip_document_viewmodel.dart';
import 'package:bizoop_driver_app/features/trips/viewmodel/trip_viewmodel.dart';
import 'package:bizoop_driver_app/features/weight_bridge/viewmodel/weight_bridge_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Use it Playstore Deployment
  // await dotenv.load(fileName: ".env");
  await dotenv.load(fileName: "assets/config.env");
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'tracking_channel',
      channelName: 'Tracking',
      channelDescription: 'Driver Location Tracking',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(300000), // 5 Minutes
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
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
      ChangeNotifierProvider(create: (_) => TripExpenseViewModel()),
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
