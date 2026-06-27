import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/script_model.dart';
import '../providers/script_provider.dart';

class EditScriptScreen extends StatefulWidget {
  final ScriptModel? script;

  const EditScriptScreen({super.key, this.script});

  @override
  State<EditScriptScreen> createState() => _EditScriptScreenState();
}

class _EditScriptScreenState extends State<EditScriptScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.script?.title ?? '');
    _contentController =
        TextEditingController(text: widget.script?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text;
    final content = _contentController.text;

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('台词内容不能为空')),
      );
      return;
    }

    final provider = Provider.of<ScriptProvider>(context, listen: false);
    provider.saveScript(
      id: widget.script?.id,
      title: title,
      content: content,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.script != null;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? '编辑台词' : '新建台词',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.check, color: Colors.white, size: 18),
              label: const Text(
                '保存',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '输入台词标题...',
                hintStyle: TextStyle(color: Colors.white38, fontSize: 20),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.white12, height: 24),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.6,
                ),
                decoration: const InputDecoration(
                  hintText: '在此粘贴或输入演讲台词内容...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _contentController,
                  builder: (context, value, child) {
                    final count = value.text.length;
                    return Text(
                      '字数统计: $count 字',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    );
                  },
                ),
                TextButton.icon(
                  onPressed: () {
                    _contentController.clear();
                  },
                  icon: const Icon(Icons.clear_all, color: Colors.white38, size: 16),
                  label: const Text('清空', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
