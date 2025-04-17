import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'Assignment Due',
      'message': 'Database Systems assignment due tomorrow at 11:59 PM',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'type': 'academic',
    },
    {
      'id': '2',
      'title': 'Campus Event',
      'message': 'Tech Expo happening this weekend at the Student Center',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'type': 'event',
    },
    {
      'id': '3',
      'title': 'Library Notice',
      'message': 'Your borrowed book "Data Structures" is due in 3 days',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': false,
      'type': 'library',
    },
    {
      'id': '4',
      'title': 'Exam Schedule',
      'message': 'Final exam schedule has been published',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'type': 'academic',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification['isRead'] = true;
                }
              });
            },
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification['id']),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification dismissed')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: _getNotificationIcon(notification['type']),
                      title: Text(
                        notification['title'],
                        style: TextStyle(
                          fontWeight: notification['isRead']
                              ? FontWeight.normal
                              : FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(notification['message']),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(notification['time']),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: notification['isRead']
                          ? null
                          : Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.msuMaroon,
                              ),
                            ),
                      onTap: () {
                        setState(() {
                          notification['isRead'] = true;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'academic':
        return CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.school, color: Colors.blue[800]),
        );
      case 'event':
        return CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.event, color: Colors.green[800]),
        );
      case 'library':
        return CircleAvatar(
          backgroundColor: Colors.amber[100],
          child: Icon(Icons.book, color: Colors.amber[800]),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(Icons.notifications, color: Colors.grey[800]),
        );
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}