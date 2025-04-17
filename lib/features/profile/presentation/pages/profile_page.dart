import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msu_connect/core/theme/app_theme.dart';
import 'package:msu_connect/features/auth/data/models/user_model.dart';
import 'package:msu_connect/features/profile/presentation/widgets/cached_profile_image.dart';
import 'package:msu_connect/features/profile/data/services/profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();
  UserModel? _user;
  bool _isEditing = false;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _studentIdController;
  late TextEditingController _programController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupUserListener();
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _studentIdController = TextEditingController();
    _programController = TextEditingController();
    _bioController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  void _setupUserListener() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && mounted) {
          setState(() {
            _user = UserModel.fromJson(snapshot.data()!);
            _nameController.text = _user?.name ?? '';
            _emailController.text = _user?.email ?? '';
            _studentIdController.text = _user?.studentId ?? '';
            _programController.text = _user?.program ?? '';
            _bioController.text = _user?.bio ?? '';
            _phoneController.text = _user?.phone ?? '';
            _addressController.text = _user?.address ?? '';
          });
        }
      }, onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load profile: $error')),
          );
        }
      });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _isLoading = true);
        final imageFile = File(image.path);
        final imageUrl = await ProfileService.uploadProfileImage(imageFile);
        setState(() {
          _user = _user?.copyWith(profileImageUrl: imageUrl);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: ${e.toString()}')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = true);
        await ProfileService.updateProfile({
          'name': _nameController.text,
          'email': _emailController.text,
          'studentId': _studentIdController.text,
          'program': _programController.text,
          'bio': _bioController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        });
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: _isEditing ? _saveProfile : _toggleEdit,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                                  CachedProfileImage(
                    imageUrl: _user?.profilePicture,
                    radius: 50,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: AppTheme.msuMaroon,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 18),
                          color: Colors.white,
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Full Name',
                _nameController,
                Icons.person,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Email',
                _emailController,
                Icons.email,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Student ID',
                _studentIdController,
                Icons.badge,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Program',
                _programController,
                Icons.school,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Bio',
                _bioController,
                Icons.description,
                enabled: _isEditing,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Phone',
                _phoneController,
                Icons.phone,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                'Address',
                _addressController,
                Icons.location_on,
                enabled: _isEditing,
                maxLines: 2,
              ),
              if (!_isEditing) ...[                
                const SizedBox(height: 24),
                _buildInfoCard('Academic Status', 'Good Standing'),
                const SizedBox(height: 16),
                _buildInfoCard('Current Semester', '2023/2024 - 1'),
                const SizedBox(height: 16),
                _buildInfoCard('Credits Completed', '60'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        enabled: enabled,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.msuMaroon,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _programController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _userSubscription?.cancel();
    super.dispose();
  }
}