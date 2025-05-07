import 'package:flutter/material.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/services/timetable_service.dart';
import 'package:msu_connect/features/timetable/domain/models/class_info.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
  final TimetableService _timetableService = TimetableService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  Map<String, List<ClassInfo>> _timetableData = {};
  
  @override
  void initState() {
    super.initState();
    final today = DateTime.now().weekday;
    final initialIndex = (today > 5) ? 0 : today - 1;
    _tabController = TabController(
      length: _weekdays.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    
    _loadTimetableData();
    
    // Listen for timetable updates
    _timetableService.timetableStream.listen((updatedData) {
      if (mounted) {
        setState(() {
          _timetableData = updatedData;
          _isLoading = false;
        });
      }
    });
    
    // Listen for auth state changes
    _auth.authStateChanges().listen((User? user) {
      if (user != null && mounted) {
        // User logged in, load their timetable
        _loadTimetableData();
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadTimetableData() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to view your timetable')),
      );
      setState(() {
        _isLoading = false;
        _timetableData = {};
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Initialize with the current user's ID to load their specific timetable
      await _timetableService.initialize(userId: _auth.currentUser!.uid);
      
      if (mounted) {
        setState(() {
          _timetableData = _timetableService.timetableData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading timetable: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _weekdays.map((day) => Tab(text: day)).toList(),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTimetableData,
            tooltip: 'Refresh timetable',
          ),
        ],
      ),
      body: _auth.currentUser == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Please log in to view your timetable'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to login page or show login dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.msuMaroon,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: _weekdays.map((day) => _buildDaySchedule(day)).toList(),
                ),
      floatingActionButton: _auth.currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddClassDialog(context),
              backgroundColor: AppTheme.msuMaroon,
              child: const Icon(Icons.add, color: Colors.white),
            ),
    );
  }

  Widget _buildDaySchedule(String day) {
    final classes = _timetableData[day] ?? [];
    
    return classes.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No classes scheduled for this day'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showAddClassDialog(context, preselectedDay: day),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.msuMaroon,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Class'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadTimetableData,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: classes.length,
              itemBuilder: (context, index) {
                final classInfo = classes[index];
                return Dismissible(
                  key: Key('${day}_${index}_${classInfo.subject}'),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Deletion'),
                          content: Text('Are you sure you want to remove ${classInfo.subject}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    _timetableService.removeClass(day, index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${classInfo.subject} removed')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(classInfo.colorValue),
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          classInfo.subject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16),
                                const SizedBox(width: 4),
                                Text(classInfo.time),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 4),
                                Text(classInfo.location),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 16),
                                const SizedBox(width: 4),
                                Text(classInfo.lecturer),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showEditClassDialog(context, day, index, classInfo),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _showAddClassDialog(BuildContext context, {String? preselectedDay}) {
    final formKey = GlobalKey<FormState>();
    String selectedDay = preselectedDay ?? _weekdays[_tabController.index];
    String subject = '';
    String time = '';
    String location = '';
    String lecturer = '';
    Color selectedColor = Colors.blue;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Class'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day'),
                  items: _weekdays.map((day) => DropdownMenuItem(
                    value: day,
                    child: Text(day),
                  )).toList(),
                  onChanged: (value) {
                    selectedDay = value!;
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => subject = value!,
                ),
                                TextFormField(
                  decoration: const InputDecoration(labelText: 'Time (e.g. 9:00 AM - 10:30 AM)'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => time = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => location = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Lecturer'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => lecturer = value!,
                ),
                const SizedBox(height: 16),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.amber,
                    Colors.red,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        selectedColor = color;
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor.value == color.value ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                final newClass = ClassInfo(
                  subject: subject,
                  time: time,
                  location: location,
                  lecturer: lecturer,
                  colorValue: selectedColor.value,
                );
                
                // Add the class to the timetable
                _timetableService.addClass(selectedDay, newClass);
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$subject added to $selectedDay')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditClassDialog(BuildContext context, String day, int index, ClassInfo classInfo) {
    final formKey = GlobalKey<FormState>();
    String subject = classInfo.subject;
    String time = classInfo.time;
    String location = classInfo.location;
    String lecturer = classInfo.lecturer;
    Color selectedColor = Color(classInfo.colorValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Class'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: subject,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => subject = value!,
                ),
                TextFormField(
                  initialValue: time,
                  decoration: const InputDecoration(labelText: 'Time'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => time = value!,
                ),
                TextFormField(
                  initialValue: location,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => location = value!,
                ),
                TextFormField(
                  initialValue: lecturer,
                  decoration: const InputDecoration(labelText: 'Lecturer'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => lecturer = value!,
                ),
                const SizedBox(height: 16),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Colors.blue,
                    Colors.green,
                    Colors.orange,
                    Colors.purple,
                    Colors.teal,
                    Colors.amber,
                    Colors.red,
                    Colors.indigo,
                  ].map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor.value == color.value ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                
                final updatedClass = ClassInfo(
                  subject: subject,
                  time: time,
                  location: location,
                  lecturer: lecturer,
                  colorValue: selectedColor.value,
                );
                
                // Update the class in the timetable
                final updatedTimetable = Map<String, List<ClassInfo>>.from(_timetableData);
                if (updatedTimetable.containsKey(day) && index >= 0 && index < updatedTimetable[day]!.length) {
                  updatedTimetable[day]![index] = updatedClass;
                  _timetableService.updateTimetable(updatedTimetable);
                }
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$subject updated')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
