import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msu_connect/core/theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const ProfilePage({super.key, required this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _programController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _facultyController = TextEditingController();
  final _yearOfStudyController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;
  String _profileImageUrl = '';
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  void _loadUserData() {
    final user = FirebaseAuth.instance.currentUser;
    
    // First populate with data passed from dashboard
    if (widget.userData.isNotEmpty) {
      _nameController.text = widget.userData['displayName'] ?? '';
      _emailController.text = widget.userData['email'] ?? '';
      _phoneController.text = widget.userData['phone'] ?? '';
      _regNumberController.text = widget.userData['regNumber'] ?? '';
      _programController.text = widget.userData['program'] ?? '';
      _cardNumberController.text = widget.userData['cardNumber'] ?? '';
      _facultyController.text = widget.userData['faculty'] ?? '';
      _yearOfStudyController.text = widget.userData['yearOfStudy'] ?? '';
      _profileImageUrl = widget.userData['photoURL'] ?? '';
    }
    
    // Then try to get the most up-to-date data from Firestore
    if (user != null) {
      setState(() => _isLoading = true);
      
      FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) {
        if (doc.exists && mounted) {
          final data = doc.data() ?? {};
          setState(() {
            _nameController.text = data['displayName'] ?? _nameController.text;
            _emailController.text = data['email'] ?? _emailController.text;
            _phoneController.text = data['phone'] ?? _phoneController.text;
            _regNumberController.text = data['regNumber'] ?? _regNumberController.text;
            _programController.text = data['program'] ?? _programController.text;
            _cardNumberController.text = data['cardNumber'] ?? _cardNumberController.text;
            _facultyController.text = data['faculty'] ?? _facultyController.text;
            _yearOfStudyController.text = data['yearOfStudy'] ?? _yearOfStudyController.text;
            _profileImageUrl = data['photoURL'] ?? _profileImageUrl;
          });
        }
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $error')),
        );
      }).whenComplete(() {
        if (mounted) setState(() => _isLoading = false);
      });
    }
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  
  Future<String?> _uploadProfileImage() async {
    if (_profileImage == null) return _profileImageUrl;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${user.uid}.jpg');
      
      await storageRef.putFile(_profileImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      
      // Update user profile photo URL
      await user.updatePhotoURL(downloadUrl);
      
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
      return null;
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');
      
      // Upload profile image if selected
      String? photoURL;
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child('${user.uid}.jpg');
        
        // Upload the file
        await storageRef.putFile(_profileImage!);
        
        // Get download URL
        photoURL = await storageRef.getDownloadURL();
        
        // Update user profile photo URL in Firebase Auth
        await user.updatePhotoURL(photoURL);
      }
      
      // Update display name in Firebase Auth
      await user.updateDisplayName(_nameController.text);
      
      // Update user data in Firestore
      final userData = {
        'displayName': _nameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'regNumber': _regNumberController.text,
        'program': _programController.text,
        'cardNumber': _cardNumberController.text,
        'faculty': _facultyController.text,
        'yearOfStudy': _yearOfStudyController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Only add photoURL to userData if it was updated
      if (photoURL != null) {
        userData['photoURL'] = photoURL;
      }
      
      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Return to previous screen with updated data
        Navigator.pop(context, userData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error updating profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppTheme.msuMaroon,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Image
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl.isNotEmpty
                                    ? NetworkImage(_profileImageUrl) as ImageProvider
                                    : null),
                            child: _profileImage == null && _profileImageUrl.isEmpty
                                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppTheme.msuMaroon,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Personal Information Section
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Full Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                       // Email cannot be changed
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Academic Information Section
                    const Text(
                      'Academic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Registration Number
                    TextFormField(
                      controller: _regNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Registration Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your registration number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Program
                    TextFormField(
                      controller: _programController,
                      decoration: const InputDecoration(
                        labelText: 'Program',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.school),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your program';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Faculty
                    TextFormField(
                      controller: _facultyController,
                      decoration: const InputDecoration(
                        labelText: 'Faculty',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your faculty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Year of Study
                    TextFormField(
                      controller: _yearOfStudyController,
                      decoration: const InputDecoration(
                        labelText: 'Year of Study',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your year of study';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Card Information Section
                    const Text(
                      'Card Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card Number
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                        hintText: '**** **** **** ****',
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 19, // 16 digits + 3 spaces
                      onChanged: (value) {
                        // Format card number with spaces
                        if (value.isNotEmpty && !value.contains(' ')) {
                          String formatted = '';
                          for (int i = 0; i < value.length; i++) {
                            if (i > 0 && i % 4 == 0) {
                              formatted += ' ';
                            }
                            formatted += value[i];
                          }
                          _cardNumberController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.msuMaroon,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _regNumberController.dispose();
    _programController.dispose();
    _cardNumberController.dispose();
    _facultyController.dispose();
    _yearOfStudyController.dispose();
    super.dispose();
  }
}
