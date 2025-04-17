import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'academic', 'award', 'certification'
  final DateTime date;
  final String? imageUrl;
  final String? documentUrl;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    this.imageUrl,
    this.documentUrl,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      date: (json['date'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'] as String?,
      documentUrl: json['documentUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'date': Timestamp.fromDate(date),
      'imageUrl': imageUrl,
      'documentUrl': documentUrl,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? date,
    String? imageUrl,
    String? documentUrl,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      imageUrl: imageUrl ?? this.imageUrl,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }
}