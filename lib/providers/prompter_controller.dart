import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'settings_provider.dart';

enum PrompterState { stopped, countdown, playing, paused }

class PrompterController extends ChangeNotifier {
  final ScrollController scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();

  PrompterState _state = PrompterState.stopped;
  int _countdownRemaining = 3;
  Timer? _countdownTimer;
  Timer? _autoScrollTimer;

  // 键盘抗冲突防抖暂停定时器
  Timer? _keyboardPauseTimer;
  bool _isTemporarilyPausedByKeyboard = false;

  bool _isSpeechAvailable = false;
  bool _isListening = false;
  String _lastRecognizedWords = '';
  String _speechErrorMessage = '';
  int _currentMatchedCharIndex = 0;

  PrompterState get state => _state;
  bool get isPlaying => _state == PrompterState.playing;
  bool get isPaused => _state == PrompterState.paused;
  bool get isCountdown => _state == PrompterState.countdown;
  int get countdownRemaining => _countdownRemaining;
  bool get isSpeechAvailable => _isSpeechAvailable;
  bool get isListening => _isListening;
  String get lastRecognizedWords => _lastRecognizedWords;
  String get speechErrorMessage => _speechErrorMessage;
  bool get isTemporarilyPausedByKeyboard => _isTemporarilyPausedByKeyboard;

  String _scriptText = '';

  void setScriptText(String text) {
    _scriptText = text;
    _currentMatchedCharIndex = 0;
  }

  // 键盘响应：平滑滚动指定距离 (delta > 0 向下，delta < 0 向上)
  void scrollByDelta(double delta, {int durationMs = 180, int pauseMs = 500}) {
    if (!scrollController.hasClients) return;

    // 暂停自动滚动 0.5s，防止与手动按键动画冲突
    pauseTemporarilyForKeyboard(pauseMs: pauseMs);

    final currentOffset = scrollController.offset;
    final maxScroll = scrollController.position.maxScrollExtent;
    final targetOffset = (currentOffset + delta).clamp(0.0, maxScroll);

    scrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
    );
  }

  // 触发键盘防冲突暂停逻辑
  void pauseTemporarilyForKeyboard({int pauseMs = 500}) {
    _isTemporarilyPausedByKeyboard = true;
    notifyListeners();

    _keyboardPauseTimer?.cancel();
    _keyboardPauseTimer = Timer(Duration(milliseconds: pauseMs), () {
      _isTemporarilyPausedByKeyboard = false;
      notifyListeners();
    });
  }

  Future<void> initSpeech() async {
    try {
      _isSpeechAvailable = await _speechToText.initialize(
        onError: (val) {
          _speechErrorMessage = val.errorMsg;
          _isListening = false;
          notifyListeners();
        },
        onStatus: (status) {
          if (status == 'listening') {
            _isListening = true;
          } else {
            _isListening = false;
          }
          notifyListeners();
        },
      );
    } catch (e) {
      _isSpeechAvailable = false;
      _speechErrorMessage = '平台语音接口不受支持或未获得授权: $e';
    }
    notifyListeners();
  }

  void start(SettingsProvider settings) {
    if (_state == PrompterState.playing) return;

    if (settings.countdownSeconds > 0 && _state == PrompterState.stopped) {
      _state = PrompterState.countdown;
      _countdownRemaining = settings.countdownSeconds;
      notifyListeners();

      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _countdownRemaining--;
        if (_countdownRemaining <= 0) {
          timer.cancel();
          _beginPlay(settings);
        } else {
          notifyListeners();
        }
      });
    } else {
      _beginPlay(settings);
    }
  }

  void _beginPlay(SettingsProvider settings) {
    _state = PrompterState.playing;
    notifyListeners();

    if (settings.isSmartScrollEnabled) {
      _startSpeechTracking();
    } else {
      _startAutoScroll(settings);
    }
  }

  void pause() {
    _countdownTimer?.cancel();
    _autoScrollTimer?.cancel();
    _keyboardPauseTimer?.cancel();
    _isTemporarilyPausedByKeyboard = false;
    if (_isListening) {
      _speechToText.stop();
    }
    _state = PrompterState.paused;
    notifyListeners();
  }

  void stop() {
    _countdownTimer?.cancel();
    _autoScrollTimer?.cancel();
    _keyboardPauseTimer?.cancel();
    _isTemporarilyPausedByKeyboard = false;
    if (_isListening) {
      _speechToText.stop();
    }
    _state = PrompterState.stopped;
    _currentMatchedCharIndex = 0;
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
    notifyListeners();
  }

  void resetScroll() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  void _startAutoScroll(SettingsProvider settings) {
    _autoScrollTimer?.cancel();
    const interval = Duration(milliseconds: 16);
    _autoScrollTimer = Timer.periodic(interval, (timer) {
      // 若处于键盘事件临时暂停中，不进行时间驱动滚动，避免与用户按键冲突
      if (_state != PrompterState.playing ||
          !scrollController.hasClients ||
          _isTemporarilyPausedByKeyboard) {
        return;
      }
      final maxScroll = scrollController.position.maxScrollExtent;
      final currentScroll = scrollController.offset;

      if (currentScroll >= maxScroll) {
        pause();
        return;
      }

      final step = (settings.scrollSpeed * 0.03);
      scrollController.jumpTo((currentScroll + step).clamp(0.0, maxScroll));
    });
  }

  Future<void> _startSpeechTracking() async {
    if (!_isSpeechAvailable) {
      await initSpeech();
    }

    if (_isSpeechAvailable) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(hours: 2),
          pauseFor: const Duration(seconds: 10),
          partialResults: true,
          localeId: 'zh_CN',
        ),
      );
    } else {
      _speechErrorMessage = '语音不可用，自动降级为平滑自动滚动模式';
      notifyListeners();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastRecognizedWords = result.recognizedWords;
    notifyListeners();

    if (_scriptText.isEmpty ||
        !scrollController.hasClients ||
        _isTemporarilyPausedByKeyboard) {
      return;
    }

    final recognized = result.recognizedWords.replaceAll(RegExp(r'\s+'), '');
    if (recognized.length < 2) return;

    final query = recognized.length > 6 ? recognized.substring(recognized.length - 6) : recognized;
    final matchIndex = _scriptText.indexOf(query, _currentMatchedCharIndex);

    if (matchIndex != -1) {
      _currentMatchedCharIndex = matchIndex;
      final progress = _currentMatchedCharIndex / _scriptText.length;
      final maxScroll = scrollController.position.maxScrollExtent;
      final targetScroll = maxScroll * progress;

      scrollController.animateTo(
        targetScroll.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoScrollTimer?.cancel();
    _keyboardPauseTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
