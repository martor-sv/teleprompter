import 'package:flutter/material.dart';
import '../models/script_model.dart';
import '../services/storage_service.dart';

class ScriptProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  List<ScriptModel> _scripts = [];
  bool _isLoading = false;
  ScriptModel? _activeScript;

  List<ScriptModel> get scripts => _scripts;
  bool get isLoading => _isLoading;
  ScriptModel? get activeScript => _activeScript;

  ScriptProvider() {
    loadScripts();
  }

  Future<void> loadScripts() async {
    _isLoading = true;
    notifyListeners();

    _scripts = await _storageService.loadAllScripts();
    
    // 如果没有任何台词，添加一个示例台词
    if (_scripts.isEmpty) {
      final demoScript = ScriptModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: '示例演说台词 - PromptSmart 体验',
        content: '''欢迎使用 Flutter 智能提词器应用！
这款提词器专为演讲者、播客主播和视频创作者打造。

你可以随时在主界面调整字体大小、自动滚动速度以及翻转镜像。
如果使用的是手机或支持语音识别的设备，还可以开启 Smart Scroll 智能语音追踪功能，系统会自动随着你的讲话进度推进文本。

祝你演讲顺利！录制出完美的视频作品。''',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _storageService.saveScript(demoScript);
      _scripts = [demoScript];
    }

    _isLoading = false;
    notifyListeners();
  }

  void setActiveScript(ScriptModel script) {
    _activeScript = script;
    notifyListeners();
  }

  Future<void> saveScript({String? id, required String title, required String content}) async {
    final now = DateTime.now();
    if (id == null || id.isEmpty) {
      // 新增
      final newScript = ScriptModel(
        id: now.millisecondsSinceEpoch.toString(),
        title: title.trim().isEmpty ? '未命名台词' : title.trim(),
        content: content,
        createdAt: now,
        updatedAt: now,
      );
      await _storageService.saveScript(newScript);
      _scripts.insert(0, newScript);
    } else {
      // 修改
      final index = _scripts.indexWhere((s) => s.id == id);
      if (index != -1) {
        final updated = _scripts[index].copyWith(
          title: title.trim().isEmpty ? '未命名台词' : title.trim(),
          content: content,
          updatedAt: now,
        );
        await _storageService.saveScript(updated);
        _scripts[index] = updated;
      }
    }
    notifyListeners();
  }

  Future<void> deleteScript(String id) async {
    await _storageService.deleteScript(id);
    _scripts.removeWhere((s) => s.id == id);
    if (_activeScript?.id == id) {
      _activeScript = null;
    }
    notifyListeners();
  }
}
