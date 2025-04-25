import 'package:flutter/material.dart';
import 'package:msu_connect/features/services/timetable_service.dart';
import 'package:intl/intl.dart';

class DashboardTimetableWidget extends StatefulWidget {
  const DashboardTimetableWidget({super.key});

  @override
  _DashboardTimetableWidgetState createState() => _DashboardTimetableWidgetState();
}

class _DashboardTimetableWidgetState extends State<DashboardTimetableWidget> {
  final TimetableService _timetableService = TimetableService();
  Map<String, dynamic> _timetableData = {'degree_program': '', 'timetable': []};
  bool _isLoading = true;
  String _currentDay = '';

  @override
  void initState() {
    super.initState();
    _loadTimetable();
    _setCurrentDay();
  }

  void _setCurrentDay() {
    final now = DateTime.now();
    _currentDay = DateFormat('EEEE').format(now); // Gets the current day name (Monday, Tuesday, etc.)
  }

  Future<void> _loadTimetable() async {
    try {
      final timetable = await _timetableService.loadTimetable();
      if (mounted) {
        setState(() {
          _timetableData = timetable;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> _getTodaysCourses() {
    if (_timetableData['timetable'] == null) return [];
    
    final dayData = (_timetableData['timetable'] as List).firstWhere(
      (day) => day['day'] == _currentDay,
      orElse: () => {'courses': []},
    );
    
    return dayData['courses'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final todayCourses = _getTodaysCourses();

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule ($_currentDay)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/timetable');
                  },
                  child: const Text('View Full Timetable'),
                ),
              ],
            ),
          ),
          const Divider(),
          if (todayCourses.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No classes scheduled for today',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayCourses.length,
              itemBuilder: (context, index) {
                final course = todayCourses[index];
                return ListTile(
                  leading: const Icon(Icons.school),
                  title: Text(course['course_name']),
                  subtitle: Text(
                    '${course['start_time']} - ${course['end_time']} | ${course['location']}',
                  ),
                  trailing: Text(
                    course['course_code'],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}