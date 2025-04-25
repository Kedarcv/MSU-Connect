import 'dart:async';
import 'package:msu_connect/features/services/ai_service.dart';
import 'package:msu_connect/features/timetable/domain/models/class_info.dart';

class TimetableService {
  final AIService _aiService = AIService();
  final _timetableStreamController = StreamController<Map<String, List<ClassInfo>>>.broadcast();
  Map<String, List<ClassInfo>> _timetableData = {};

  Stream<Map<String, List<ClassInfo>>> get timetableStream => _timetableStreamController.stream;
  Map<String, List<ClassInfo>> get timetableData => _timetableData;

  Future<void> initialize() async {
    final rawData = await loadTimetable();
    _timetableData = _convertToClassInfoMap(rawData);
    _timetableStreamController.add(_timetableData);
  }

  Map<String, List<ClassInfo>> _convertToClassInfoMap(Map<String, dynamic> rawData) {
    final Map<String, List<ClassInfo>> result = {};
    
    for (final dayData in rawData['timetable'] as List) {
      final day = dayData['day'] as String;
      final courses = dayData['courses'] as List;
      
      result[day] = courses.map((course) => ClassInfo.fromJson(course)).toList();
    }
    
    return result;
  }

  Map<String, dynamic> _convertFromClassInfoMap(Map<String, List<ClassInfo>> classInfoMap) {
    final List<Map<String, dynamic>> timetableList = [];
    
    classInfoMap.forEach((day, classes) {
      timetableList.add({
        'day': day,
        'courses': classes.map((classInfo) => classInfo.toJson()).toList(),
      });
    });
    
    return {
      'degree_program': '',
      'timetable': timetableList,
    };
  }

  // Load timetable data
  Future<Map<String, dynamic>> loadTimetable() async {
    try {
      final timetable = await _aiService.loadTimetable();
      if (timetable != null) {
        return timetable;
      } else {
        // Return empty timetable structure if none exists
        return {
          'degree_program': '',
          'timetable': [
            for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
              {
                'day': day,
                'courses': [],
              }
          ]
        };
      }
    } catch (e) {
      throw Exception('Failed to load timetable: ${e.toString()}');
    }
  }

  // Save timetable data
  Future<String> saveTimetable(Map<String, dynamic> timetableData) async {
    return await _aiService.saveTimetable(timetableData);
  }

  // Add a class to the timetable
  Future<void> addClass(String day, ClassInfo classInfo) async {
    if (!_timetableData.containsKey(day)) {
      _timetableData[day] = [];
    }
    
    _timetableData[day]!.add(classInfo);
    await updateTimetable(_timetableData);
  }

  // Remove a class from the timetable
  Future<void> removeClass(String day, int index) async {
    if (_timetableData.containsKey(day) && index >= 0 && index < _timetableData[day]!.length) {
      _timetableData[day]!.removeAt(index);
      await updateTimetable(_timetableData);
    }
  }

  // Update the entire timetable
  Future<void> updateTimetable(Map<String, List<ClassInfo>> newTimetable) async {
    _timetableData = newTimetable;
    final rawData = _convertFromClassInfoMap(newTimetable);
    await saveTimetable(rawData);
    _timetableStreamController.add(_timetableData);
  }

  void dispose() {
    _timetableStreamController.close();
  }

  Future<Map<String, dynamic>> addCourse(
    String day,
    String courseName,
    String courseCode,
    String startTime,
    String endTime,
    String location,
  ) async {
    final timetable = await loadTimetable();
    
    final dayIndex = (timetable['timetable'] as List).indexWhere(
      (dayData) => dayData['day'] == day
    );
    
    if (dayIndex >= 0) {
      final newCourse = {
        'course_name': courseName,
        'course_code': courseCode,
        'start_time': startTime,
        'end_time': endTime,
        'location': location,
      };
      
      (timetable['timetable'][dayIndex]['courses'] as List).add(newCourse);
      await saveTimetable(timetable);
    }
    
    return timetable;
  }

  editCourse(String day, int courseIndex, String text, String text2, String text3, String text4, String text5) {}

  removeCourse(String day, int courseIndex) {}

  updateDegreeProgram(String text) {}
}