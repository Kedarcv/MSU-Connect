import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventModel {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // 'academic', 'event', 'deadline'
  final String? location;
  final bool isAllDay;
  final List<String>? attachments;
  final Map<String, dynamic>? reminders;
  final String createdBy;
  final DateTime createdAt;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.location,
    required this.isAllDay,
    this.attachments,
    this.reminders,
    required this.createdBy,
    required this.createdAt,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      type: json['type'] as String,
      location: json['location'] as String?,
      isAllDay: json['isAllDay'] as bool,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      reminders: json['reminders'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'type': type,
      'location': location,
      'isAllDay': isAllDay,
      'attachments': attachments,
      'reminders': reminders,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  CalendarEventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? location,
    bool? isAllDay,
    List<String>? attachments,
    Map<String, dynamic>? reminders,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return CalendarEventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      location: location ?? this.location,
      isAllDay: isAllDay ?? this.isAllDay,
      attachments: attachments ?? this.attachments,
      reminders: reminders ?? this.reminders,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}