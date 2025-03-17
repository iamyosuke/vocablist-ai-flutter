import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:just_audio/just_audio.dart';
import '../models/word.dart';

class WordDetail extends StatefulWidget {
  final Word word;
  final Function(Word) onWordUpdate;

  const WordDetail({
    super.key,
    required this.word,
    required this.onWordUpdate,
  });

  @override
  State<WordDetail> createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail> {
  late TextEditingController _meaningController;
  late AudioPlayer _audioPlayer;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _meaningController = TextEditingController(text: widget.word.meaning);
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _meaningController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    try {
      // TextToSpeechを使用して単語を読み上げる
      // Note: 実際のTTS実装はプラットフォームに応じて異なります
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('音声の再生に失敗しました')),
      );
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // 編集モードを終了時に変更を保存
        final updatedWord = widget.word.copyWith(
          meaning: _meaningController.text,
          updatedAt: DateTime.now(),
        );
        widget.onWordUpdate(updatedWord);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.word.word),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.word.word,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: _speakWord,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isEditing)
              TextField(
                controller: _meaningController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '意味',
                ),
              )
            else
              MarkdownBody(data: widget.word.meaning),
            const SizedBox(height: 16),
            Text(
              '作成日: ${widget.word.createdAt.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '更新日: ${widget.word.updatedAt.toLocal()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}