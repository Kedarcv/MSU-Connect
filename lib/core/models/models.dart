import 'package:equatable/equatable.dart';

// Event Model for Campus Events Calendar
class Event extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String organizer;
  final List<String> attendees;
  final bool isNotificationEnabled;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizer,
    this.attendees = const [],
    this.isNotificationEnabled = true,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        location,
        organizer,
        attendees,
        isNotificationEnabled,
      ];
}

// Forum Post Model for Student Forum
class ForumPost extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final List<Comment> comments;
  final List<String> tags;
  final int likes;
  final bool isAnnouncement;

  const ForumPost({
    required this.id,
    required this.title,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.comments = const [],
    this.tags = const [],
    this.likes = 0,
    this.isAnnouncement = false,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        authorId,
        authorName,
        createdAt,
        comments,
        tags,
        likes,
        isAnnouncement,
      ];
}

// Comment Model for Forum Posts
class Comment extends Equatable {
  final String id;
  final String content;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final int likes;

  const Comment({
    required this.id,
    required this.content,
    required this.authorId,
    required this.authorName,
    required this.createdAt,
    this.likes = 0,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        authorId,
        authorName,
        createdAt,
        likes,
      ];
}

// Resource Model for Campus Resources Directory
class Resource extends Equatable {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final Map<String, String> contactInfo;
  final List<String> operatingHours;
  final bool isAvailableOffline;

  const Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.contactInfo,
    required this.operatingHours,
    this.isAvailableOffline = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        category,
        location,
        contactInfo,
        operatingHours,
        isAvailableOffline,
      ];
}