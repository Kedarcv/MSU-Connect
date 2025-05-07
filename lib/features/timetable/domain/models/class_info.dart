class ClassInfo {
  final String subject;
  final String time;
  final String location;
  final String lecturer;
  final int colorValue;

  ClassInfo({
    required this.subject,
    required this.time,
    required this.location,
    required this.lecturer,
    required this.colorValue,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      subject: json['course_name'] ?? '',
      time: '${json['start_time'] ?? ''} - ${json['end_time'] ?? ''}',
      location: json['location'] ?? '',
      lecturer: json['course_code'] ?? '',
      colorValue: json['color_value'] ?? 0xFF2196F3, // Default blue
    );
  }

  Map<String, dynamic> toJson() {
    final timeParts = time.split(' - ');
    return {
      'course_name': subject,
      'course_code': lecturer,
      'start_time': timeParts.isNotEmpty ? timeParts[0] : '',
      'end_time': timeParts.length > 1 ? timeParts[1] : '',
      'location': location,
      'color_value': colorValue,
    };
  }

  static Map<String, List<ClassInfo>> fromMap(classData) {
    return {};
  }}