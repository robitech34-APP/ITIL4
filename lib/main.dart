import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // REQUIRED for SystemChrome
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/home_screen.dart';
import 'models/exam_result.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  Directory appDocDir = Platform.isWindows
      ? Directory('C:/MYApps/ITIL/hive_data')
      : await getApplicationDocumentsDirectory();

  if (!appDocDir.existsSync()) {
    appDocDir.createSync(recursive: true);
  }

  await Hive.initFlutter(appDocDir.path);
  Hive.registerAdapter(ExamResultAdapter());
  await Hive.openBox<ExamResult>('exam_results');

  // Initialize Google Mobile Ads
  await MobileAds.instance.initialize();

  // ------------------------------------------------------------------
  // 🚀 EDGE-TO-EDGE FIX: Android 15 Compatibility
  // ------------------------------------------------------------------
  // 1. Enable Edge-to-Edge Mode (Draw UI under system bars)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // 2. Set Status and Navigation Bar colors to transparent
  // This allows the UI to show through the system bars, handling the default edge-to-edge setting.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,

      // Ensure icons are visible based on your app's light background
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  // ------------------------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITIL 4 Exam Prep',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const HomeScreen(), // Don't forget to wrap the content of HomeScreen with SafeArea!
    );
  }
}