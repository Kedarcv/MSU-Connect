import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:msu_connect/core/theme/splash_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msu_connect/core/models/firebase_options.dart';
import 'package:msu_connect/features/maps/presentation/pages/map_page.dart';
import 'package:msu_connect/features/settings/presentation/pages/settings_page.dart';
import 'package:msu_connect/screens/auth/login_screen.dart';
import 'package:msu_connect/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/screens/study_assistant_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MSU Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/': (context) => LoginScreen(),
        '/dashboard': (context) => DashboardPage(),
        '/profile': (context) => ProfilePage(),
        '/splash': (context) => SplashScreen(),
        '/settings': (context) => SettingsPage(),
        '/ai': (context) => StudyAssistantScreen(),
        '/map': (context) => MapPage(),
      },
    );
  }
}