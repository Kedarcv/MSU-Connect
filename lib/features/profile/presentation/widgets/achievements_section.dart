import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:msu_connect/features/profile/data/models/achievement_model.dart';
import 'package:msu_connect/features/profile/data/services/profile_service.dart';

class AchievementsSection extends StatefulWidget {
  final bool isEditing;
  final String userId;

  const AchievementsSection({
    super.key,
    required this.isEditing,
    required this.userId,
  });

  @override
  State<AchievementsSection> createState() => _AchievementsSectionState();
}

class _AchievementsSectionState extends State<AchievementsSection> {
  List<AchievementModel> _achievements = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      setState(() => _isLoading = true);
      final achievements = await ProfileService.getUserAchievements(widget.userId);
      setState(() {
        _achievements = achievements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load achievements: $e')),
      );
    }
  }

  Future<void> _addAchievement() async {
    final result = await showDialog<AchievementModel>(
      context: context,
      builder: (context) => const AchievementDialog(),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await ProfileService.addAchievement(widget.userId, result);
        await _loadAchievements();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add achievement: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editAchievement(AchievementModel achievement) async {
    final result = await showDialog<AchievementModel>(
      context: context,
      builder: (context) => AchievementDialog(achievement: achievement),
    );

    if (result != null) {
      try {
        setState(() => _isLoading = true);
        await ProfileService.updateAchievement(widget.userId, result);
        await _loadAchievements();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update achievement: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAchievement(String achievementId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Achievement'),
        content: const Text('Are you sure you want to delete this achievement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await ProfileService.deleteAchievement(widget.userId, achievementId);
        await _loadAchievements();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete achievement: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Academic Achievements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.isEditing)
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addAchievement,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_achievements.isEmpty)
          const Center(
            child: Text('No achievements added yet'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _achievements.length,
            itemBuilder: (context, index) {
              final achievement = _achievements[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(achievement.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(achievement.description),
                      Text(
                        DateFormat.yMMMd().format(achievement.date),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: widget.isEditing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editAchievement(achievement),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteAchievement(achievement.id),
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          ),
      ],
    );
  }
}

class AchievementDialog extends StatefulWidget {
  final AchievementModel? achievement;

  const AchievementDialog({super.key, this.achievement});

  @override
  State<AchievementDialog> createState() => _AchievementDialogState();
}

class _AchievementDialogState extends State<AchievementDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  String _selectedType = 'academic';

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.achievement?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.achievement?.description ?? '');
    _selectedDate = widget.achievement?.date ?? DateTime.now();
    _selectedType = widget.achievement?.type ?? 'academic';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.achievement == null
          ? 'Add Achievement'
          : 'Edit Achievement'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: const [
                  DropdownMenuItem(value: 'academic', child: Text('Academic')),
                  DropdownMenuItem(value: 'award', child: Text('Award')),
                  DropdownMenuItem(
                      value: 'certification', child: Text('Certification')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date'),
                subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState?.validate() == true) {
              final achievement = AchievementModel(
                id: widget.achievement?.id ?? DateTime.now().toString(),
                title: _titleController.text,
                description: _descriptionController.text,
                type: _selectedType,
                date: _selectedDate,
                imageUrl: widget.achievement?.imageUrl,
                documentUrl: widget.achievement?.documentUrl,
              );
              Navigator.pop(context, achievement);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}