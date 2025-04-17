import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  final List<Map<String, dynamic>> _courses = [
    {
      'id': '1',
      'code': 'CS301',
      'title': 'Database Systems',
      'instructor': 'Dr. Smith',
      'color': Colors.blue,
      'progress': 0.75,
    },
    {
      'id': '2',
      'code': 'CS302',
      'title': 'Software Engineering',
      'instructor': 'Dr. Williams',
      'color': Colors.orange,
      'progress': 0.6,
    },
    {
      'id': '3',
      'code': 'CS303',
      'title': 'Artificial Intelligence',
      'instructor': 'Dr. Brown',
      'color': Colors.purple,
      'progress': 0.4,
    },
    {
      'id': '4',
      'code': 'CS304',
      'title': 'Web Development',
      'instructor': 'Dr. Wilson',
      'color': Colors.teal,
      'progress': 0.8,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Classroom'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Courses',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._courses.map((course) => _buildCourseCard(course)),
          const SizedBox(height: 24),
          const Text(
            'Upcoming Deadlines',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDeadlineCard(
            'Database Systems',
            'Assignment 3: SQL Queries',
            DateTime.now().add(const Duration(days: 2)),
          ),
          _buildDeadlineCard(
            'Software Engineering',
            'Project Milestone 2',
            DateTime.now().add(const Duration(days: 5)),
          ),
          _buildDeadlineCard(
            'Artificial Intelligence',
            'Quiz on Neural Networks',
            DateTime.now().add(const Duration(days: 7)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        onPressed: () {
          // Join a class
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Join a Class'),
              content: TextField(
                decoration: const InputDecoration(
                  labelText: 'Enter Class Code',
                  hintText: 'e.g., ABC123',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Joining class...'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.msuMaroon,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Join'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to course details
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening ${course['title']}'),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: course['color'],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      course['code'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                course['title'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Instructor: ${course['instructor']}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: course['progress'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(course['color']),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(course['progress'] * 100).toInt()}%',
                    style: TextStyle(
                      color: course['color'],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(Icons.assignment, 'Assignments'),
                  _buildActionButton(Icons.book, 'Materials'),
                  _buildActionButton(Icons.people, 'Discussions'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.msuMaroon),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildDeadlineCard(String course, String assignment, DateTime dueDate) {
    final daysLeft = dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUrgent ? Colors.red[100] : Colors.grey[200],
          child: Icon(
            Icons.assignment,
            color: isUrgent ? Colors.red : Colors.grey[700],
          ),
        ),
        title: Text(assignment),
        subtitle: Text(course),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Due in $daysLeft days',
              style: TextStyle(
                color: isUrgent ? Colors.red : Colors.grey[700],
                fontWeight: isUrgent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            Text(
              '${dueDate.day}/${dueDate.month}/${dueDate.year}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
