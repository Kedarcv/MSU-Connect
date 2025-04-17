import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:msu_connect/features/profile/data/models/achievement_model.dart';
import 'package:msu_connect/features/profile/data/models/academic_progress_model.dart';

class ProfileService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Achievement Methods
  static Future<List<AchievementModel>> getUserAchievements(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AchievementModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load achievements: $e');
    }
  }

  static Future<void> addAchievement(
    String userId,
    AchievementModel achievement,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .set(achievement.toJson());
    } catch (e) {
      throw Exception('Failed to add achievement: $e');
    }
  }

  static Future<void> updateAchievement(
    String userId,
    AchievementModel achievement,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievement.id)
          .update(achievement.toJson());
    } catch (e) {
      throw Exception('Failed to update achievement: $e');
    }
  }

  static Future<void> deleteAchievement(
    String userId,
    String achievementId,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete achievement: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  static Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
      } else {
        throw Exception('No user logged in');
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final ref = _storage.ref().child('profile_images/${user.uid}');
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user profile with new image URL
      await updateProfile({'profileImageUrl': downloadUrl});

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  static Future<void> updateUserData({
    required String name,
    required String email,
    required String studentId,
    required String program,
  }) async {
    try {
      await updateProfile({
        'name': name,
        'email': email,
        'studentId': studentId,
        'program': program,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update user data: $e');
    }
  }

  // Academic Progress Methods
  static Future<AcademicProgressModel?> getAcademicProgress(String studentId) async {
    try {
      final doc = await _firestore
          .collection('academic_progress')
          .doc(studentId)
          .get();

      if (doc.exists && doc.data() != null) {
        return AcademicProgressModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to load academic progress: $e');
    }
  }

  static Future<void> updateAcademicProgress(
    AcademicProgressModel academicProgress,
  ) async {
    try {
      await _firestore
          .collection('academic_progress')
          .doc(academicProgress.studentId)
          .set(academicProgress.toJson());
    } catch (e) {
      throw Exception('Failed to update academic progress: $e');
    }
  }

  static Future<List<CourseHistory>> getEnrolledCourses(String studentId) async {
    try {
      final doc = await _firestore
          .collection('academic_progress')
          .doc(studentId)
          .get();

      if (doc.exists && doc.data() != null) {
        final progress = AcademicProgressModel.fromJson(doc.data()!);
        return progress.courseHistory;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load enrolled courses: $e');
    }
  }
}