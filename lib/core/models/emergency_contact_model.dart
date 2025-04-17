import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String id;
  final String name;
  final String phoneNumber;
  final String department;
  final String location;
  final bool isAvailable24x7;
  final String? alternateNumber;
  final String? email;
  final Map<String, String> operatingHours;
  final int priority;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.location,
    required this.isAvailable24x7,
    this.alternateNumber,
    this.email,
    required this.operatingHours,
    required this.priority,
  });

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? department,
    String? location,
    bool? isAvailable24x7,
    String? alternateNumber,
    String? email,
    Map<String, String>? operatingHours,
    int? priority,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      department: department ?? this.department,
      location: location ?? this.location,
      isAvailable24x7: isAvailable24x7 ?? this.isAvailable24x7,
      alternateNumber: alternateNumber ?? this.alternateNumber,
      email: email ?? this.email,
      operatingHours: operatingHours ?? this.operatingHours,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'department': department,
      'location': location,
      'isAvailable24x7': isAvailable24x7,
      'alternateNumber': alternateNumber,
      'email': email,
      'operatingHours': operatingHours,
      'priority': priority,
    };
  }

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      department: json['department'] as String,
      location: json['location'] as String,
      isAvailable24x7: json['isAvailable24x7'] as bool,
      alternateNumber: json['alternateNumber'] as String?,
      email: json['email'] as String?,
      operatingHours: Map<String, String>.from(json['operatingHours'] as Map),
      priority: json['priority'] as int,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phoneNumber,
        department,
        location,
        isAvailable24x7,
        alternateNumber,
        email,
        operatingHours,
        priority,
      ];
}