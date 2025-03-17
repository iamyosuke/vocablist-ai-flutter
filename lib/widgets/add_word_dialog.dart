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
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Word',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _wordController,
              decoration: InputDecoration(
                hintText: 'Enter word',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit, color: Colors.deepPurple),
                  onPressed: _generateMeaning,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isGenerating)
              const Center(child: CircularProgressIndicator())
            else
              TextField(
                controller: _meaningController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Enter meaning',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addWord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
