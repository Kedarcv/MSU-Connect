import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:msu_connect/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/features/services/auth_service.dart';
import 'package:msu_connect/features/timetable/presentation/pages/timetable_page.dart';
import 'package:msu_connect/screens/auth/login_screen.dart';
import 'package:msu_connect/screens/study_assistant_screen.dart';
import 'package:provider/provider.dart';
import 'package:msu_connect/core/models/firebase_options.dart';
import 'package:msu_connect/features/screens/document_list_screen.dart';
import 'package:msu_connect/features/screens/document_upload_screen.dart';
import 'package:msu_connect/features/screens/ai_assistant_screen.dart';
import 'package:msu_connect/features/navigation/presentation/pages/main_navigation_page.dart';
// Fix the import path to match your actual file structure
import 'package:msu_connect/features/elearning/presentation/pages/elearning_page.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  } catch (e) {
    print('Initialization error: $e');
    // Provide a fallback to at least show something
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Failed to initialize app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthService(),
        ),
      ],
      child: MaterialApp(
        title: 'MSU Connect',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthenticationWrapper(), // Use home instead of initialRoute for simplicity
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final user = authService.currentUser;
            Map<String, dynamic> userData = {
              'displayName': user?.displayName ?? '',
              'email': user?.email ?? '',
              'uid': user?.uid ?? '',
              'program': '',
              'regNumber': '',
            };
            return DashboardPage(userData: userData);
          },
          '/timetable': (context) => const TimetablePage(),
          '/documents': (context) => const DocumentListScreen(),
          '/documents/upload': (context) => const DocumentUploadPage(),
          '/profile': (context) {
            final authService = Provider.of<AuthService>(context, listen: false);
            final user = authService.currentUser;
            Map<String, dynamic> userData = {
              'displayName': user?.displayName ?? '',
              'email': user?.email ?? '',
              'uid': user?.uid ?? '',
              'program': '',
              'regNumber': '',
            };
            return ProfilePage(userData: userData);
          },
          '/ai_assistant': (context) => const AIAssistantScreen(),
          '/main_navigation': (context) => const MainNavigationPage(),
          '/study_assistant': (context) => const StudyAssistantScreen(),
          '/logout': (context) => const LoginScreen(),
          '/elearning': (context) => const ElearningPage(), // Make sure this class name matches your actual class
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Add debug print to see what's happening
        print('Auth state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}');
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const MainNavigationPage();
        }
        
        // User is not logged in
        return const LoginScreen();
      },
    );
  }
}
