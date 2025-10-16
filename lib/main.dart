import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main_app.dart';
import 'screens/health_screen.dart';
import 'screens/history_screen.dart';
import 'screens/enhanced_life_records_screen.dart';
import 'screens/reminder_screen.dart';
import 'screens/daily_habits_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'utils/ui_performance_monitor.dart';

void main() {
  // 在debug模式下启动性能监控
  if (kDebugMode) {
    WidgetsFlutterBinding.ensureInitialized();
    UIPerformanceMonitor().startMonitoring();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Felo Camera',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFD84D)),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const MainApp(), // 临时修改：直接导航到MainApp进行测试
      debugShowCheckedModeBanner: false,
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile-setup': (context) => const ProfileSetupScreen(),
        '/home': (context) => const MainApp(),
        '/health': (context) => const HealthScreen(),
        '/history': (context) => const EnhancedLifeRecordsScreen(),
        '/reminder': (context) => const ReminderScreen(),
        '/life_records': (context) => const DailyHabitsScreen(),
      },
    );
  }
}
