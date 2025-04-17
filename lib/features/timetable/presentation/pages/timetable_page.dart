import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  
  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    final initialIndex = (today > 5) ? 0 : today - 1;
    _tabController = TabController(
      length: _weekdays.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _weekdays.map((day) => Tab(text: day)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _weekdays.map((day) => _buildDaySchedule(day)).toList(),
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    // Sample schedule data
    final classes = _getSampleClasses(day);
    
    return classes.isEmpty
        ? const Center(child: Text('No classes scheduled'))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final classInfo = classes[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: classInfo['color'],
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      classInfo['subject'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16),
                            const SizedBox(width: 4),
                            Text(classInfo['time']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16),
                            const SizedBox(width: 4),
                            Text(classInfo['location']),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16),
                            const SizedBox(width: 4),
                            Text(classInfo['lecturer']),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  List<Map<String, dynamic>> _getSampleClasses(String day) {
    final Map<String, List<Map<String, dynamic>>> schedule = {
      'Monday': [
        {
          'subject': 'Database Systems',
          'time': '09:00 AM - 11:00 AM',
          'location': 'Room 2.1',
          'lecturer': 'Dr. Smith',
          'color': Colors.blue,
        },
        {
          'subject': 'Computer Networks',
          'time': '01:00 PM - 03:00 PM',
          'location': 'Lab 3',
          'lecturer': 'Prof. Johnson',
          'color': Colors.green,
        },
      ],
      'Tuesday': [
        {
          'subject': 'Software Engineering',
          'time': '10:00 AM - 12:00 PM',
          'location': 'Room 3.2',
          'lecturer': 'Dr. Williams',
          'color': Colors.orange,
        },
      ],
      'Wednesday': [
        {
          'subject': 'Artificial Intelligence',
          'time': '09:00 AM - 11:00 AM',
          'location': 'Lab 5',
          'lecturer': 'Dr. Brown',
          'color': Colors.purple,
        },
      ],
      'Thursday': [
        {
          'subject': 'Web Development',
          'time': '11:00 AM - 01:00 PM',
          'location': 'Lab 2',
          'lecturer': 'Dr. Wilson',
          'color': Colors.teal,
        },
      ],
      'Friday': [
        {
          'subject': 'Project Management',
          'time': '09:00 AM - 11:00 AM',
          'location': 'Room 4.1',
          'lecturer': 'Prof. Taylor',
          'color': Colors.amber,
        },
      ],
    };
    
    return schedule[day] ?? [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
