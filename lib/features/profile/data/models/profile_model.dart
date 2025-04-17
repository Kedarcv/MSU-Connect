import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String major;
  final int graduationYear;
  final double gpa;
  final List<String> enrolledCourses;
  final List<AcademicAchievement> achievements;
  final Map<String, List<String>> completedCourses; // semester -> course list
  final DateTime lastUpdated;

  ProfileModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.major,
    required this.graduationYear,
    required this.gpa,
    required this.enrolledCourses,
    required this.achievements,
    required this.completedCourses,
    required this.lastUpdated,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      major: json['major'] as String,
      graduationYear: json['graduationYear'] as int,
      gpa: (json['gpa'] as num).toDouble(),
      enrolledCourses: List<String>.from(json['enrolledCourses'] ?? []),
      achievements: (json['achievements'] as List?)
          ?.map((e) => AcademicAchievement.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      completedCourses: Map<String, List<String>>.from(
        (json['completedCourses'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(
                key,
                List<String>.from(value as List),
              ),
            ) ??
            {},
      ),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'major': major,
      'graduationYear': graduationYear,
      'gpa': gpa,
      'enrolledCourses': enrolledCourses,
      'achievements': achievements.map((e) => e.toJson()).toList(),
      'completedCourses': completedCourses,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class AcademicAchievement {
  final String title;
  final String description;
  final DateTime dateEarned;
  final String? badgeUrl;

  AcademicAchievement({
    required this.title,
    required this.description,
    required this.dateEarned,
    this.badgeUrl,
  });

  factory AcademicAchievement.fromJson(Map<String, dynamic> json) {
    return AcademicAchievement(
      title: json['title'] as String,
      description: json['description'] as String,
      dateEarned: (json['dateEarned'] as Timestamp).toDate(),
      badgeUrl: json['badgeUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dateEarned': Timestamp.fromDate(dateEarned),
      'badgeUrl': badgeUrl,
    };
  }
}