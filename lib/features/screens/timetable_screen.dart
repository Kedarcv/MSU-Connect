import 'package:flutter/material.dart';
import 'package:msu_connect/features/services/timetable_service.dart';
import 'package:msu_connect/features/services/ai_service.dart';
import 'package:msu_connect/features/widgets/app_sidebar.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  final TimetableService _timetableService = TimetableService();
  final AIService _aiService = AIService();
  Map<String, dynamic> _timetableData = {'degree_program': '', 'timetable': []};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimetable();

    // Listen for timetable updates
    _timetableService.timetableStream.listen((updatedData) {
      // Convert from ClassInfo map to the raw format
      _loadTimetable();
    });
  }

  @override
  void dispose() {
    _timetableService.dispose();
    super.dispose();
  }

  Future<void> _loadTimetable() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final timetable = await _timetableService.loadTimetable();
      setState(() {
        _timetableData = timetable;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading timetable: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _importTimetableFromImage() async {
    try {
      final image = await _aiService.pickTimetableImage();
      if (image != null) {
        setState(() {
          _isLoading = true;
        });

        final extractedText = await _aiService.processTimetableImage(image);
        final degreeProgram = _timetableData['degree_program'] ?? '';
        final timetableData = await _aiService.createDigitalTimetable(
            extractedText, degreeProgram);

        await _timetableService.saveTimetable(timetableData);
        await _loadTimetable();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing timetable: ${e.toString()}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddCourseDialog(String day) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    final locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Course to $day'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
              TextField(
                controller: startTimeController,
                decoration:
                    const InputDecoration(labelText: 'Start Time (HH:MM)'),
              ),
              TextField(
                controller: endTimeController,
                decoration:
                    const InputDecoration(labelText: 'End Time (HH:MM)'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  startTimeController.text.isNotEmpty &&
                  endTimeController.text.isNotEmpty) {
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                try {
                  final updatedTimetable = await _timetableService.addCourse(
                    day,






                    nameController.text,
                    codeController.text,
                    startTimeController.text,
                    endTimeController.text,
                    locationController.text,
                  );                  
                  setState(() {
                    _timetableData = updatedTimetable;
                    _isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Course added successfully')),
                  );
                } catch (e) {
                  setState(() {
                    _isLoading = false;
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error adding course: ${e.toString()}')),
                  );
                }              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(
      String day, int courseIndex, Map<String, dynamic> course) {
    final nameController = TextEditingController(text: course['course_name']);
    final codeController = TextEditingController(text: course['course_code']);
    final startTimeController =
        TextEditingController(text: course['start_time']);
    final endTimeController = TextEditingController(text: course['end_time']);
    final locationController = TextEditingController(text: course['location']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Course on $day'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Course Code'),
              ),
              TextField(
                controller: startTimeController,
                decoration:
                    const InputDecoration(labelText: 'Start Time (HH:MM)'),
              ),
              TextField(
                controller: endTimeController,
                decoration:
                    const InputDecoration(labelText: 'End Time (HH:MM)'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isLoading = true;
              });

              try {
                final updatedTimetable = await TimetableService().editCourse(
                  day,
                  courseIndex,
                  nameController.text,
                  codeController.text,
                  startTimeController.text,
                  endTimeController.text,
                  locationController.text,
                );
                setState(() {
                  _timetableData = updatedTimetable;
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course updated successfully')),
                );
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error updating course: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              try {
                final updatedTimetable =
                    await _timetableService.removeCourse(day, courseIndex);

                setState(() {
                  _timetableData = updatedTimetable;
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course removed successfully')),
                );
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error removing course: ${e.toString()}')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDegreeProgramDialog() {
    final controller =
        TextEditingController(text: _timetableData['degree_program']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Degree Program'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Degree Program'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              setState(() {
                _isLoading = true;
              });

              try {
                final updatedTimetable = await _timetableService
                    .updateDegreeProgram(controller.text);

                setState(() {
                  _timetableData = updatedTimetable;
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Degree program updated successfully')),
                );
              } catch (e) {
                setState(() {
                  _isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Error updating degree program: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditDegreeProgramDialog,
            tooltip: 'Edit Degree Program',
          ),
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: _importTimetableFromImage,
            tooltip: 'Import from Image',
          ),
        ],
      ),
      drawer: AppSidebar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        'Degree Program: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Expanded(
                        child: Text(
                          _timetableData['degree_program'] ?? 'Not set',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: (_timetableData['timetable'] as List).length,
                    itemBuilder: (context, index) {
                      final day = _timetableData['timetable'][index];
                      final courses = day['courses'] as List;

                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ExpansionTile(
                          title: Text(
                            day['day'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            ...courses.asMap().entries.map((entry) {
                              final courseIndex = entry.key;
                              final course = entry.value;

                              return ListTile(
                                title: Text(course['course_name']),
                                subtitle: Text(
                                  '${course['course_code']} | ${course['start_time']} - ${course['end_time']} | ${course['location']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _showEditCourseDialog(
                                      day['day'], courseIndex, course),
                                ),
                              );
                            }),
                            ListTile(
                              leading: const Icon(Icons.add),
                              title: const Text('Add Course'),
                              onTap: () => _showAddCourseDialog(day['day']),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}