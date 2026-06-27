import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/prompter_controller.dart';
import '../providers/script_provider.dart';
import '../providers/settings_provider.dart';

class PrompterScreen extends StatefulWidget {
  const PrompterScreen({super.key});

  @override
  State<PrompterScreen> createState() => _PrompterScreenState();
}

class _PrompterScreenState extends State<PrompterScreen> {
  late PrompterController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _controller = PrompterController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      final script = Provider.of<ScriptProvider>(context, listen: false).activeScript;
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      if (script != null) {
        _controller.setScriptText(script.content);
      }
      if (settings.isSmartScrollEnabled) {
        _controller.initSpeech();
      }
      _startHideTimer();
    });
  }

  void _startHideTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _controller.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scriptProvider = Provider.of<ScriptProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final script = scriptProvider.activeScript;

    if (script == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text('未选择任何台词', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: settings.backgroundColor,
      body: ChangeNotifierProvider.value(
        value: _controller,
        child: Consumer<PrompterController>(
          builder: (context, controller, child) {
            return Focus(
              focusNode: _focusNode,
              autofocus: true,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent || event is KeyRepeatEvent) {
                  if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                    controller.scrollByDelta(-settings.keyboardScrollStep);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                    controller.scrollByDelta(settings.keyboardScrollStep);
                    return KeyEventResult.handled;
                  } else if (event.logicalKey == LogicalKeyboardKey.space) {
                    if (controller.isPlaying) {
                      controller.pause();
                    } else {
                      controller.start(settings);
                    }
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: GestureDetector(
                onTap: _toggleControls,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  children: [
                    _buildPrompterViewport(context, script.content, settings, controller),
                    _buildGuideline(context, settings),
                    if (controller.isCountdown)
                      _buildCountdownOverlay(controller.countdownRemaining),
                    if (_showControls) ...[
                      _buildTopBar(context, script.title, controller),
                      _buildBottomControlPanel(context, settings, controller),
                    ],
                    if (_showControls && settings.isSmartScrollEnabled)
                      _buildSpeechStatusBanner(controller),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPrompterViewport(
      BuildContext context, String content, SettingsProvider settings, PrompterController controller) {
    final size = MediaQuery.of(context).size;
    final scaleX = settings.isMirroredHorizontally ? -1.0 : 1.0;
    final scaleY = settings.isMirroredVertically ? -1.0 : 1.0;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(scaleX, scaleY, 1.0),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: controller.isPlaying
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * settings.indicatorPosition),
              Text(
                content,
                style: TextStyle(
                  color: settings.textColor,
                  fontSize: settings.fontSize,
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
              SizedBox(height: size.height * 0.7),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideline(BuildContext context, SettingsProvider settings) {
    final size = MediaQuery.of(context).size;
    final topOffset = size.height * settings.indicatorPosition;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Container(
          height: settings.fontSize * 1.8,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withValues(alpha: 0.08),
            border: Border(
              top: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1.5),
              bottom: BorderSide(color: Colors.blueAccent.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownOverlay(int seconds) {
    return Container(
      color: const Color(0xDD000000),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
          child: Text(
            '$seconds',
            key: ValueKey<int>(seconds),
            style: const TextStyle(
              color: Colors.blueAccent,
              fontSize: 120,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, String title, PrompterController controller) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          bottom: 12,
          left: 16,
          right: 16,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xDD000000), Colors.transparent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                controller.stop();
                Navigator.pop(context);
              },
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechStatusBanner(PrompterController controller) {
    final text = controller.lastRecognizedWords.isNotEmpty
        ? '已识别: "${controller.lastRecognizedWords}"'
        : (controller.isListening ? '🎙️ Smart Scroll 监听中...' : '🎙️ Smart Scroll 就绪');
    return Positioned(
      top: MediaQuery.of(context).padding.top + 50,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xB8000000),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.4)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.blueAccent, fontSize: 13),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildBottomControlPanel(
      BuildContext context, SettingsProvider settings, PrompterController controller) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 16,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.transparent, Color(0xE6000000)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 32,
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  onPressed: () => controller.resetScroll(),
                ),
                const SizedBox(width: 24),
                FloatingActionButton.large(
                  backgroundColor: Colors.blueAccent,
                  onPressed: () {
                    if (controller.isPlaying) {
                      controller.pause();
                    } else {
                      controller.start(settings);
                    }
                  },
                  child: Icon(
                    controller.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 24),
                IconButton(
                  iconSize: 32,
                  icon: Icon(
                    settings.isSmartScrollEnabled ? Icons.mic : Icons.speed,
                    color: settings.isSmartScrollEnabled ? Colors.blueAccent : Colors.white70,
                  ),
                  onPressed: () => settings.toggleSmartScroll(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.text_fields, color: Colors.white54, size: 20),
                    IconButton(
                      icon: const Icon(Icons.remove, color: Colors.white),
                      onPressed: () => settings.setFontSize(settings.fontSize - 4),
                    ),
                    Text(
                      '${settings.fontSize.toInt()}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => settings.setFontSize(settings.fontSize + 4),
                    ),
                  ],
                ),
                if (!settings.isSmartScrollEnabled)
                  Row(
                    children: [
                      const Icon(Icons.shutter_speed, color: Colors.white54, size: 20),
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => settings.setScrollSpeed(settings.scrollSpeed - 10),
                      ),
                      Text(
                        '${settings.scrollSpeed.toInt()}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => settings.setScrollSpeed(settings.scrollSpeed + 10),
                      ),
                    ],
                  ),
                IconButton(
                  icon: Icon(
                    Icons.flip,
                    color: settings.isMirroredHorizontally ? Colors.blueAccent : Colors.white54,
                  ),
                  onPressed: () => settings.toggleMirrorHorizontal(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
