import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

class DocumentService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  get getLocalPath => null;

  // Upload a document file
  Future<String> uploadDocument(File file, String type) async {
    try {
      // Check if user is logged in
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Create a reference to the file location in Firebase Storage
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'documents/${user.uid}/$type/${timestamp}_$fileName';
      final storageRef = _storage.ref().child(storagePath);

      // Upload the file
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(fileName),
          customMetadata: {
            'userId': user.uid,
            'fileName': fileName,
            'type': type,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Store document metadata in Firestore
      await _firestore.collection('documents').add({
        'userId': user.uid,
        'fileName': fileName,
        'type': type.toLowerCase(),
        'storagePath': storagePath,
        'downloadUrl': downloadUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading document: $e');
      throw Exception('Failed to upload document: ${e.toString()}');
    }
  }

  // Get content type based on file extension
  String _getContentType(String fileName) {
    final ext = path.extension(fileName).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.ppt':
      case '.pptx':
        return 'application/vnd.ms-powerpoint';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Get document URL for viewing
  Future<String> getDocumentUrl(String fileName, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Query Firestore to find the document
      final querySnapshot = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: user.uid)
          .where('fileName', isEqualTo: fileName)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Document not found');
      }

      // Return the download URL
      return querySnapshot.docs.first.data()['downloadUrl'];
    } catch (e) {
      print('Error getting document URL: $e');
      throw Exception('Failed to get document URL: ${e.toString()}');
    }
  }

  // Get document download URL
  Future<String> getDocumentDownloadUrl(String fileName, String type) async {
    return getDocumentUrl(fileName, type);
  }

  // Delete a document
  Future<void> deleteDocument(String fileName, String type) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Query Firestore to find the document
      final querySnapshot = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: user.uid)
          .where('fileName', isEqualTo: fileName)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Document not found');
      }

      final docData = querySnapshot.docs.first.data();
      final storagePath = docData['storagePath'];

      // Delete from Storage
      await _storage.ref().child(storagePath).delete();

      // Delete from Firestore
      await querySnapshot.docs.first.reference.delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Failed to delete document: ${e.toString()}');
    }
  }

  // Get all documents for the current user
  Future<List<Map<String, dynamic>>> getUserDocuments() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final querySnapshot = await _firestore
          .collection('documents')
          .where('userId', isEqualTo: user.uid)
          .orderBy('uploadedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print('Error getting user documents: $e');
      throw Exception('Failed to get user documents: ${e.toString()}');
    }
  }

  // Organize documents by type
  Future<Map<String, List<String>>> organizeDocuments() async {
    try {
      final documents = await getUserDocuments();
      final Map<String, List<String>> organizedDocs = {};

      for (final doc in documents) {
        final type = doc['type'] as String;
        final fileName = doc['fileName'] as String;

        if (!organizedDocs.containsKey(type)) {
          organizedDocs[type] = [];
        }

        organizedDocs[type]!.add(fileName);
      }

      return organizedDocs;
    } catch (e) {
      print('Error organizing documents: $e');
      throw Exception('Failed to organize documents: ${e.toString()}');
    }
  }

  requestStoragePermission() {}
}