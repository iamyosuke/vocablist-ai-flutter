import 'package:flutter/material.dart';
import '../models/word.dart';

class AddWordDialog extends StatefulWidget {
  final Function(Word) onWordAdd;

  const AddWordDialog({super.key, required this.onWordAdd});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  bool _isGenerating = false;

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  Future<void> _generateMeaning() async {
    if (_wordController.text.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    try {
      // TODO: AIを使用して意味を生成する処理を実装
      // 仮の実装として、簡単な例文を生成
      final meaning = '''
# 意味
${_wordController.text}の基本的な意味

# 例文
- This is an example sentence using ${_wordController.text}.
- Here is another example of ${_wordController.text}.

# 注意点
- 使用する際の注意点
- 類似語との違い
''';

      setState(() {
        _meaningController.text = meaning;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('意味の生成に失敗しました')));
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  void _addWord() {
    if (_wordController.text.isEmpty || _meaningController.text.isEmpty) return;

    final now = DateTime.now();
    final word = Word(
      word: _wordController.text,
      meaning: _meaningController.text,
      createdAt: now,
      updatedAt: now,
    );

    widget.onWordAdd(word);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しい単語を追加'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _wordController,
              decoration: const InputDecoration(
                labelText: '単語',
                border: OutlineInputBorder(),
              ),
              onEditingComplete: _generateMeaning,
            ),
            const SizedBox(height: 16),
            if (_isGenerating)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _generateMeaning,
                child: const Text('意味を生成'),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _meaningController,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: '意味',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(onPressed: _addWord, child: const Text('追加')),
      ],
    );
  }
}
