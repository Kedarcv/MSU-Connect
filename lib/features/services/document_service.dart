import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class DocumentService {
  final Dio _dio = Dio();
  static const String _documentsDir = 'msu_documents';

  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$_documentsDir';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  get getLocalPath => null;

  Future<File> downloadDocument(String url, String fileName) async {
    try {
      if (!await requestStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final path = await _localPath;
      final file = File('$path/$fileName');

      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      await file.writeAsBytes(response.data);
      return file;
    } catch (e) {
      throw Exception('Failed to download document: ${e.toString()}');
    }
  }

  Future<List<FileSystemEntity>> listDocuments() async {
    try {
      final path = await _localPath;
      final dir = Directory(path);
      return dir.listSync();
    } catch (e) {
      throw Exception('Failed to list documents: ${e.toString()}');
    }
  }

  Future<void> deleteDocument(String fileName) async {
    try {
      final path = await _localPath;
      final file = File('$path/$fileName');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete document: ${e.toString()}');
    }
  }

  Future<void> createDirectory(String dirName) async {
    try {
      final path = await _localPath;
      final dir = Directory('$path/$dirName');
      if (!await dir.exists()) {
        await dir.create();
      }
    } catch (e) {
      throw Exception('Failed to create directory: ${e.toString()}');
    }
  }

  Future<Map<String, List<String>>> organizeDocuments() async {
    try {
      final documents = await listDocuments();
      return {
        'notes': _filterByExtension(documents, ['.pdf', '.doc', '.docx']),
        'exams': _filterByExtension(documents, ['.pdf']),
        'timetables': _filterByExtension(documents, ['.pdf', '.jpg', '.png']),
        'others': _filterByExtension(documents, ['.txt', '.zip']),
      };
    } catch (e) {
      throw Exception('Failed to organize documents: ${e.toString()}');
    }
  }

  List<String> _filterByExtension(List<FileSystemEntity> files, List<String> extensions) {
    return files
        .whereType<File>()
        .where((file) => extensions.any((ext) => file.path.toLowerCase().endsWith(ext)))
        .map((file) => file.path.split('/').last)
        .toList();
  }
}