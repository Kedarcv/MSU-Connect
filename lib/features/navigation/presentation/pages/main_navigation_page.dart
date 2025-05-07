import 'package:flutter/material.dart';
import 'package:msu_connect/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:msu_connect/features/profile/presentation/pages/profile_page.dart';
import 'package:msu_connect/features/settings/presentation/pages/settings_page.dart';
import 'package:msu_connect/features/maps/presentation/pages/map_page.dart';
import 'package:msu_connect/features/classroom/presentation/pages/classroom_page.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';

class MainNavigationPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  
  const MainNavigationPage({super.key, this.userData});
  
  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    
    // Create a non-nullable map by using an empty map as fallback
    final userData = widget.userData ?? {};
    
    _pages = [
      DashboardPage(userData: userData),
      const MapPage(),
      const ClassroomPage(),
      ProfilePage(userData: userData),
      const SettingsPage()
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
      ),
      drawer: AppSidebar(userData: {},),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.school), label: 'Classroom'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Map';
      case 2: return 'Classroom';
      case 3: return 'AI Assistant';
      case 4: return 'Profile';
      case 5: return 'Settings';
      default: return 'MSU Connect';
    }
  }}
