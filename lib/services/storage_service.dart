import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/script_model.dart';

class StorageService {
  static const String _folderName = 'teleprompter_scripts';

  Future<Directory> _getStorageDirectory() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<List<ScriptModel>> loadAllScripts() async {
    try {
      final dir = await _getStorageDirectory();
      final List<FileSystemEntity> files = dir.listSync();
      final List<ScriptModel> scripts = [];

      for (var file in files) {
        if (file is File && file.path.endsWith('.json')) {
          final content = await file.readAsString();
          scripts.add(ScriptModel.fromJson(content));
        }
      }

      scripts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return scripts;
    } catch (e) {
      if (kDebugMode) {
        print('Load scripts error: $e');
      }
      return [];
    }
  }

  Future<void> saveScript(ScriptModel script) async {
    final dir = await _getStorageDirectory();
    final file = File('${dir.path}/${script.id}.json');
    await file.writeAsString(script.toJson());
  }

  Future<void> deleteScript(String id) async {
    final dir = await _getStorageDirectory();
    final file = File('${dir.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
