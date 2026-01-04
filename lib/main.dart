import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_fast_tracker/data/local/fasting_session_adapter.dart';
import 'package:simple_fast_tracker/presentation/pages/history/history_controller.dart';
import 'package:toastification/toastification.dart';

import 'core/constants/app_constants.dart';
import 'core/services/encryption_service.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(FastingSessionAdapter());
  await Hive.openBox('fasting_sessions');
  
  // Initialize Services
  await Get.putAsync(() => SupabaseService().init());
  
  final encryption = Get.put(EncryptionService());
  encryption.init(AppConstants.encryptionKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: GetMaterialApp(
        navigatorKey: Get.key,
        title: 'Simple Fast Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialBinding: BindingsBuilder(() {  
          Get.put(AuthController());
          Get.put(HistoryController());
          
        }),
        home: const DashboardPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
