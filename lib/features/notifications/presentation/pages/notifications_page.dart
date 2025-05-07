import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'dart:convert';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _setupFirebaseMessaging();
    _loadNotifications();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.notification.status;
    setState(() {
      _hasPermission = status.isGranted;
    });
    
    if (!_hasPermission) {
      _requestPermissions();
    }
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.notification.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _setupFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;
    
    // Get FCM token for this device
    final token = await messaging.getToken();
    debugPrint('FCM Token: $token');
    
    // Handle incoming messages when app is in foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        _addNotification(
          NotificationItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: notification.title ?? 'New Notification',
            message: notification.body ?? '',
            time: DateTime.now(),
            type: _getNotificationType(message.data),
            isRead: false,
          ),
        );
      }
    });
    
    // Handle notification clicks when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Navigate to specific page based on notification data if needed
      debugPrint('Notification clicked: ${message.data}');
    });
  }

  String _getNotificationType(Map<String, dynamic> data) {
    return data['type'] ?? 'general';
  }

  Future<void> _loadNotifications() async {
    // Simulate loading notifications from a backend
    await Future.delayed(const Duration(seconds: 1));
    
    // In a real app, you would fetch notifications from your backend
    setState(() {
      _isLoading = false;
    });
  }

  void _addNotification(NotificationItem notification) {
    setState(() {
      _notifications.insert(0, notification);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          if (!_hasPermission)
            IconButton(
              icon: const Icon(Icons.notifications_off),
              onPressed: _requestPermissions,
              tooltip: 'Enable notifications',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.msuMaroon))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return Dismissible(
                      key: Key(notification.id),
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
                          const SnackBar(content: Text('Notification removed')),
                        );
                      },
                      child: _buildNotificationCard(notification),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll receive updates about your schedule,\nalerts, and messages here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          if (!_hasPermission) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: const Text('Enable Notifications'),
              onPressed: _requestPermissions,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.msuMaroon,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: AppTheme.msuMaroon.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            notification.isRead = true;
          });
          // Handle notification tap - could navigate to relevant screen
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getNotificationIcon(notification.type),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.msuMaroon,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.message,
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(notification.time),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'schedule':
        return CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.calendar_today, color: Colors.blue[800], size: 20),
        );
      case 'alert':
        return CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(Icons.warning, color: Colors.red[800], size: 20),
        );
      case 'ai':
        return CircleAvatar(
          backgroundColor: Colors.purple[100],
          child: Icon(Icons.psychology, color: Colors.purple[800], size: 20),
        );
      case 'message':
        return CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.message, color: Colors.green[800], size: 20),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.notifications, color: Colors.grey[800], size: 20),
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

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final String type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}