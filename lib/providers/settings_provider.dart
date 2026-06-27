import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  double _fontSize = 40.0;
  double _scrollSpeed = 60.0;
  bool _isMirroredHorizontally = false;
  bool _isMirroredVertically = false;
  int _backgroundColorHex = 0xFF000000;
  int _textColorHex = 0xFFFFFFFF;
  double _indicatorPosition = 0.35;
  bool _isSmartScrollEnabled = false;
  int _countdownSeconds = 3;
  double _keyboardScrollStep = 100.0; // 键盘按键滚动步长（像素）

  double get fontSize => _fontSize;
  double get scrollSpeed => _scrollSpeed;
  bool get isMirroredHorizontally => _isMirroredHorizontally;
  bool get isMirroredVertically => _isMirroredVertically;
  Color get backgroundColor => Color(_backgroundColorHex);
  Color get textColor => Color(_textColorHex);
  double get indicatorPosition => _indicatorPosition;
  bool get isSmartScrollEnabled => _isSmartScrollEnabled;
  int get countdownSeconds => _countdownSeconds;
  double get keyboardScrollStep => _keyboardScrollStep;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _fontSize = _prefs.getDouble('fontSize') ?? 40.0;
    _scrollSpeed = _prefs.getDouble('scrollSpeed') ?? 60.0;
    _isMirroredHorizontally = _prefs.getBool('isMirroredHorizontally') ?? false;
    _isMirroredVertically = _prefs.getBool('isMirroredVertically') ?? false;
    _backgroundColorHex = _prefs.getInt('backgroundColorHex') ?? 0xFF000000;
    _textColorHex = _prefs.getInt('textColorHex') ?? 0xFFFFFFFF;
    _indicatorPosition = _prefs.getDouble('indicatorPosition') ?? 0.35;
    _isSmartScrollEnabled = _prefs.getBool('isSmartScrollEnabled') ?? false;
    _countdownSeconds = _prefs.getInt('countdownSeconds') ?? 3;
    _keyboardScrollStep = _prefs.getDouble('keyboardScrollStep') ?? 100.0;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value.clamp(18.0, 96.0);
    notifyListeners();
    await _prefs.setDouble('fontSize', _fontSize);
  }

  Future<void> setScrollSpeed(double value) async {
    _scrollSpeed = value.clamp(10.0, 200.0);
    notifyListeners();
    await _prefs.setDouble('scrollSpeed', _scrollSpeed);
  }

  Future<void> setKeyboardScrollStep(double value) async {
    _keyboardScrollStep = value.clamp(20.0, 300.0);
    notifyListeners();
    await _prefs.setDouble('keyboardScrollStep', _keyboardScrollStep);
  }

  Future<void> toggleMirrorHorizontal() async {
    _isMirroredHorizontally = !_isMirroredHorizontally;
    notifyListeners();
    await _prefs.setBool('isMirroredHorizontally', _isMirroredHorizontally);
  }

  Future<void> toggleMirrorVertical() async {
    _isMirroredVertically = !_isMirroredVertically;
    notifyListeners();
    await _prefs.setBool('isMirroredVertically', _isMirroredVertically);
  }

  Future<void> setColors(Color bg, Color text) async {
    _backgroundColorHex = bg.toARGB32();
    _textColorHex = text.toARGB32();
    notifyListeners();
    await _prefs.setInt('backgroundColorHex', _backgroundColorHex);
    await _prefs.setInt('textColorHex', _textColorHex);
  }

  Future<void> setIndicatorPosition(double val) async {
    _indicatorPosition = val.clamp(0.1, 0.8);
    notifyListeners();
    await _prefs.setDouble('indicatorPosition', _indicatorPosition);
  }

  Future<void> toggleSmartScroll() async {
    _isSmartScrollEnabled = !_isSmartScrollEnabled;
    notifyListeners();
    await _prefs.setBool('isSmartScrollEnabled', _isSmartScrollEnabled);
  }

  Future<void> setCountdownSeconds(int sec) async {
    _countdownSeconds = sec;
    notifyListeners();
    await _prefs.setInt('countdownSeconds', _countdownSeconds);
  }
}
