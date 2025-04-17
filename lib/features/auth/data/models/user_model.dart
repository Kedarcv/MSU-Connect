import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String studentId;
  final String program;
  final String bio;
  final String phone;
  final String address;
  final String? profilePicture;
  final String? profileImageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.studentId,
    required this.program,
    required this.bio,
    required this.phone,
    required this.address,
    this.profilePicture,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      studentId: json['studentId'] ?? '',
      program: json['program'] ?? '',
      bio: json['bio'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      profilePicture: json['profilePicture'],
      profileImageUrl: json['profileImageUrl'],
      createdAt: json['createdAt'] ?? Timestamp.now(),
      updatedAt: json['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'studentId': studentId,
      'program': program,
      'bio': bio,
      'phone': phone,
      'address': address,
      'profilePicture': profilePicture,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? studentId,
    String? program,
    String? bio,
    String? phone,
    String? address,
    String? profilePicture,
    String? profileImageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      studentId: studentId ?? this.studentId,
      program: program ?? this.program,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}