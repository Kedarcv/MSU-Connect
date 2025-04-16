class UserModel {
  final String id;
  final String name;
  final String email;
  final String regNumber;
  final String degreeProgram;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.regNumber,
    required this.degreeProgram,
    this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      regNumber: json['reg_number'] ?? '',
      degreeProgram: json['degree_program'] ?? '',
      profilePicture: json['profile_picture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'reg_number': regNumber,
      'degree_program': degreeProgram,
      'profile_picture': profilePicture,
    };
  }
}