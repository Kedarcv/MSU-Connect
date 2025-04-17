import 'package:cloud_firestore/cloud_firestore.dart';

class AcademicProgressModel {
  final String studentId;
  final double cumulativeGpa;
  final int totalCredits;
  final int creditsCompleted;
  final List<CourseHistory> courseHistory;
  final Map<String, double> semesterGpa;
  final DateTime lastUpdated;

  AcademicProgressModel({
    required this.studentId,
    required this.cumulativeGpa,
    required this.totalCredits,
    required this.creditsCompleted,
    required this.courseHistory,
    required this.semesterGpa,
    required this.lastUpdated,
  });

  factory AcademicProgressModel.fromJson(Map<String, dynamic> json) {
    return AcademicProgressModel(
      studentId: json['studentId'] as String,
      cumulativeGpa: (json['cumulativeGpa'] as num).toDouble(),
      totalCredits: json['totalCredits'] as int,
      creditsCompleted: json['creditsCompleted'] as int,
      courseHistory: (json['courseHistory'] as List)
          .map((course) => CourseHistory.fromJson(course))
          .toList(),
      semesterGpa: Map<String, double>.from(json['semesterGpa'] as Map),
      lastUpdated: (json['lastUpdated'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'cumulativeGpa': cumulativeGpa,
      'totalCredits': totalCredits,
      'creditsCompleted': creditsCompleted,
      'courseHistory': courseHistory.map((course) => course.toJson()).toList(),
      'semesterGpa': semesterGpa,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}

class CourseHistory {
  final String courseId;
  final String courseName;
  final String semester;
  final int credits;
  final String grade;
  final DateTime completionDate;

  CourseHistory({
    required this.courseId,
    required this.courseName,
    required this.semester,
    required this.credits,
    required this.grade,
    required this.completionDate,
  });

  factory CourseHistory.fromJson(Map<String, dynamic> json) {
    return CourseHistory(
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      semester: json['semester'] as String,
      credits: json['credits'] as int,
      grade: json['grade'] as String,
      completionDate: (json['completionDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'semester': semester,
      'credits': credits,
      'grade': grade,
      'completionDate': Timestamp.fromDate(completionDate),
    };
  }
}