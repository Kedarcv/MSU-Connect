import 'package:equatable/equatable.dart';

class CampusEvent extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final String location;
  final String organizer;
  final String category;
  final bool isNotificationEnabled;
  final List<String> attendees;

  const CampusEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.organizer,
    required this.category,
    this.isNotificationEnabled = true,
    this.attendees = const [],
  });

  CampusEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    String? location,
    String? organizer,
    String? category,
    bool? isNotificationEnabled,
    List<String>? attendees,
  }) {
    return CampusEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      category: category ?? this.category,
      isNotificationEnabled: isNotificationEnabled ?? this.isNotificationEnabled,
      attendees: attendees ?? this.attendees,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'category': category,
      'isNotificationEnabled': isNotificationEnabled,
      'attendees': attendees,
    };
  }

  factory CampusEvent.fromJson(Map<String, dynamic> json) {
    return CampusEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      category: json['category'] as String,
      isNotificationEnabled: json['isNotificationEnabled'] as bool,
      attendees: List<String>.from(json['attendees'] as List),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startTime,
        endTime,
        location,
        organizer,
        category,
        isNotificationEnabled,
        attendees,
      ];
}