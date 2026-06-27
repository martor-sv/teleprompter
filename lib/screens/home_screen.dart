import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/script_provider.dart';
import '../providers/settings_provider.dart';
import '../models/script_model.dart';
import 'edit_script_screen.dart';
import 'prompter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scriptProvider = Provider.of<ScriptProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.speed, color: Colors.blueAccent, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'PromptSmart Pro 提词器',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70),
            onPressed: () => _showGlobalSettingsDialog(context, settingsProvider),
          ),
        ],
      ),
      body: scriptProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : scriptProvider.scripts.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scriptProvider.scripts.length,
                  itemBuilder: (context, index) {
                    final script = scriptProvider.scripts[index];
                    return _buildScriptCard(context, script, scriptProvider);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditScriptScreen(),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '新建台词',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.article_outlined, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            '暂无演讲台词',
            style: TextStyle(color: Colors.white60, fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            '点击右下角按钮添加你的第一篇台词',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptCard(
      BuildContext context, ScriptModel script, ScriptProvider provider) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    script.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditScriptScreen(script: script),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDelete(context, provider, script.id),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              script.content,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '更新时间: ${dateFormat.format(script.updatedAt)}',
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    provider.setActiveScript(script);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrompterScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                  label: const Text(
                    '开始提词',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ScriptProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('删除台词', style: TextStyle(color: Colors.white)),
        content: const Text('确定要删除这篇演说台词吗？此操作无法撤销。',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              provider.deleteScript(id);
              Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGlobalSettingsDialog(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '全局偏好设置',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('智能语音追踪 (Smart Scroll)',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('根据说话进度自动同步滚动文本',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    value: settings.isSmartScrollEnabled,
                    activeTrackColor: Colors.blueAccent,
                    onChanged: (val) {
                      settings.toggleSmartScroll();
                      setModalState(() {});
                    },
                  ),
                  const Divider(color: Colors.white12),
                  ListTile(
                    title: const Text('启动倒计时', style: TextStyle(color: Colors.white)),
                    trailing: DropdownButton<int>(
                      dropdownColor: const Color(0xFF334155),
                      value: settings.countdownSeconds,
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                      items: [0, 3, 5, 10].map((sec) {
                        return DropdownMenuItem<int>(
                          value: sec,
                          child: Text(sec == 0 ? '无倒计时' : '$sec 秒'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          settings.setCountdownSeconds(val);
                          setModalState(() {});
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('键盘方向键微调距离', style: TextStyle(color: Colors.white)),
                            Text('${settings.keyboardScrollStep.toInt()} px',
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Slider(
                          value: settings.keyboardScrollStep,
                          min: 30.0,
                          max: 250.0,
                          divisions: 22,
                          activeColor: Colors.blueAccent,
                          onChanged: (val) {
                            settings.setKeyboardScrollStep(val);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
